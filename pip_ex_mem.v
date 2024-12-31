module pip_ex_mem (
    input clk,
    input pip_en,
    input discard,

    input [31:0] alu_out,
    input [31:0] rs2,


    input [4:0] rs1_ad,
    input [4:0] rs2_ad,
    input [4:0] rd_ad,
    input DMwriteEn,
    input DMread,
    input [2:0] DM_ctrl,
    input rdEn,
    input rdmuxSel,

    output reg [31:0] alu_out_p,
    output reg [31:0] rs2_p,

    output reg [4:0] rs1_ad_p,
    output reg [4:0] rs2_ad_p,
    output reg [4:0] rd_ad_p,
    output reg DMwriteEn_p,
    output reg DMread_p,
    output reg [2:0] DM_ctrl_p,
    output reg rdEn_p,
    output reg rdmuxSel_p

);

always @(posedge clk ) begin
    if(pip_en && !discard) begin
        rs1_ad_p <= rs1_ad;
        rs2_ad_p <= rs2_ad;
        rd_ad_p <= rd_ad;
        DMwriteEn_p <= DMwriteEn;
        DMread_p <= DMread;
        rdEn_p <= rdEn;

        alu_out_p <= alu_out;
        rs2_p <= rs2;
        DM_ctrl_p <= DM_ctrl;

        rdmuxSel_p <= rdmuxSel;
    end

    else if(pip_en && discard) begin
        rs1_ad_p <= 0;
        rs2_ad_p <= 0;
        rd_ad_p <= 0;
        DMwriteEn_p <= 0;
        DMread_p <= 0;
        rdEn_p <= 0;

        alu_out_p <= 0;
        rs2_p <= 0;
        DM_ctrl_p <= 0;

        rdmuxSel_p <= 0;
    end

end
    
endmodule
