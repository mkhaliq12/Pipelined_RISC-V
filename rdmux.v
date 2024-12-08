module rdmux(
    input wire[1:0] sel,
    input wire[31:0] dataMem,
    input wire[31:0] alu,
    input wire[31:0] pc,
    input wire[31:0] imm,
    output reg[31:0] rd
);

always @(*) begin
    case(sel)
    2'b00: rd = alu;        //R,IA
    2'b01: rd = dataMem;    //IL
    2'b10: rd = pc + 4;
    2'b11: rd = imm;
    endcase

end


endmodule