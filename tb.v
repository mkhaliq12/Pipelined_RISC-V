
module tb_counter;
    reg clk;
    reg reset;
    wire [31:0] count;

counter counter_inst(
        .clk (clk),
        .reset(reset),
        .count(count)
    );

initial
begin
    clk = 0;
    forever
    #5 clk = ~clk;
end

initial
begin
    reset = 1;
    @(posedge clk);
    reset <= #1 0;
    @(posedge clk);
    reset <= #1 0;
    @(posedge clk);
    reset <= #1 0;
    repeat(20)@(posedge clk);
    $stop;
end
endmodule










/////////////////////
module regfile_tb;
    reg clk;
    reg enrd;
    reg [4:0] rdsel;
    reg [31:0] rd;
    reg [4:0] rs1sel;
    reg [4:0] rs2sel;
    wire [31:0] rs1;
    wire [31:0] rs2;


regfile reg_inst(
    .clk(clk),
    .enrd(enrd),
    .rdsel(rdsel),
    .rd(rd),
    .rs1sel(rs1sel),
    .rs2sel(rs2sel),
    .rs1(rs1),
    .rs2(rs2)
    );

initial
begin
    clk = 0;
    forever
    #10 clk = ~clk;
end

initial
begin
enrd = 1;
rdsel = 0;
rs1sel = 0;
rs2sel = 0;
rd = 32'hF00F;
@(posedge clk);
#5 rs2sel = 10;
rs1sel = 5;
rdsel = 10;
@(posedge clk);
@(posedge clk);

repeat(20)@(posedge clk);
$stop;
end
endmodule






////////////////////////////////////////////////////////



module insFetch(
    input clk,
    input reset,
    input enl,
    input wire[31:0] load,
    output wire[31:0] ins
    );

    wire[31:0] pmAdd;

    counter c1(
        .clk(clk),
        .reset(reset),
        .enl(enl),
        .load(load),
        .count(pmAdd)
    );

    programMem myMem(
        .address(pmAdd),
        .ins(ins)
    );

endmodule




module testmem;
    reg clk;
    reg reset;
    reg enl;
    reg[31:0] load;
    wire[31:0] ins;

insFetch sys1(
    .clk(clk),
    .reset(reset),
    .enl(enl),
    .load(load),
    .ins(ins)
);

initial
begin
    clk = 0;
    forever
    #10 clk = ~clk;
end

initial
begin
    reset = 0;
    enl = 1;
    load = 0;
    @(posedge clk )
        enl <= #1 0;
        $display("%0h", ins);
    @(posedge clk );
        reset <= #1 0;
        $display("%0h", ins);
    @(posedge clk );
    $display("%0h", ins);
    @(posedge clk );
    $display("%0h", ins);
    @(posedge clk );
    $display("%0h", ins);

    repeat(20)@(posedge clk)
        $display("%0h", ins);
    $stop;
end


endmodule


////////////////////////////