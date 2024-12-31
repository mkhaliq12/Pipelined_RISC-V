module pc(
    input clk,
    input reset,
    input enl,
    input wire[31:0] load,     
    output reg[31:0] count
);

always @(posedge clk ) begin
    if(reset) count <= 0;
    else if(enl) count <= load;
    else count <= count + 4;
end
endmodule
