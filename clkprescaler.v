module clkprescaler(
    input clk,
    input reset,
    output reg clkout);

reg [26:0] count;


always @(posedge clk or reset) begin
    if(reset) begin
        clkout <= 0;
        count <=0;
    end
    else begin
        if(count < 12_500_000)
            count <= count +1;
        else begin
            clkout <= ~ clkout;
            count <= 0;
        end
    end
end


endmodule
