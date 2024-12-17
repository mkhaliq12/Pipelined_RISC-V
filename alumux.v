module alumux(
    input wire sel,
    input wire[31:0] rs1,
    input wire[31:0] pc,
    output reg[31:0] aluIn1
);

always @(*) begin
    case(sel)
    1'b0: aluIn1 = rs1;
    1'b1: aluIn1 = pc;
    endcase

end

endmodule


