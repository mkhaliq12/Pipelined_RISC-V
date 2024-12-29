module forwardingUnit (
    input wire [4:0] dec_ex_rs1_ad,
    input wire [4:0] dec_ex_rs2_ad,
    input wire [4:0] ex_mem_rd_ad,
    input wire [4:0] mem_wb_rdEn,
    input wire ex_mem_rdEn,
    input wire mem_wb_rdEn,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // EX Hazard for Rs1            3rd to 3rd             
        if (ex_mem_rdEn && (ex_mem_rd_ad != 5'b00000) && 
            (ex_mem_rd_ad == dec_ex_rs1_ad)) begin
            ForwardA = 2'b10;
        end
        // EX Hazard for Rs2
        else if (ex_mem_rdEn && (ex_mem_rd_ad != 5'b00000) && 
            (ex_mem_rd_ad == dec_ex_rs2_ad)) begin
            ForwardB = 2'b10;
        end

        // MEM Hazard for Rs1           4th to 3rd
        else if (mem_wb_rdEn && (mem_wb_rdEn != 5'b00000) &&
            !(ex_mem_rdEn && (ex_mem_rd_ad != 5'b00000) && 
              (ex_mem_rd_ad == dec_ex_rs1_ad)) &&
            (mem_wb_rdEn == dec_ex_rs1_ad)) begin
            ForwardA = 2'b01;
        end
        // MEM Hazard for Rs2
        else if (mem_wb_rdEn && (mem_wb_rdEn != 5'b00000) &&
            !(ex_mem_rdEn && (ex_mem_rd_ad != 5'b00000) && 
              (ex_mem_rd_ad == dec_ex_rs2_ad)) &&
            (mem_wb_rdEn == dec_ex_rs2_ad)) begin
            ForwardB = 2'b01;
        end
        // Default: No forwarding 
        else begin
            ForwardA = 2'b00;
            ForwardB = 2'b00;
        end
    end

endmodule
