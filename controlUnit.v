module controlUnit(
    input wire[6:0]opcode,            ///reduce
    input wire[2:0]func3,
    input wire func7,
    input wire brnch,

    output reg[3:0] aluCont,
    output reg rdEn,
    output reg DMwriteEn,
    output reg pcloadEn,
    output reg[1:0]rdmuxSel,
    output reg alumux1sel,
    output reg alumux2sel,
    output reg[2:0]imm   
    );



always@(*) begin
    case(opcode)
    7'b0110011: begin         //R
        aluCont = {func7, func3};
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b000; 
        rdmuxSel = 2'b00;
        alumux1sel  = 0;
        alumux2sel = 0;
        pcloadEn = 0;
    end

    7'b0010011: begin    //I Arithmetic/logic
        aluCont = {func7, func3};
        rdEn = 1;
        DMwriteEn = 0;
        if(func3==3'b101)
            imm = 3'b101; 
        else imm = 3'b000;

        rdmuxSel = 2'b00;
        alumux1sel  = 0;
        alumux2sel = 1;
        pcloadEn = 0;
    end

    7'b0000011: begin    //I load
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b000;
        rdmuxSel = 2'b01;
        alumux1sel  = 0;
        alumux2sel = 1;
        pcloadEn = 0;
    end

    7'b0100011: begin    //S
        aluCont = 4'b0000;
        rdEn = 0;
        DMwriteEn = 1;
        imm = 3'b001;
        rdmuxSel = 2'b00;
        alumux1sel  = 0;
        alumux2sel = 1;
        pcloadEn = 0;
        
    end

    7'b1100011: begin    //B
        aluCont = 4'b0000;
        rdEn = 0;
        DMwriteEn = 0;
        imm = 3'b010;
        rdmuxSel = 2'b00;
        alumux1sel  = 1;
        alumux2sel = 1;
        if (brnch)
            pcloadEn = 1;
    end

    7'b1101111: begin    //J
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b011; 
        rdmuxSel = 2'b10;
        alumux1sel  = 1;
        alumux2sel = 1;
        pcloadEn = 1;
    end

    7'b1100111: begin    //I JALR
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b000; 
        rdmuxSel = 2'b10;
        alumux1sel  = 0;
        alumux2sel = 1;
        pcloadEn = 1;
    end

    7'b0110111: begin    //U LUI
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b100; 
        rdmuxSel = 2'b11;
        alumux1sel  = 0;
        alumux2sel = 0;
        pcloadEn = 0;
    end

    7'b0010111: begin    //U AUIPC
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = 3'b100; 
        rdmuxSel = 2'b00;
        alumux1sel  = 1;
        alumux2sel = 1;
        pcloadEn = 0;
    end
    endcase

end


endmodule

