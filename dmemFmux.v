module dmemFmux (
    input sel,
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
);

always @(*)begin
    if (sel) out = B;
    else if (!sel) out = A;

end
    
endmodule