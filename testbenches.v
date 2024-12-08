//////////////////////////// counter
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










/////////////////////       reg file
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




////////////////////////////////////        counter + progMem

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


//////////////////              alu

module alu_tb;

reg [31:0] A;
reg [31:0] B;
reg [3:0] cont;
wire [31:0] out;


alu Alu(
    .A1(A),
    .A2(B),
    .aluCont(cont),
    .aluOut(out)
);

initial begin
#100 A = 0; B = 0; cont = 4'b0000;
#100 A = 1; B = 1; cont = 4'b0000;
#100 A = 2; B = 2; cont = 4'b0000;
#100 A = 3; B = 3; cont = 4'b0000;
#100 A = -10; B = 3; cont = 4'b0011;
#100 A = -10; B = 3; cont = 4'b0010;


end


endmodule


/////////////////////////              brnch


module brnch_tb;

    reg [3:0] func3;
    reg [31:0] A, B;
    wire brnchOut;

    brnch brnch1(
        .func3(func3),
        .A(A),
        .B(B),
        .brnchOut(brnchOut)
    );

initial begin
#100 A = 0; B = 0; func3 = 0;
#100 A = 1; B = 1; func3 = 1;
#100 A = -3; B = 2; func3 = 4;
#100 A = -3; B = 3; func3 = 6;
#100 A = 10; B = 3; func3 = 5;
#100 A = -10; B = 3; func3 = 7;
end


endmodule



/////////////////////////////////// data mem


module datamem_tb;

    reg clk;
    reg writeEn;
    reg [31:0] storeVal;      //rs2
    reg [31:0] addr;
    reg [2:0]func3;
    wire [31:0] loadVal;

    datamem dut(
        .clk(clk),
        .writeEn(writeEn),
        .addr(addr),
        .func3(func3),
        .storeVal(storeVal),
        .loadVal(loadVal)
    );

initial begin
    writeEn = 1;
    storeVal = -8;
    func3 = 2;
    addr = 0;
    clk = 0;
    #10;
    clk = 1;
    #10
    clk = 0;

    writeEn = 0;
    #100 func3 = 0;
    #100 func3 = 1;
    #100 func3 = 2;
    #100 func3 = 4;
    #100 func3 = 5;





end


endmodule




//////////////////// riscv

module riscV_tb;

reg clk;
reg reset;

wire[9:0] out;

riscV riscV1(
    .clk(clk),
    .reset(reset),
    .out(out)
);

initial begin
clk = 0;

#10
clk = 1;
reset = 0;
end

endmodule





////////////////////////////// riscV


module riscV_tb;

reg clk;
reg reset;

wire[9:0] out;

riscV riscV1(
    .clk(clk),
    .reset(reset),
    .out(out)
);

initial
begin
    clk = 0;
    forever
    #10 clk = ~clk;
end



initial begin
reset = 1;
#30
reset = 0;

repeat(500)@(posedge clk)
        $display("%0d", out);
    $stop;
end

endmodule