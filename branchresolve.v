module branchresolve(
    input wire [2:0] func3,
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    input wire branch_taken,    //was branch taken?
    input wire branch_comm,     //confirm if it was a branch command
    output reg misprediction);

wire [31:0] X;  //unsigned
wire [31:0] Y;  
assign X = A;
assign Y = B;

reg brnchOut;

always @(*) begin
    case(func3)
        3'b000: brnchOut = A == B ? 1:0;
        3'b001: brnchOut = A != B ? 1:0;
        3'b100: brnchOut = A <  B ? 1:0;
        3'b101: brnchOut = A >= B ? 1:0;
        3'b110: brnchOut = X <  Y ? 1:0;
        3'b111: brnchOut = X >= Y ? 1:0;
    endcase
end

always @(*) begin
    if (branch_comm && branch_taken && brnchOut) misprediction = 0;
    else if (branch_comm && !branch_taken && !brnchOut) misprediction = 0;
    else misprediction = 1;
end

endmodule



//https://stackoverflow.com/questions/21340093/why-is-this-verilog-relational-statement-returning-true
//
