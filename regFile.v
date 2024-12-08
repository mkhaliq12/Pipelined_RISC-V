module regfile(
    input clk,
    input enrd,
    input wire[4:0] rdsel,
    input wire[31:0] rd,
    input wire[4:0] rs1sel,
    input wire[4:0] rs2sel,
    output reg[31:0] rs1,
    output reg[31:0] rs2
);

reg [31:0] registers[0:31];

always @(posedge clk) begin
    if(enrd) registers[rdsel] <= rd;

end

always @(*) begin
    rs1 = registers[rs1sel];
    rs2 = registers[rs2sel];
end

endmodule