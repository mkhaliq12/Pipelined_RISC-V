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

//pipeline 
wire pip_en;
wire [31:0] instr_p;
wire[31:0] rs1_p, rs2_p, imm_p;
wire [4:0] rs1_ad_p, rs2_ad_p, rd_ad_p;

wire rdEn_p, rdEn_p2;
wire DMwriteEn_p, DMwriteEn_p2;
wire [3:0] aluCont_p;
wire aluMux1Sel_p, aluMux2sel_p;

wire[1:0] rdMuxsel_p;


programMem progmem(
    .address(count),
    .ins(instr)
);

pip_fetch_dec p1(
    .clk(clk),
    .pip_en(pip_en),
    .instr(instr),
    .instr_p(instr_p)
);


controlUnit CU1(
    .opcode(instr_p[6:0]),
    .func3(instr_p[14:12]),
    .func7(instr_p[30]),
    .brnch(branch),

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
    .ins(instr_p),
    .cont(immsel),
    .imm(imm)
);


pip_dec_ex decode_execute_pipeline (
    .clk(clk),                 
    .pip_en(pip_en), 
    
    // Input connections
    .rs1_ad(instr_p[19:15]), 
    .rs2_ad(instr_p[24:20]),  
    .rd_ad(instr_p[11:7]), 
    .rs1(rs1), 
    .rs2(rs2), 
    .imm(imm),
    
    // ALU control signals
    .aluCont(aluCont),     
    .rdmuxSel(rd_mux_select),
    .alumux1sel(alumux1sel),
    .alumux2sel(alumux2sel),
    
    // Memory and writeback signals
    .DMwriteEn(DMwriteEn),
    .rdEn(rdEn),
    
    // Output connections
    .rs1_ad_p(rs1_ad_p),
    .rs2_ad_p(rs2_ad_p),
    .rd_ad_p(rd_ad_p),
    .rs1_p(rs1_p),
    .rs2_p(rs2_p), 
    .imm_p(imm_p),
    
    // ALU control signals to execute stage
    .aluCont_p(aluCont_p),
    .rdmuxSel_p(rd_mux_select_ex),
    .alumux1sel_p(alumux1sel_p),
    .alumux2sel_p(alumux2sel_p),
    
    // Memory and writeback signals to execute stage
    .DMwriteEn_p(DMwriteEn_p),
    .rdEn_p(rdEn_p)
);

pc counter(
    .clk(clk),
    .reset(reset),
    .enl(pcloadEn),
    .load(aluOut),
    .count(count)
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

datamem DataMem(
    .clk(clk),
    .writeEn(DMwriteEn),
    .addr(aluOut),
    .func3(instr[14:12]),
    .storeVal(rs2),
    .loadVal(dmLoad)
);

brnch brnch1(
    .func3(instr[14:12]),
    .A(rs1),
    .B(rs2),
    .brnchOut(branch)
);


assign out = t6[18:0];





endmodule