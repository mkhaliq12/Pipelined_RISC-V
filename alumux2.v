module alumux2(
    input wire sel,
    input wire[31:0] rs2,
    input wire[31:0] imm,
    output reg[31:0] aluIn2
);

always @(*) begin
    case(sel)
    1'b0: aluIn2 = rs2;
    1'b1: aluIn2 = imm;
    endcase

end

endmodule


