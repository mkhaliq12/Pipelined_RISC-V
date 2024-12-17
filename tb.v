
module riscV_tb;

reg clk;
reg reset;

wire[18:0] out;

riscV riscV1(
    .clk(clk),
    .reset(reset),
    .out(out)
);

initial
begin
    clk = 0;
    forever
    #30 clk = ~clk;
end



initial begin
reset = 1;
#50
reset = 0;

repeat(500)@(posedge clk)
        $display("%0d", out);
    $stop;
end

endmodule
