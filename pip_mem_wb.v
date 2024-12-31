module pip_mem_wb (
    input clk,
    input pip_en,
    input discard,

    input [31:0] rd,

    input [4:0] rs1_ad,        //only rd needed I think
    input [4:0] rs2_ad,
    input [4:0] rd_ad,
    input rdEn,
    input DMread,

    output reg [31:0] rd_p,

    output reg [4:0] rs1_ad_p,
    output reg [4:0] rs2_ad_p,
    output reg [4:0] rd_ad_p,
    output reg rdEn_p,
    output reg DMread_p

);

always @(posedge clk) begin
    if(pip_en && !discard) begin
        rd_p <= rd;
        rs1_ad_p <= rs1_ad;
        rs2_ad_p <= rs2_ad;
        rd_ad_p <= rd_ad;
        rdEn_p <= rdEn;
        DMread_p <= DMread;
    end
    else if(pip_en && discard) begin
        rd_p <= 0;
        rs1_ad_p <= 0;
        rs2_ad_p <= 0;
        rd_ad_p <= 0;
        rdEn_p <= 0;
        DMread_p <= 0;
    end
end
    
endmodule
