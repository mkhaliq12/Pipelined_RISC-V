module imm(
    input wire[2:0] sel,
    input wire[31:0] ins, //machine code
    output reg[31:0] imm
);

always @(*) begin
    case(sel)
    3b'000: imm = {20{ins[31]}, ins[31:25]};                            //I
    3b'001: imm = {20{ins[31]}, ins[31:25], ins[11:7]};                 //S
    3b'010: imm = {20{ins[31]}, ins[30:25], ins[7], ins[11:8], 1'b0};   //B
    3b'011: imm = {20'd0, ins[31:12]} << 12;                            //U
    3b'100: imm = {ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};     //J

    endcase

end


endmodule