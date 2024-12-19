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

// Cache structure (2-way set associative)
reg [0:0] valid [3:0][1:0];      // 4 sets, 2 ways, 1 valid bit each
reg [25:0] tags [3:0][1:0];      // 26-bit tags
reg [31:0] data [3:0][1:0];      // 32-bit data
reg [2:0] age [3:0][1:0];        // LRU counter (3-bit)

// State machine
reg [1:0] state;
localparam IDLE = 2'b00;
localparam READ = 2'b01;
localparam WRITE = 2'b10;

// Cache line selection
reg replace_way;
wire [25:0] tag = addr[31:6];    // Tag bits
wire [1:0] set_index = addr[5:4]; // Set index bits
wire addr_valid = (addr[1:0] == 2'b00);  // Word alignment check

// Memory interface
wire [31:0] mem_data;
wire mem_data_ready;
reg mem_write_en;

// Initial state
integer i, j;
initial begin
    for(i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 2; j = j + 1) begin
            valid[i][j] = 0;
            tags[i][j] = 0;
            data[i][j] = 0;
            age[i][j] = 0;
        end
    end
    state = IDLE;
    busy = 0;
    hit = 0;
    mem_write_en = 0;
    read_data = 0;
end

// Memory interface
datamem main_memory(
    .clk(clk),
    .reset(reset),
    .writeEn(mem_write_en),
    .addr(addr),
    .func3(func3),
    .storeVal(write_data),
    .loadVal(mem_data),
    .data_ready(mem_data_ready)
);

// Main control logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        busy <= 0;
        hit <= 0;
        mem_write_en <= 0;
        read_data <= 0;
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
        case(state)
            IDLE: begin
                mem_write_en <= 0;
                busy <= 0;
                hit <= 0;

                if (addr_valid) begin
                    // Check both ways for hit
                    if (valid[set_index][0] && tags[set_index][0] == tag) begin
                        hit <= 1;
                        read_data <= data[set_index][0];
                        age[set_index][0] <= 0;
                        age[set_index][1] <= age[set_index][1] + 1;
                        
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
                        age[set_index][1] <= 0;
                        age[set_index][0] <= age[set_index][0] + 1;
                        
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
                        // Select replacement way
                        replace_way <= (!valid[set_index][0]) ? 1'b0 :
                                     (!valid[set_index][1]) ? 1'b1 :
                                     (age[set_index][0] > age[set_index][1]) ? 1'b0 : 1'b1;
                    end
                end
            end

            READ: begin
                if (mem_data_ready) begin
                    valid[set_index][replace_way] <= 1'b1;
                    tags[set_index][replace_way] <= tag;
                    data[set_index][replace_way] <= mem_data;
                    read_data <= mem_data;
                    
                    age[set_index][replace_way] <= 0;
                    age[set_index][~replace_way] <= age[set_index][~replace_way] + 1;

                    state <= IDLE;
                    busy <= 0;
                    hit <= 1;
                end
                else begin
                    busy <= 1;
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

            default: begin
                state <= IDLE;
                busy <= 0;
                hit <= 0;
                mem_write_en <= 0;
            end
        endcase
    end
end

endmodule