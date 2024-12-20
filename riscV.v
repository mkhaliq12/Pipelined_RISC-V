module riscV(
    input wire clk,
    input wire reset,
    output wire [18:0] out
);

wire[31:0] instr;
wire[31:0] rd, rs1, rs2, imm;
wire[31:0] aluOut, count, dmLoad;
wire[31:0] A1, A2;

wire[2:0] immsel;

wire[3:0] alucont;
wire aluMux1Sel;
wire aluMux2sel;

wire[1:0] rdMuxsel;

wire rdEn, DMwriteEn, pcloadEn, branch;

wire[31:0] t6;

wire cache_hit, cache_Busy;
wire processor_stall = cache_Busy;

controlUnit CU1(
    .opcode(instr[6:0]),
    .func3(instr[14:12]),
    .func7(instr[30]),
    .brnch(branch),
    .cache_busy(cache_Busy),
    .aluCont(alucont),
    .rdEn(rdEn),
    .DMwriteEn(DMwriteEn),
    .pcloadEn(pcloadEn),
    .rdmuxSel(rdMuxsel),
    .alumux1sel(aluMux1Sel),
    .alumux2sel(aluMux2sel),
    .imm(immsel)
);

imm imm1(
    .ins(instr),
    .cont(immsel),
    .imm(imm)
);

// Modify program counter to respect cache stalls
pc counter(
    .clk(clk),
    .reset(reset),
    .enl(pcloadEn & ~processor_stall),  // Stall PC when cache is busy
    .load(aluOut),
    .count(count)
);

programMem progmem(
    .address(count),
    .ins(instr)
);

regFile regfile(
    .clk(clk),
    .enrd(rdEn),
    .reset(reset),
    .rdsel(instr[11:7]),
    .rs1sel(instr[19:15]),
    .rs2sel(instr[24:20]),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .out(t6)
);


rdmux rdMux(
    .sel(rdMuxsel),
    .dataMem(dmLoad),
    .alu(aluOut),
    .pc(count),
    .imm(imm),
    .rd(rd)
);

alu Alu(
    .A1(A1),
    .A2(A2),
    .aluCont(alucont),
    .aluOut(aluOut)
);

alumux Alumux1(
    .sel(aluMux1Sel),
    .rs1(rs1),
    .pc(count),
    .aluIn1(A1)
);

alumux2 Alumux2(
    .sel(aluMux2sel),
    .rs2(rs2),
    .imm(imm),
    .aluIn2(A2)
);

// Remove old datamem instantiation and replace with cache
cache datacache(
    .clk(clk),
    .reset(reset),    // Add missing reset signal
    .addr(aluOut),
    .write_data(rs2),
    .write_en(DMwriteEn),
    .func3(instr[14:12]),
    .read_data(dmLoad),
    .hit(cache_hit),
    .busy(cache_Busy)
);

brnch brnch1(
    .func3(instr[14:12]),
    .A(rs1),
    .B(rs2),
    .brnchOut(branch)
);


assign out = t6[18:0];

endmodule