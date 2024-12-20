`timescale 1ns/1ps

module riscV_tb;
    reg clk;
    reg reset;
    wire[18:0] out;
    
    // Test control
    integer test_phase;
    integer cycle_count;
    integer error_count;
    
    // Processor instance
    riscV riscV1(
        .clk(clk),
        .reset(reset),
        .out(out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #30 clk = ~clk;
    end
    
    // Monitor cache behavior
    wire cache_hit = riscV1.cache_hit;
    wire cache_busy = riscV1.cache_Busy;
    wire [31:0] current_instr = riscV1.instr;
    wire [31:0] pc_value = riscV1.count;
    
    // Instruction decoder for readable output
    reg [63:0] instr_string;
    always @(*) begin
        case(current_instr[6:0])
            7'b0110011: instr_string = "R-type  ";
            7'b0010011: instr_string = "I-ALU   ";
            7'b0000011: instr_string = "I-LOAD  ";
            7'b0100011: instr_string = "STORE   ";
            7'b1100011: instr_string = "BRANCH  ";
            7'b1101111: instr_string = "JAL     ";
            7'b1100111: instr_string = "JALR    ";
            7'b0110111: instr_string = "LUI     ";
            7'b0010111: instr_string = "AUIPC   ";
            default:    instr_string = "UNKNOWN ";
        endcase
    end

    // Test sequence
    initial begin
        // Setup test environment
        $display("\n=== RISC-V Processor Test Starting ===");
        $display("Time  Phase  PC     Instruction  Cache  Output");
        $display("--------------------------------------------");
        
        test_phase = 0;
        cycle_count = 0;
        error_count = 0;
        reset = 1;
        
        // Reset phase
        #50 reset = 0;
        test_phase = 1;

        // Main test loop
        repeat(500) @(posedge clk) begin
            cycle_count = cycle_count + 1;
            
            // Print detailed status every cycle
            $display("%4d: %2d     0x%h %s %s %d", 
                    cycle_count,
                    test_phase,
                    pc_value,
                    instr_string,
                    cache_busy ? "MISS" : "HIT ",
                    out);

            // Check for stalls
            if (cache_busy) begin
                $display("      [Cache Miss] Processor stalled...");
            end

            // Error checking
            if (current_instr === 32'hxxxxxxxx) begin
                $display("ERROR: Invalid instruction detected!");
                error_count = error_count + 1;
            end
            
            // Phase transitions based on program counter
            case(pc_value)
                32'h0:     test_phase = 1;  // Program start
                32'h10:    test_phase = 2;  // After initialization
                32'h20:    test_phase = 3;  // Main computation
                32'h30:    test_phase = 4;  // Final phase
            endcase
        end

        // Test summary
        $display("\n=== Test Complete ===");
        $display("Total Cycles: %d", cycle_count);
        $display("Cache Hits: %d", riscV1.datacache.hit_count);
        $display("Cache Misses: %d", cycle_count - riscV1.datacache.hit_count);
        $display("Final Output: %d", out);
        $display("Errors: %d", error_count);
        
        if (error_count == 0)
            $display("\nTEST PASSED ✓");
        else
            $display("\nTEST FAILED ✗");
            
        $finish;
    end

    // Performance monitoring
    reg [31:0] instr_count = 0;
    real ipc;
    
    always @(posedge clk) begin
        if (!reset && !cache_busy) begin
            instr_count <= instr_count + 1;
            ipc <= instr_count / cycle_count;
        end
    end

endmodule
