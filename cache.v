module cache (
    input wire clk,
    input wire reset,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire write_en,
    input wire [2:0] func3,
    output reg [31:0] read_data,
    output reg hit,
    output reg busy
);

// Corrected structure
reg [0:0] valid [3:0][1:0];      // Single bit valid
reg [25:0] tags [3:0][1:0];      // 26-bit tags
reg [31:0] data [3:0][1:0];      // 32-bit data
reg [2:0] age [3:0][1:0];        // 3-bit age counter
reg [1:0] state;
reg replace_way;

// Corrected address mapping
wire [25:0] tag = addr[31:6];    // Tag bits
wire [1:0] set_index = addr[5:4]; // Set index bits
wire [3:0] block_offset = addr[3:0]; // Block offset

// Simplified validity checks
wire addr_valid = (addr[1:0] == 2'b00);  // Word alignment check
wire state_legal = (state < 2'b11);       // Valid states only

wire [31:0] mem_data;
wire mem_data_ready;
reg mem_write_en;

// Redefine state encoding to avoid illegal states
localparam IDLE = 2'b00;
localparam READ = 2'b01;
localparam WRITE = 2'b10;
localparam UPDATE = 2'b10;  // Changed to match WRITE to avoid illegal state

integer i, j;
initial begin
    for(i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 2; j = j + 1) begin
            valid[i][j] = 0;
            age[i][j] = 0;
        end
    end
    state = IDLE;
    busy = 0;
    hit = 0;
    mem_write_en = 0;
end

datamem main_memory(
    .clk(clk),
    .reset(reset),        // Added reset
    .writeEn(mem_write_en),
    .addr(addr),
    .func3(func3),
    .storeVal(write_data),
    .loadVal(mem_data),
    .data_ready(mem_data_ready)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        busy <= 0;
        hit <= 0;
        mem_write_en <= 0;
        read_data <= 32'h0;  // Explicitly reset read_data
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                valid[i][j] <= 0;
                tags[i][j] <= 0;
                data[i][j] <= 0;
                age[i][j] <= 0;
            end
        end
    end
    else begin
        // State validation
        if (!state_legal) begin
            $display("ERROR: Illegal state %d at time %0t", state, $time);
            state <= IDLE;
            busy <= 0;
        end

        case(state)
            IDLE: begin
                mem_write_en <= 0;
                busy <= 0;
                hit <= 0;  // Reset hit signal each cycle
                
                // Ensure that addr does not exceed memory bounds
                if (!addr_valid) begin
                    $display("ERROR: Invalid address %h at time %0t", addr, $time);
                    busy <= 0;
                    hit <= 0;
                end
                else begin
                    // Check both ways simultaneously
                    if (valid[set_index][0] && tags[set_index][0] == tag) begin
                        hit <= 1;
                        read_data <= data[set_index][0];
                        // Only update LRU on actual access
                        age[set_index][0] <= 3'b000;
                        if (valid[set_index][1]) begin
                            age[set_index][1] <= age[set_index][1] + 1;
                        end
                        
                        if (write_en) begin
                            data[set_index][0] <= write_data;
                            mem_write_en <= 1;
                            state <= WRITE;
                            busy <= 1;
                        end
                    end
                    else if (valid[set_index][1] && tags[set_index][1] == tag) begin
                        hit <= 1;
                        read_data <= data[set_index][1];
                        // Only update LRU on actual access
                        age[set_index][1] <= 3'b000;
                        if (valid[set_index][0]) begin
                            age[set_index][0] <= age[set_index][0] + 1;
                        end
                        
                        if (write_en) begin
                            data[set_index][1] <= write_data;
                            mem_write_en <= 1;
                            state <= WRITE;
                            busy <= 1;
                        end
                    end
                    else begin
                        // Cache miss
                        hit <= 0;
                        busy <= 1;
                        state <= READ;
                        // Determine replacement way
                        if (!valid[set_index][0]) replace_way <= 1'b0;
                        else if (!valid[set_index][1]) replace_way <= 1'b1;
                        else replace_way <= (age[set_index][0] > age[set_index][1]) ? 1'b0 : 1'b1;
                    end
                end
            end

            READ: begin
                busy <= 1;
                if (mem_data_ready) begin
                    // Cache line replacement
                    valid[set_index][replace_way] <= 1'b1;
                    tags[set_index][replace_way] <= tag;
                    data[set_index][replace_way] <= mem_data;
                    read_data <= mem_data;
                    
                    // Reset age counter for new entry
                    age[set_index][replace_way] <= 3'b000;
                    // Update other way's age if valid
                    if (valid[set_index][~replace_way]) begin
                        age[set_index][~replace_way] <= age[set_index][~replace_way] + 1;
                    end

                    state <= IDLE;
                    busy <= 0;
                    hit <= 1;
                end
            end

            WRITE: begin
                if (mem_data_ready) begin
                    state <= IDLE;
                    busy <= 0;
                    mem_write_en <= 0;
                end
                else begin
                    busy <= 1;
                end
            end

            UPDATE: begin
                mem_write_en <= 0;
                
                // Simplified replacement policy
                replace_way <= (!valid[set_index][0]) ? 1'b0 :
                             (!valid[set_index][1]) ? 1'b1 :
                             (age[set_index][0] > age[set_index][1]) ? 1'b0 : 1'b1;

                valid[set_index][replace_way] <= 1'b1;
                tags[set_index][replace_way] <= tag;
                data[set_index][replace_way] <= mem_data;
                read_data <= mem_data;

                // Reset age for replaced way
                age[set_index][replace_way] <= 3'b000;
                // Increment age for other way if valid
                age[set_index][~replace_way] <= valid[set_index][~replace_way] ? 
                    age[set_index][~replace_way] + 3'b001 : 3'b000;

                busy <= 0;
                hit <= 1;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
                busy <= 0;
                hit <= 0;
                mem_write_en <= 0;
            end
        endcase
    end
end

// Correct tag comparison logic
always @(posedge clk) begin
    if (write_en) begin
        // ...existing code...
    end else begin
        // Ensure tag comparison includes all relevant bits
        if (valid[set_index][replace_way] && (tags[set_index][replace_way] == tag)) begin
            hit = 1;
            read_data = data[set_index][replace_way];
            // Update LRU
            // ...existing LRU update code...
        end else begin
            hit = 0;
            // ...existing code for miss...
        end
    end
end

// Improve LRU Updates on Cache Hit
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // ...existing reset code...
    end
    else begin
        // ...existing state machine...
        case(state)
            IDLE: begin
                // ...existing IDLE state code...
                if (hit) begin
                    // Update LRU counters correctly based on which way was hit
                    if (replace_way == 0) begin
                        age[set_index][0] <= 3'b000;
                        age[set_index][1] <= age[set_index][1] + 1;
                    end
                    else begin
                        age[set_index][1] <= 3'b000;
                        age[set_index][0] <= age[set_index][0] + 1;
                    end
                end
                // ...existing code...
            end

            READ: begin
                // ...existing READ state code...
                if (mem_data_ready) begin
                    // ...existing replacement logic...
                    // Reset LRU counter for the replaced way
                    age[set_index][replace_way] <= 3'b000;
                    // Increment LRU counter for the other way
                    age[set_index][~replace_way] <= age[set_index][~replace_way] + 1;
                end
                // ...existing code...
            end

            // Remove or correct the UPDATE state if it's redundant
            // ...existing code...
        endcase
    end
end

// Correct Tag Comparison Logic
always @(posedge clk) begin
    if (write_en) begin
        // ...existing write logic...
    end else begin
        // Ensure tag comparison includes all relevant bits and both ways
        if (valid[set_index][0] && (tags[set_index][0] == tag)) begin
            hit = 1;
            read_data = data[set_index][0];
            replace_way = 0;
            // Update LRU
            age[set_index][0] <= 3'b000;
            age[set_index][1] <= age[set_index][1] + 1;
        end
        else if (valid[set_index][1] && (tags[set_index][1] == tag)) begin
            hit = 1;
            read_data = data[set_index][1];
            replace_way = 1;
            // Update LRU
            age[set_index][1] <= 3'b000;
            age[set_index][0] <= age[set_index][0] + 1;
        end
        else begin
            hit = 0;
            // ...existing miss handling code...
        end
    end
end

endmodule