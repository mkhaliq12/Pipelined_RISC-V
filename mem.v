


///////////////////////////////////////////////////////////







/////////////////////////////////////////////////////




module programMem(
    input wire[31:0] address,
    output reg[31:0] ins
);

reg[7:0] ROM[0:30];

always @(*) begin   //little endian
    ROM[0] = 8'h00; //lsb
    ROM[1] = 8'h10; 
    ROM[2] = 8'h20;  
    ROM[3] = 8'h30; //msb
    ROM[4] = 8'h40;  
    ROM[5] = 8'h50; 
    ROM[6] = 8'h60; 
    ROM[7] = 8'h70; 
    ROM[8] = 8'h80;  
    ROM[9] = 8'h90; 
    ROM[10] = 8'ha0; 
    ROM[11] = 8'hb0; 
    ROM[12] = 8'hc0; 
    ROM[13] = 8'hd0; 
    ROM[14] = 8'he0;  
    ROM[15] = 8'hf0;
    ins = {ROM[address +3], ROM[address + 2], ROM[address + 1], ROM[address]};
end
endmodule




/////////////////////////////////7

