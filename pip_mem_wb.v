module pip_mem_wb (
    input clk,
    input [31:0] alu_out,
    input [31:0] dmem_out,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input rdEn,

    output reg [31:0] alu_out_p,
    output reg [31:0] dmem_out_p,

    output reg [4:0] rs1_p,
    output reg [4:0] rs2_p,
    output reg [4:0] rd_p,
    output reg rdEn_p

);

always @(posedge clk) begin
    alu_out_p <= alu_out;
    dmem_out_p <= dmem_out;
    rs1_p <= rs1;
    rs2_p <= rs2;
    rd_p <= rd;
    rdEn_p <= rdEn;
end
    
endmodule