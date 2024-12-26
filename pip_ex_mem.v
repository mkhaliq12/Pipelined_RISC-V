module pip_dec_ex (
    input clk,
    input [31:0] alu_out,
    input [31:0] dmem_addr,
    input [2:0] dmem_ctrl,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input DMwriteEn,
    input rdEn,

    output reg [31:0] alu_out_p,
    output reg [31:0] dmem_addr_p,
    output reg [2:0] dmem_ctrl_p,

    output reg [4:0] rs1_p,
    output reg [4:0] rs2_p,
    output reg [4:0] rd_p,
    output reg DMwriteEn_p,
    output reg rdEn_p

);

always @(posedge clk ) begin
    rs1_p <= rs1;
    rs2_p <= rs2;
    rd_p <= rd;
    DMwriteEn_p <= DMwriteEn;
    rdEn_p <= rdEn;

    alu_out_p <= alu_out;
    dmem_addr_p <= dmem_addr;
    dmem_ctrl_p <= dmem_ctrl;
end
    
endmodule