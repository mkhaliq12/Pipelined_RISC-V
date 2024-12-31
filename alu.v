module alu(
    input wire signed [31:0] A1,
    input wire signed [31:0] A2,
    input wire[3:0] aluCont,
    output reg[31:0] aluOut

);

wire [31:0] X;
wire [31:0] Y;
assign X = A1;
assign Y = A2;

always@(*) begin
    case(aluCont)
    4'b0000: aluOut = A1 + A2;      //Add
    4'b1000: aluOut = A1 - A2;      //Sub
    4'b0100: aluOut = A1 ^ A2;      //XOR
    4'b0110: aluOut = A1 | A2;      //OR
    4'b0111: aluOut = A1 & A2;      //AND
    4'b0001: aluOut = A1 << A2;     //SLL
    4'b0101: aluOut = A1 >> A2;     //SRL
    4'b1101: aluOut = A1 >>> A2;    //SRA
    4'b0010: aluOut = A1 < A2 ? 32'd1 : 32'd0;  //SLT
    4'b0011: aluOut = X < Y ? 32'd1 : 32'd0;      //SLTU
    endcase


end

endmodule
