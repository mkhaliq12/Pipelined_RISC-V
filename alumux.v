module alumux(
    input wire[2:0] sel,
    input wire[31:0] rs1,
    input wire[31:0] rs2,
    input wire[31:0] pc,
    input wire[31:0] imm,
    output reg[31:0] aluIn1,
    output reg[31:0] aluIn2
);

always @(*) begin
    case(sel)
    2'b00: begin
        aluIn1 = rs1;
        aluIn2 = rs2;
    end
    2'b01: begin
        aluIn1 = rs1;
        aluIn2 = imm;
    end
    2'b10: begin        //B,j, AUIPC
        aluIn1 = pc;
        aluIn2 = imm;
    end
    2'b11: begin            //JALR
        aluIn1 = rs1;
        aluIn2 = pc;
    end
    endcase

end

endmodule


