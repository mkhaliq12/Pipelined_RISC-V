module regFile(
    input clk,
    input enrd,
    input reset,
    input wire [4:0] rdsel,
    input wire [31:0] rd,
    input wire [4:0] rs1sel,
    input wire [4:0] rs2sel,
    output wire[31:0] rs1,
    output wire[31:0] rs2,
    output wire[31:0] out
);

integer i;

reg [31:0] registers[0:31];



always @(posedge clk) begin
    if(enrd) begin 
        registers[rdsel] <= rd;
        registers[0] <= 0;

    end
    if(reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end
    end
    
end


assign rs1 = registers[rs1sel];
assign rs2 = registers[rs2sel];
assign out = registers[31];

endmodule

