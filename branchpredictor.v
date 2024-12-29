module branchpredictor (
    input wire clk,
    input wire rst,
    input wire mispredicted,      // Input: 1 if a misprediction occurred, 0 otherwise
    input wire update_en,         // Input: Enable signal to update the predictor
    output wire prediction        // Output: Predict next branch (1: taken, 0: not taken)
);

    // State encoding
    parameter STRONGLY_NOT_TAKEN = 2'b00;
    parameter WEAKLY_NOT_TAKEN   = 2'b01;
    parameter WEAKLY_TAKEN       = 2'b10;
    parameter STRONGLY_TAKEN     = 2'b11;
    
    // State register
    reg [1:0] state;
    
    // Prediction is simply the MSB of state
    assign prediction = state[1];
    
    // State transition logic
    always @(posedge clk) begin
        if (rst) begin
            state <= WEAKLY_NOT_TAKEN;  // Initialize to weakly not taken
        end
        else if (update_en) begin
            case (state)
                STRONGLY_NOT_TAKEN: 
                    state <= mispredicted ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                WEAKLY_NOT_TAKEN:   
                    state <= mispredicted ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
                WEAKLY_TAKEN:       
                    state <= mispredicted ? WEAKLY_NOT_TAKEN : STRONGLY_TAKEN;
                STRONGLY_TAKEN:     
                    state <= mispredicted ? WEAKLY_TAKEN : STRONGLY_TAKEN;
            endcase
        end
    end

endmodule
