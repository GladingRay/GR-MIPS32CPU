`timescale  1ns / 1ps

module tb_Cache;

// Cache Parameters
parameter PERIOD  = 10;


// Cache Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [31:0]  read_virtual_addr            = 0 ;
reg   is_write_cache                       = 0 ;
reg   [31:0]  write_virtual_addr           = 0 ;
reg   [31:0]  cache_write_data             = 0 ;

// Cache Outputs
wire  is_hit                               ;
wire  [31:0]  cache_hit_data               ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) reset  =  1;
    #(PERIOD*2) reset  =  0;
end

Cache  u_Cache (
    .clk                     ( clk                        ),
    .reset                   ( reset                      ),
    .read_virtual_addr       ( read_virtual_addr   [31:0] ),
    .is_write_cache          ( is_write_cache             ),
    .write_virtual_addr      ( write_virtual_addr  [31:0] ),
    .cache_write_data        ( cache_write_data    [31:0] ),

    .is_hit                  ( is_hit                     ),
    .cache_hit_data          ( cache_hit_data      [31:0] )
);

initial
begin
    #(PERIOD*8);
    is_write_cache = 0;
    read_virtual_addr = 32'h80000000;
    write_virtual_addr = 32'h80000000;
    cache_write_data = 32'h34000000;
    #(PERIOD*1);
    is_write_cache = 1;
    read_virtual_addr = 32'h80000004;
    write_virtual_addr = 32'h80000004;
    cache_write_data = 32'h34000000;
    #(PERIOD*1);

    is_write_cache = 0;
    read_virtual_addr = 32'h80000008;
    write_virtual_addr = 32'h80000004;
    cache_write_data = 32'h34000000;
    #(PERIOD*1);
    is_write_cache = 0;
    read_virtual_addr = 32'h80000004;
    write_virtual_addr = 32'h80000004;
    cache_write_data = 32'h34000000;
    #(PERIOD*1);

    $finish;
end

endmodule