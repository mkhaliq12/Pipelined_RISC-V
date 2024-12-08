module riscV(
    input wire clk,
    input wire reset,
);

wire[31:0] instr;

controlUnit CU1(
    .ins(instr),
    .brnch(),

    .aluCont(),
    .rdEn(),
    .DMwriteEn(),
    .pcloadEn(),
    .rdmuxSel(),
    .alumuxSel(),
    .imm()
);


pc counter(
    .clk(clk),
    .reset(reset),
    .enl(),
    .load(),
    .count()
);


programMem progmem(
    .address(),
    .ins(instr)
);

regFile regfile(
    .clk(clk),
    .enrd(),
    .rdsel(),
    .rs1sel(),
    .rs2sel(),
    .rd(),
    .rs1(),
    .rs2()
);


rdmux rdMux(
    .sel(),
    .dataMem(),
    .alu(),
    .pc(),
    .imm(),
    .rd()
);

alu Alu(
    .A1(),
    .A2(),
    .aluCont(),
    .aluOut()
);

alumux Alumux1(
    .sel(),
    .rs1(),
    .rs2(),
    .pc(),
    .imm(),
    .aluIn1(),
    .aluIn2()
);

datamem DataMem(
    .clk(),
    .writeEn(),
    .addr(),
    .func3(),
    .storeVal(),
    .loadVal()
);

brnch brnch1(
    .func3(),
    .A(),
    .B(),
    .brnchOut()
);








endmodule