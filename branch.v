module branch (
    input branch_comm,
    input prediction,
    input jump,
    input prev_mispredicted,
    input [31:0] PC,
    input [31:0] imm,
    output takebranch,
    output [31:0] next_add

);

reg [31:0] backup;

    
always @(*) begin
    if (prev_mispredicted) begin
        takebranch = 1;
        next_add = backup;
    end

    if ((branch_comm && prediction) || jump) begin
        takebranch = 1;
        next_add = PC + imm;
    end

    else begin
        takebranch = 0;
        next_add = PC + 4;
    end
end

always @(posedge clk ) begin
    if (branch_comm && prediction) 
        backup <= PC + 4;
    else if (branch_comm && !prediction)
        backup <= PC + imm;
end




endmodule
