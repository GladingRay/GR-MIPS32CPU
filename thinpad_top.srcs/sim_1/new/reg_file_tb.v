`timescale  1ns / 1ps

module tb_Reg_file;

// Reg_file Parameters
parameter PERIOD  = 10;


// Reg_file Inputs
reg   clk                                  = 0 ;
reg   [5:0]  read_reg_addr1                = 0 ;
reg   [5:0]  read_reg_addr2                = 0 ;
reg   write_reg_en                         = 0 ;
reg   [5:0]  write_reg_addr                = 0 ;
reg   [31:0]  write_reg_data               = 0 ;

// Reg_file Outputs
wire  [31:0]  read_reg_data1               ;
wire  [31:0]  read_reg_data2               ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

// initial
// begin
//     #(PERIOD*2) rst_n  =  1;
// end

Reg_file  u_Reg_file (
    .clk                     ( clk                    ),
    .read_reg_addr1          ( read_reg_addr1  [5:0]  ),
    .read_reg_addr2          ( read_reg_addr2  [5:0]  ),
    .write_reg_en            ( write_reg_en           ),
    .write_reg_addr          ( write_reg_addr  [5:0]  ),
    .write_reg_data          ( write_reg_data  [31:0] ),

    .read_reg_data1          ( read_reg_data1  [31:0] ),
    .read_reg_data2          ( read_reg_data2  [31:0] )
);

initial
begin
    # (PERIOD*2);
    read_reg_addr1 = 6'd0;
    read_reg_addr2 = 6'd0;
    write_reg_en = 0;
    write_reg_addr = 6'd3;
    write_reg_data = 32'h12345678;
    # (PERIOD*2);
    read_reg_addr1 = 6'd0;
    read_reg_addr2 = 6'd0;
    write_reg_en = 1;
    write_reg_addr = 6'd3;
    write_reg_data = 32'h12345678;
    # (PERIOD*2);
    read_reg_addr1 = 6'd0;
    read_reg_addr2 = 6'd0;
    write_reg_en = 1;
    write_reg_addr = 6'd1;
    write_reg_data = 32'hffffffff;
    # (PERIOD*2);
    read_reg_addr1 = 6'd1;
    read_reg_addr2 = 6'd3;
    write_reg_en = 0;
    write_reg_addr = 6'd3;
    write_reg_data = 32'h12345678;
    # (PERIOD*2);
    $finish;
end

endmodule