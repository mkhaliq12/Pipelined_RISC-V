module controlUnit(
    input wire[31:0]ins,
    input wire brnch,

    output reg[3:0] aluCont,
    output reg rdEn,
    output reg DMwriteEn,
    output reg pcloadEn,
    output reg[1:0]rdmuxSel,
    output reg[1:0]alumuxSel,
    output reg[31:0]imm
    );

wire [6:0] opcode;
wire [2:0] func3;
wire func7;

assign opcode = ins[6:0];
assign func3 = ins[14:12];
assign func7 = ins[30];


always@(*) begin
    if (opcode == 7'b0110011) begin         //R
        aluCont = {func7, func3};
        rdEn = 1;
        DMwriteEn = 0;
        imm = {{20{ins[31]}}, ins[31:20]}; 
        rdmuxSel = 2'b00;
        alumuxSel = 2'b00;
        pcloadEn = 0;
    end

    else if (opcode == 7'b0010011) begin    //I Arithmetic/logic
        aluCont = {func7, func3};
        rdEn = 1;
        DMwriteEn = 0;
        imm = {{20{ins[31]}}, ins[31:20]};
        if(func3==3'b101)
            imm = {27'd0, ins[24:20]}; 
        rdmuxSel = 2'b00;
        alumuxSel = 2'b01;
        pcloadEn = 0;
    end

    else if (opcode == 7'b0000011) begin    //I load
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = {{20{ins[31]}}, ins[31:20]}; 
        rdmuxSel = 2'b01;
        alumuxSel = 2'b01;
        pcloadEn = 0;
    end

    else if (opcode == 7'b0100011) begin    //S
        aluCont = 4'b0000;
        rdEn = 0;
        DMwriteEn = 1;
        imm = {{20{ins[31]}}, ins[31:25], ins[11:7]}; 
        rdmuxSel = 2'b00;
        alumuxSel = 2'b01;
        pcloadEn = 0;
        
    end

    else if (opcode == 7'b1100011) begin    //B
       aluCont = 4'b0000;
       rdEn = 0;
       DMwriteEn = 0;
       imm = {{20{ins[31]}}, ins[30:25], ins[7], ins[11:8], 1'b0};
       rdmuxSel = 2'b00;
       alumuxSel = 2'b10;
       pcloadEn = 1;
    end

    else if (opcode == 7'b1101111) begin    //J
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = {ins[31], ins[19:12], ins[20], ins[30:21], 1'b0}; 
        rdmuxSel = 2'b10;
        alumuxSel = 2'b10;
        pcloadEn = 1;
    end

    else if (opcode == 7'b1100111) begin    //I JALR
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = {{20{ins[31]}}, ins[31:20]}; 
        rdmuxSel = 2'b10;
        alumuxSel = 2'b11;
        pcloadEn = 1;
    end

    else if (opcode == 7'b0110111) begin    //U LUI
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = {ins[31:12], 12'd0}; 
        rdmuxSel = 2'b11;
        alumuxSel = 2'b00;
        pcloadEn = 0;
    end

    else if (opcode == 7'b0010111) begin    //U AUIPC
        aluCont = 4'b0000;
        rdEn = 1;
        DMwriteEn = 0;
        imm = {ins[31:12], 12'd0}; 
        rdmuxSel = 2'b00;
        alumuxSel = 2'b10;
        pcloadEn = 0;
    end

end


endmodule

