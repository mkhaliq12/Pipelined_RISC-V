module riscV(
    input wire clk,
    input wire reset,
    output wire [18:0] out
);

wire[31:0] instr;
wire[31:0] rd, rs1, rs2, imm;
wire[31:0] aluOut, count, dmLoad;
wire[31:0] A1, A2;
wire [31:0] pcload;

wire[2:0] immsel;

wire[3:0] alucont;
wire aluMux1Sel;
wire aluMux2sel;

wire rdmuxSel;

wire rdEn, DMwriteEn, DMread, pcloadEn, branch, rs1_read, rs2_read, jump;

wire[31:0] t6;

//pipeline 
wire pip_en;
wire [31:0] instr_p;
wire[31:0] rs1_p, rs2_p, imm_p, rs2_p2;
wire [4:0] rs1_ad_p, rs2_ad_p, rd_ad_p;
wire [4:0] rs1_ad_p2, rs2_ad_p2, rd_ad_p2;
wire [4:0] rs1_ad_p3, rs2_ad_p3, rd_ad_p3;


wire rdEn_p, rdEn_p2, rdEn_p3;
wire rs1_read_p, rs1_read_p2;
wire rs2_read_p, rs2_read_p2;
wire DMwriteEn_p, DMwriteEn_p2;
wire DMread_p, DMread_p2, DMread_p3;
wire [3:0] aluCont_p;
wire [2:0] DM_ctrl_p, DM_ctrl_p2;
wire aluMux1Sel_p, aluMux2sel_p;

wire rdmuxSel_p, rdmuxSel_p2;

wire [31:0] alu_out_p;
wire [31:0] rd_p;
wire branch_comm_p;
wire branch_taken_p;

wire p1flush, p2flush;

programMem progmem(
    .address(count),
    .ins(instr)
);

pip_fetch_dec p1(
    .clk(clk),
    .pip_en(pip_en),
    .discard(p1flush),
    .instr(instr),
    .instr_p(instr_p)
);


controlUnit CU1(
    .opcode(instr_p[6:0]),
    .func3(instr_p[14:12]),
    .func7(instr_p[30]),
    .branch(branch),
    .jump(jump),

    .aluCont(alucont),
    .rdEn(rdEn),
    .rs1_read(rs1_read),
    .rs2_read(rs2_read),
    .DMwriteEn(DMwriteEn),
    .DMread(DMread),
    // .pcloadEn(pcloadEn),
    .rdmuxSel(rdmuxSel),
    .alumux1sel(aluMux1Sel),
    .alumux2sel(aluMux2sel),
    .imm(immsel)
);

imm imm1(
    .ins(instr_p),
    .cont(immsel),
    .imm(imm)
);


pip_dec_ex p2 (
    .clk(clk),                 
    .pip_en(pip_en), 
    .discard(p2flush),
    
    // Input connections
    .rs1_ad(instr_p[19:15]), 
    .rs2_ad(instr_p[24:20]),  
    .rd_ad(instr_p[11:7]), 
    .rs1(rs1), 
    .rs2(rs2), 
    .imm(imm),
    
    // ALU control signals
    .aluCont(aluCont),     
    .rdmuxSel(rdmuxSel),
    .alumux1sel(alumux1sel),
    .alumux2sel(alumux2sel),
    
    // Memory and writeback signals
    .DMwriteEn(DMwriteEn),
    .DMread(DMread),
    .DM_ctrl(instr[14:12]),
    .rdEn(rdEn),
    .rs1_read(rs1_read),
    .rs2_read(rs2_read),    
    .branch_comm(),
    .branch_taken(),
    
    // Output connections
    .rs1_ad_p(rs1_ad_p),
    .rs2_ad_p(rs2_ad_p),
    .rd_ad_p(rd_ad_p),
    .rs1_p(rs1_p),
    .rs2_p(rs2_p), 
    .imm_p(imm_p),
    
    // ALU control signals to execute stage
    .aluCont_p(aluCont_p),
    .rdmuxSel_p(rdmuxSel_p),
    .alumux1sel_p(alumux1sel_p),
    .alumux2sel_p(alumux2sel_p),
    
    // Memory and writeback signals to execute stage
    .DMwriteEn_p(DMwriteEn_p),
    .DMread_p(DMread_p),
    .DM_ctrl_p(DM_ctrl_p),
    .rdEn_p(rdEn_p),
    .rs1_read_p(rs1_read_p),
    .rs2_read_p(rs2_read_p),
    .branch_comm_p(),
    .branch_taken_p()    
);

pc counter(
    .clk(clk),
    .reset(reset),
    .enl(pcloadEn),
    .load(pcload),
    .count(count)
);


regFile regfile(
    .clk(clk),
    .enrd(rdEn_p3),
    .reset(reset),
    .rdsel(rd_ad_p3),
    .rs1sel(instr[19:15]),
    .rs2sel(instr[24:20]),
    .rd(rd_p),
    .rs1(rs1),
    .rs2(rs2),
    .out(t6)
);




alu Alu(
    .A1(rs1_p),     //check
    .A2(A2),
    .aluCont(alucont_p),
    .aluOut(aluOut)
);

// alumux Alumux1(     //rs1 or count remove
//     .sel(aluMux1Sel),
//     .rs1(rs1),
//     .pc(count),
//     .aluIn1(A1)
// );

mux2to1 Alumux2(    //correct
    .sel(aluMux2sel_p),
    .A(A2F),
    .B(imm_p),
    .Out(A2)
);

mux4to1 f1(
    .sel(ForwardA),
    .A(rs1_p),
    .B(rd_p),
    .C(alu_out_p),
    .out(A1)
);

mux4to1 f2(
    .sel(ForwardB),
    .A(rs2_p),
    .B(rd_p),
    .C(alu_out_p),
    .out(A2F)
);

wire [1:0] ForwardA, ForwardB;
wire ForwardC;
wire [31:0] A2F;

forwardingUnit fu1(
    .dec_ex_rs1_ad(rs1_ad_p),
    .dec_ex_rs2_ad(rs2_ad_p),
    .ex_mem_rs2_ad(rs2_ad_p2),
    .ex_mem_rd_ad(rd_ad_p2),
    .mem_wb_rd_ad(rd_ad_p3),
    .ex_mem_rdEn(rdEn_p2),
    .mem_wb_rdEn(rdEn_p3),
    .ex_mem_DMwriteEn(DMwriteEn_p2),
    .mem_wb_DMread(DMread_p3),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB),
    .ForwardC(ForwardC)
);

pip_ex_mem p3(
    .clk(clk),         
    .pip_en(pip_en),

    .alu_out(aluOut),
    .rs2(rs2_p2),
    .DM_ctrl(DM_ctrl_p),
    
    // Register addresses and control signals
    .rs1_ad(rs1_ad_p),  
    .rs2_ad(rs2_ad_p),
    .rd_ad(rd_ad_p),  
    .DMwriteEn(DMwriteEn_p), 
    .DMread(DMread_p),  
    .rdEn(rdEn_p),
    .rdmuxSel(rdmuxSel_p), 
    
    // Outputs to Memory stage
    .alu_out_p(alu_out_p), 
    .rs2_p(rs2_p2), 
    .DM_ctrl_p(DM_ctrl_p2), 
    
    // Register addresses and control signals to Memory stage
    .rs1_ad_p(rs1_ad_p2), 
    .rs2_ad_p(rs2_ad_p2),
    .rd_ad_p(rd_ad_p2),        
    .DMwriteEn_p(DMwriteEn_p2), 
    .DMread_p(DMread_p2),   
    .rdEn_p(rdEn_p2),
    .rdmuxSel_p(rdmuxSel_p2)   
);

mux2to1 f3(
    .sel(ForwardC),
    .A(rs2_p2),
    .B(rd_p),
    .Out(toDmem)
);

wire [31:0] toDmem;

datamem DataMem(        //fix
    .clk(clk),
    .writeEn(DMwriteEn_p2),
    .addr(alu_out_p),
    .func3(DM_ctrl_p2),
    .storeVal(toDmem),
    .loadVal(dmLoad)
);

mux2to1 rdMux(
    .sel(rdmuxSel_p2),
    .A(alu_out_p),
    .B(dmLoad),
    //.pc(count),
    //.imm(imm),
    .Out(rd)
);

pip_mem_wb p4 (
    .clk(clk),
    .rd(rd),
    
    .rs1_ad(rs1_ad_p2),
    .rs2_ad(rs2_ad_p2),
    .rd_ad(rd_ad_p2),
    .rdEn(rdEn_p2),
    .DMread(DMread_p2),
    
    .rd_p(rd_p),
    
    .rs1_ad_p(rs1_ad_p3),
    .rs2_ad_p(rs2_ad_p3),
    .rd_ad_p(rd_ad_p3),
    .rdEn_p(rdEn_p3),
    .DMread_p(DMread_p3)
);


branchresolve brnch1(   //in EX stage
    .func3(DM_ctrl_p), 
    .A(A1),
    .B(A2F),
    .branch_taken(branch_taken_p),
    .branch_comm(branch_comm_p),    
    .misprediction(mispredicted)        //out
);


pip_ctrl pctrl(
    .branch_taken(pcloadEn),
    .branch_mispredicted(mispredicted),
    .flush_fetch_dec(p1flush),
    .flush_dec_ex(p2flush)
);

branch b1(
    .branch_comm(branch),
    .prediction(prediction),
    .jump(jump),
    .prev_mispredicted(mispredicted),   //input
    .PC(count),
    .imm(imm),
    .takebranch(pcloadEn),              //out
    .next_add(pcload)

);

wire prediction;
wire mispredicted;

branchpredictor bp(     //in Dec stage
    .clk(clk),
    .rst(reset),
    .mispredicted(mispredicted),    //input
    .update_en(branch_comm_p),       //branch command
    .prediction(prediction)         //output
);

assign out = t6[18:0];





endmodule