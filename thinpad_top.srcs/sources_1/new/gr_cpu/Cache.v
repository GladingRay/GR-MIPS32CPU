/*
    一路1KB(2^10) 行大小4B(2^2)
    offset 2bit
    index  10-2 = 8bit
    tag    32-10 = 22bit
*/
module Cache (
    input wire clk,
    input wire reset,
    input wire [31:0] read_virtual_addr,

    output wire is_hit,
    output wire [31:0] cache_hit_data,

    input wire is_write_cache,
    input wire [31:0] write_virtual_addr,
    input wire [31:0] cache_write_data


);
    reg v_table [255:0];

    wire [7:0] write_index;
    wire [7:0] read_index;
    wire [1:0] offset;
    wire [21:0] write_tag;
    wire [21:0] tag;
    assign offset = read_virtual_addr[1:0];
    assign write_index = write_virtual_addr[9:2];
    assign read_index = read_virtual_addr[9:2];
    assign tag = read_virtual_addr[31:10];
    assign write_tag = write_virtual_addr[31:10];
    
    integer i;
    always @(posedge clk) begin
        if(reset)begin
            for (i = 0;i<256 ;i = i+1 ) begin
                v_table[i] <= 0;
            end            
        end
        else begin
            v_table[write_index] <= 1;
        end
    end
    
    
    wire [21:0] target_tag;
    // tag and valid table
    tag_v_ram tag_table
        (
            .clka           (clk),
            .wea            (is_write_cache),
            .addra          (write_index),
            .dina           (write_tag),
            .clkb           (clk),
            .addrb          (read_index),
            .doutb          (target_tag)
        );
    wire [31:0] target_data;
    // gen is hit signal
    cache_data_ram cache_data_table
        (
            .clka           (clk),
            .wea            (is_write_cache),
            .addra          (write_index),
            .dina           (cache_write_data),
            .clkb           (clk),
            .addrb          (read_index),
            .doutb          (target_data)
        );

    assign cache_hit_data = target_data;
    assign is_hit = (target_tag == tag) & v_table[read_index];
    
endmodule