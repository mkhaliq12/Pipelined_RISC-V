module mux2to1 (
    input wire sel,
    input wire[31:0] A,
    input wire[31:0] B,
    output reg[31:0] Out
);

always @(*) begin
    case(sel)
        1'b0: Out = A;
        1'b1: Out = B;
    endcase

end

endmodule
