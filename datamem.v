module datamem(
    input clk,
    input writeEn,
    input addr,
    input wire[2:0]func3,
    input wire[31:0] storeVal,      //rs2
    output reg[31:0] loadVal

);

reg [7:0] mem[0:40];

always@(posedge clk) begin
    if (writeEn) begin  //store
        case(func3)
        3'b010: begin          // store word
            mem[addr    ] = storeVal[7:0];
            mem[addr + 1] = storeVal[15:8];
            mem[addr + 2] = storeVal[23:16];
            mem[addr + 3] = storeVal[31:24];
            end

        3'b001: begin          //store Half
            mem[addr    ] = storeVal[7:0];
            mem[addr + 1] = storeVal[15:8];
            end
        
        3'b000:                //store Half
            mem[addr    ] = storeVal[7:0];
        endcase
    end
end

always @(*) begin
    case(func3)
    3'b000: loadVal = {{24{mem[addr][7]}}, mem[addr]};    //LB
    3'b001: loadVal = {{12{mem[addr+1][7]}}, mem[addr + 1], mem[addr]};    //LH
    3'b010: loadVal = {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]};   //LW
    3'b100: loadVal = {24'd0, mem[addr]};    //LBU
    3'b101: loadVal = {12'd0, mem[addr]};    //LHU
    endcase   
    
end



endmodule






//https://stackoverflow.com/questions/4176556/how-to-sign-extend-a-number-in-verilog