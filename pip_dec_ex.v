module pip_dec_ex (
    input clk,
    input pip_en,

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
    input [1:0] rdmuxSel,
    input alumux1sel,
    input alumux2sel,  
    //mem wb signals
    input DMwriteEn,
    input rdEn,

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
    output reg [1:0] rdmuxSel_p,
    output reg alumux1sel_p,
    output reg alumux2sel_p,  
    //mem wb signals
    output reg DMwriteEn_p,
    output reg rdEn_p
);

always @(posedge clk) begin
    if (pip_en) begin
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
        rdEn_p <= rdEn;
    end
end

endmodule
