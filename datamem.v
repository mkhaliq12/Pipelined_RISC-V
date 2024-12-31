module datamem(
    input clk,
    input reset,
    input writeEn,
    input [31:0]addr,
    input wire[2:0]func3,
    input wire[31:0] storeVal,      //rs2
    output reg[31:0] loadVal,
    
    output reg data_ready
);

reg [31:0] memory [0:1023];
integer i;

initial begin
    for (i = 0; i < 1024; i = i + 1) begin
        memory[i] = 32'h0;
    end
    data_ready = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] <= 32'h0;
        end
        loadVal <= 32'h0;
        data_ready <= 0;
    end
    else begin
        data_ready <= 0;
        if (writeEn) begin
            memory[addr[11:2]] <= storeVal;
            data_ready <= 1;
        end
        else begin
            loadVal <= memory[addr[11:2]];
            data_ready <= 1;
        end
    end
end

endmodule
