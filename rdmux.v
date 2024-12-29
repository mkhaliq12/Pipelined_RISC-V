module rdmux(           //reduced this to only datamem and alu
    input wire sel,
    input wire[31:0] dataMem,
    input wire[31:0] alu,
//    input wire[31:0] pc,
//    input wire[31:0] imm,
    output reg[31:0] rd 
);

always @(*) begin
    case(sel)
    0: rd = alu;        //R,IA
    1: rd = dataMem;    //IL
//    2'b10: rd = pc + 4;
//    2'b11: rd = imm;    	//LUI
    endcase

end


endmodule