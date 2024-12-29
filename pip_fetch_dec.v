module pip_fetch_dec (
    input clk,
    input pip_en,
    input discard,

    input [31:0] instr,
    output reg [31:0] instr_p
);
    
always @(posedge clk) begin
    if(pip_en && !discard)
        instr_p <= instr;
    else if(pip_en && discard)
        instr_p <= 0;
end

endmodule

