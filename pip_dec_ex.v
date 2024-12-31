module pip_dec_ex (
    input clk,
    input pip_en,
    input discard,

    //register addresses
    input [4:0] rs1_ad,
    input [4:0] rs2_ad,
    input [4:0] rd_ad,
    //reg/imm value
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] imm,
    //alu signals
    input [3:0] aluCont,
    input rdmuxSel,
    input alumux1sel,
    input alumux2sel,  
    //mem wb signals
    input DMwriteEn,
    input DMread,
    input [2:0] DM_ctrl,
    input rdEn,
    input rs1_read,
    input rs2_read,
    input branch_comm,
    input branch_taken,

    //register addresses
    output reg [4:0] rs1_ad_p,
    output reg [4:0] rs2_ad_p,
    output reg [4:0] rd_ad_p,
    //reg/imm value
    output reg [31:0] rs1_p,
    output reg [31:0] rs2_p,
    output reg [31:0] imm_p,
    //alu signals
    output reg [3:0] aluCont_p,
    output reg rdmuxSel_p,
    output reg alumux1sel_p,
    output reg alumux2sel_p,  
    //mem wb signals
    output reg DMwriteEn_p,
    output reg DMread_p,
    output reg [2:0] DM_ctrl_p,
    output reg rdEn_p,
    output reg rs1_read_p,
    output reg rs2_read_p,
    output reg branch_comm_p,
    output reg branch_taken_p
);

always @(posedge clk) begin
    if (pip_en && !discard) begin
        // Register addresses
        rs1_ad_p <= rs1_ad;
        rs2_ad_p <= rs2_ad;
        rd_ad_p <= rd_ad;
        
        // Register values and immediate
        rs1_p <= rs1;
        rs2_p <= rs2;
        imm_p <= imm;
        
        // ALU signals
        aluCont_p <= aluCont;
        rdmuxSel_p <= rdmuxSel;
        alumux1sel_p <= alumux1sel;
        alumux2sel_p <= alumux2sel;
        
        // Memory and write-back signals
        DMwriteEn_p <= DMwriteEn;
        DMread_p <= DMread;
        DM_ctrl_p <= DM_ctrl; 
        rdEn_p <= rdEn;
        rs1_read_p <= rs1_read;
        rs2_read_p <= rs2_read;
        branch_taken_p <= branch_taken;
        branch_comm_p <= branch_comm;
        
    end

    else if (pip_en && discard) begin
        rs1_ad_p <= 0;
        rs2_ad_p <= 0;
        rd_ad_p <= 0;
        
        rs1_p <= 0;
        rs2_p <= 0;
        imm_p <= 0;
        
        aluCont_p <= 0;
        rdmuxSel_p <= 0;
        alumux1sel_p <= 0;
        alumux2sel_p <= 0;
        
        DMwriteEn_p <= 0;
        DMread_p <= 0;
        DM_ctrl_p <= 0; 
        rdEn_p <= 0;
        rs1_read_p <= 0;
        rs2_read_p <= 0;
        branch_taken_p <= 0;
        branch_comm_p <= 0;
    end

end

endmodule
