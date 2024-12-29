module aluFmux (
    input [1:0] sel,
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    output [31:0] out
);

always @(*)begin
    case (sel)
        0: out = A;
        1: out = B;
        2: out = C;
        default: out = A;
    endcase

end
    
endmodule