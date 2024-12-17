module brnch(
    input wire [2:0] func3,
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    output reg brnchOut);

wire [31:0] X;
wire [31:0] Y;
assign X = A;
assign Y = B;


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

endmodule



//https://stackoverflow.com/questions/21340093/why-is-this-verilog-relational-statement-returning-true
//