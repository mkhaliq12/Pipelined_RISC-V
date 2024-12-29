module pip_mem_wb (
    input clk,
    input [31:0] rd,

    input [4:0] rs1_ad,        //only rd needed I think
    input [4:0] rs2_ad,
    input [4:0] rd_ad,
    input rdEn,

    output reg [31:0] rd_p,

    output reg [4:0] rs1_ad_p,
    output reg [4:0] rs2_ad_p,
    output reg [4:0] rd_ad_p,
    output reg rdEn_p

);

always @(posedge clk) begin
    rd_p <= rd;
    rs1_ad_p <= rs1_ad;
    rs2_ad_p <= rs2_ad;
    rd_ad_p <= rd_ad;
    rdEn_p <= rdEn;
end
    
endmodule