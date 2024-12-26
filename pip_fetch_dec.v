module pip_fetch_dec (
    input clk,
    input pip_en,
    input [31:0] instr,
    output reg [31:0] instr_p
);
    
always @(posedge clk) begin
    if(pip_en)
        instr_p <= instr;
end

endmodule

