module two_bit_predictor (
    input wire clk,
    input wire rst,
    input wire branch_outcome,    // Input: Was branch taken? (1: taken, 0: not taken)
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
        else begin
            case (state)
                STRONGLY_NOT_TAKEN: 
                    state <= branch_outcome ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                WEAKLY_NOT_TAKEN:   
                    state <= branch_outcome ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
                WEAKLY_TAKEN:       
                    state <= branch_outcome ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
                STRONGLY_TAKEN:     
                    state <= branch_outcome ? STRONGLY_TAKEN : WEAKLY_TAKEN;
            endcase
        end
    end

endmodule