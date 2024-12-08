module programMem(
    input wire[31:0] address,
    output reg[31:0] ins
);

reg[7:0] ROM[0:46];

always @(*) begin   //little endian
    ROM[0] = 8'h93; //lsb
    ROM[1] = 8'h02; 
    ROM[2] = 8'h00;  
    ROM[3] = 8'h00; //msb
    ROM[4] = 8'h13;  
    ROM[5] = 8'h03; 
    ROM[6] = 8'h00; 
    ROM[7] = 8'h00; 
    ROM[8] = 8'h93;  
    ROM[9] = 8'h03; 
    ROM[10] = 8'h10; 
    ROM[11] = 8'h00; 
    ROM[12] = 8'h13; 
    ROM[13] = 8'h0E; 
    ROM[14] = 8'hE0;  
    ROM[15] = 8'h02;
    ROM[16] = 8'hB3; //lsb
    ROM[17] = 8'h03; 
    ROM[18] = 8'h73;  
    ROM[19] = 8'h00; //msb
    ROM[20] = 8'h33;  
    ROM[21] = 8'h03; 
    ROM[22] = 8'h73; 
    ROM[23] = 8'h00; 
    ROM[24] = 8'hB3;  
    ROM[25] = 8'h03; 
    ROM[26] = 8'h73; 
    ROM[27] = 8'h40; 
    ROM[28] = 8'h33; 
    ROM[29] = 8'h03; 
    ROM[30] = 8'h73; 
    ROM[31] = 8'h40; 
    ROM[32] = 8'h93; 
    ROM[33] = 8'h0E; 
    ROM[34] = 8'h03; 
    ROM[35] = 8'h00; 
    ROM[36] = 8'h93; 
    ROM[37] = 8'h82; 
    ROM[38] = 8'h12;  
    ROM[39] = 8'h00; 
    ROM[40] = 8'hE3; 
    ROM[41] = 8'hC4; 
    ROM[42] = 8'hC2; 
    ROM[43] = 8'hFF; 
    ROM[44] = 8'h6F; 
    ROM[45] = 8'hF0; 
    ROM[46] = 8'h5F; 
    ROM[47] = 8'hFD; 

    ins = {ROM[address +3], ROM[address + 2], ROM[address + 1], ROM[address]};
end

endmodule