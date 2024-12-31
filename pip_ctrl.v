module pip_ctrl (
    // input wire clk,
    // input wire reset,
    input wire branch_taken,
    input wire branch_mispredicted,
    // input wire data_hazard,
    // input wire load_use_hazard,

    // output reg stall_fetch_dec,
    // output reg stall_dec_ex,
    // output reg stall_ex_mem,
    output reg flush_fetch_dec,
    output reg flush_dec_ex
    // output reg flush_ex_mem
);


always @(*) begin

    // Handle branch prediction
    if (branch_mispredicted) begin
        // Prioritize branch misprediction
        flush_fetch_dec = 1'b1;
        flush_dec_ex = 1'b1;
        // flush_ex_mem = 1'b0; // check
    end else if (branch_taken) begin
        // Handle normal branch
        flush_fetch_dec = 1'b1;
        flush_dec_ex = 1'b0;
        // flush_ex_mem = 1'b0;
    end else begin
        // Default state
        flush_fetch_dec = 1'b0;
        flush_dec_ex = 1'b0;
        // flush_ex_mem = 1'b0;
    end

        // // Handle data hazards
        // if (data_hazard) begin
        //     stall_fetch_dec <= 1'b1;
        //     stall_dec_ex <= 1'b1;
        // end else begin
        //     stall_dec_ex <= 1'b0;
        // end

        // // Handle load-use hazards
        // if (load_use_hazard) begin
        //     stall_fetch_dec <= 1'b1;
        //     stall_dec_ex <= 1'b1;
        //     stall_execute <= 1'b1;
        // end else begin
        //     stall_execute <= 1'b0;
        // end
    
end

endmodule
