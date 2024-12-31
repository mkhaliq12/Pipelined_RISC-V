`timescale 1ns/1ps

module cache_tb;

    reg clk;
    reg reset;
    reg [31:0] addr;
    reg [31:0] write_data;
    reg write_en;
    reg [2:0] func3;
    wire [31:0] read_data;
    wire hit;
    wire busy;

    integer timeout;
    integer error_count;
    integer i, j;
    integer addr_temp, data_temp;
    integer random_seed;
    reg [1:0] pre_state;
    reg pre_hit;
    reg [31:0] test_vectors[0:31];

    cache dut(
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .write_data(write_data),
        .write_en(write_en),
        .func3(func3),
        .read_data(read_data),
        .hit(hit),
        .busy(busy)
    );

    wire [25:0] tag = addr[31:6];  
    wire [1:0] set_index = addr[5:4];  

    localparam IDLE = 2'b00;
    localparam MEMOP = 2'b01;
    localparam UPDATE = 2'b10;

    task print_cache_state;
        integer i;
        begin
            $display("\nCache State at time %0t:", $time);
            for (i = 0; i < 4; i = i + 1) begin
                $display("Set %0d: Valid[0]=%b Tag[0]=%h Data[0]=%h Age[0]=%d", 
                        i, dut.valid[i][0], dut.tags[i][0], dut.data[i][0], dut.age[i][0]);
                $display("      Valid[1]=%b Tag[1]=%h Data[1]=%h Age[1]=%d", 
                        dut.valid[i][1], dut.tags[i][1], dut.data[i][1], dut.age[i][1]);
            end
            $display("");
        end
    endtask

    initial begin
        random_seed = 32'h1234_5678;  // Fixed seed for reproducibility
        for(i = 0; i < 32; i = i + 1) begin
            test_vectors[i] = $random(random_seed);
        end
    end

    reg [31:0] expected_data;

    always @(posedge clk) begin
        if (write_en) begin
            expected_data <= write_data;
        end
    end

    task do_memory_op;
        input [31:0] address;
        input [31:0] data;
        input write;
        input [2:0] size;
        begin

            pre_state = dut.state;
            pre_hit = hit;

            @(posedge clk);
            addr = address;
            write_data = data;
            write_en = write;
            func3 = size;

            repeat(2) @(posedge clk);

            timeout = 1;
            while((busy || (!hit && !write)) && timeout < 20) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if(timeout == 20) begin
                $display("ERROR: Operation timeout at time %0t", $time);
                $display("Pre-op state: %d, Pre-hit: %b", pre_state, pre_hit);
                $display("Current state: %d, Hit: %b", dut.state, hit);
                error_count = error_count + 1;
                $finish;
            end
            else begin
                $display("Operation complete after %0d cycles", timeout);
                $display("Hit: %b, Read Data: %h", hit, read_data);
                if(!write && hit) begin
                    case(size)
                        3'b000: begin // Byte
                            if((read_data & 32'h000000FF) !== (expected_data & 32'h000000FF)) begin
                                $display("ERROR: Byte read mismatch. Expected %h, got %h", 
                                    expected_data & 32'h000000FF, read_data & 32'h000000FF);
                                error_count = error_count + 1;
                            end
                        end
                        3'b001: begin // Half word
                            if((read_data & 32'h0000FFFF) !== (expected_data & 32'h0000FFFF)) begin
                                $display("ERROR: Half word read mismatch. Expected %h, got %h", 
                                    expected_data & 32'h0000FFFF, read_data & 32'h0000FFFF);
                                error_count = error_count + 1;
                            end
                        end
                        default: begin 
                            if(read_data !== expected_data) begin
                                $display("ERROR: Word read mismatch. Expected %h, got %h", 
                                    expected_data, read_data);
                                error_count = error_count + 1;
                            end
                        end
                    endcase
                end
                print_cache_state();
            end

            @(posedge clk);
        end
    endtask

    initial begin
        expected_data = 32'h0;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("cache_test.vcd");
        $dumpvars(0, cache_tb);

        error_count = 0;
        reset = 1;
        addr = 0;
        write_data = 0;
        write_en = 0;
        func3 = 3'b010;

        repeat(10) @(posedge clk);  
        reset = 0;
        repeat(5) @(posedge clk);   

        for(i = 0; i < 32; i = i + 1) begin
            test_vectors[i] = $random(random_seed);  
        end

        $display("\n=== PHASE 1: Sequential Set Testing ===");

        for(i = 0; i < 4; i = i + 1) begin

            addr_temp = (i << 4);  
            $display("\nTesting Set %0d", i);

            do_memory_op(addr_temp, 32'h11111111 + i, 1, 3'b010);

            do_memory_op(addr_temp, 32'h11111111 + i, 0, 3'b010);

            do_memory_op(addr_temp + 32'h1000, 32'h22222222 + i, 1, 3'b010);

            do_memory_op(addr_temp + 32'h1000, 32'h22222222 + i, 0, 3'b010);

            do_memory_op(addr_temp, 32'h11111111 + i, 0, 3'b010);
        end

        $display("\n=== PHASE 2: LRU Testing ===");

        for(i = 0; i < 4; i = i + 1) begin
            addr_temp = (i << 4);
            $display("\nTesting LRU for Set %0d", i);

            do_memory_op(addr_temp, 32'hAAAA0000 + i, 1, 3'b010);
            do_memory_op(addr_temp + 32'h1000, 32'hBBBB0000 + i, 1, 3'b010);

            do_memory_op(addr_temp, 32'hAAAA0000 + i, 0, 3'b010);

            do_memory_op(addr_temp + 32'h2000, 32'hCCCC0000 + i, 1, 3'b010);

            do_memory_op(addr_temp, 32'hAAAA0000 + i, 0, 3'b010);

            do_memory_op(addr_temp + 32'h2000, 32'hCCCC0000 + i, 0, 3'b010);
        end

        $display("\n=== PHASE 3: Tag Exhaustion Test ===");

        for(i = 0; i < 8; i = i + 1) begin
            addr_temp = i << 8;  
            data_temp = 32'hAA000000 + (i << 16);
            do_memory_op(addr_temp, data_temp, 1, 3'b010);
            do_memory_op(addr_temp, data_temp, 0, 3'b010);
        end

        $display("\n=== PHASE 4: Edge Cases ===");

        do_memory_op(32'hFFC, 32'hEEEEEEEE, 1, 3'b010);
        do_memory_op(32'hFFC, 32'hEEEEEEEE, 0, 3'b010);

        do_memory_op(32'h100, 32'h12345678, 1, 3'b000); // Byte
        do_memory_op(32'h100, 32'h12345678, 0, 3'b000);
        do_memory_op(32'h104, 32'h90ABCDEF, 1, 3'b001); // Half word
        do_memory_op(32'h104, 32'h90ABCDEF, 0, 3'b001);

        $display("\n=== Test Summary ===");
        $display("Total Errors: %0d", error_count);
        $finish;
    end

    always @(posedge clk) begin
        if(!reset) begin
            if(hit === 1'bx || busy === 1'bx || dut.state === 2'bxx) begin
                $display("ERROR: Undefined signals at time %0t", $time);
                $display("State: %b, Hit: %b, Busy: %b", dut.state, hit, busy);
                error_count = error_count + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (hit && !write_en) begin
            if (read_data === 32'hxxxxxxxx) begin
                $display("ERROR: Undefined read data at time %0t", $time);
                $display("Address: %h, Expected: %h", addr, expected_data);
                error_count = error_count + 1;
            end
        end
    end
endmodule
