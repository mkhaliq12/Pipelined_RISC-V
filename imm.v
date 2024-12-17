module imm(
    input wire[31:0] ins,
    input wire[2:0] cont,
    output reg [31:0] imm
);

always@(*) begin
    case(cont)
    3'b000: imm = {{20{ins[31]}}, ins[31:20]}; //I
    3'b001: imm = {{20{ins[31]}}, ins[31:25], ins[11:7]};   //S
    3'b010: imm = {{20{ins[31]}}, ins[30:25], ins[7], ins[11:8], 1'b0}; //B
    3'b011: imm = {{11{ins[31]}}, ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};     //J
    3'b100: imm = {ins[31:12], 12'd0};  //U
    3'b101: imm = {27'd0, ins[24:20]}; ////I sll


    endcase
end



endmodule