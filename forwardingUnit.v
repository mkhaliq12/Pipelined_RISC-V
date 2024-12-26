module forwardingUnit (
    input wire [4:0] ID_EX_RegisterRs1,
    input wire [4:0] ID_EX_RegisterRs2,
    input wire [4:0] EX_MEM_RegisterRd,
    input wire [4:0] MEM_WB_RegisterRd,
    input wire EX_MEM_RegWrite,
    input wire MEM_WB_RegWrite,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // EX Hazard for Rs1
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'b00000) && 
            (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b10;
        end
        // EX Hazard for Rs2
        else if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'b00000) && 
            (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b10;
        end

        // MEM Hazard for Rs1
        else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 5'b00000) &&
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'b00000) && 
              (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b01;
        end
        // MEM Hazard for Rs2
        else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 5'b00000) &&
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'b00000) && 
              (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b01;
        end
        // Default: No forwarding 
        else begin
            ForwardA = 2'b00;
            ForwardB = 2'b00;
        end
    end

endmodule
