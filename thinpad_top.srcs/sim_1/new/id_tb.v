`timescale  1ns / 1ps

module tb_Inst_decoder;

// Inst_decoder Parameters
parameter PERIOD  = 10;


// Inst_decoder Inputs
reg   clk                                  = 1 ;
reg   [31:0]  pc                           = 0 ;
reg   [31:0]  inst                         = 0 ;
reg   stall_id                             = 0 ;
reg   [31:0]  pre_alu_res                  = 0 ;
reg   [31:0]  read_ram_data                = 0 ;
reg   [31:0]  read_reg_data1               = 0 ;
reg   [31:0]  read_reg_data2               = 0 ;
reg   rst_n = 1;

// Inst_decoder Outputs
wire  is_branch                            ;    
wire  [31:0]  target_pc                    ;    
wire  read_ram_en                          ;    
wire  [31:0]  read_ram_addr                ;    
wire  [3:0]  read_ram_be                   ;    
wire  write_ram_en                         ;    
wire  [3:0]  write_ram_be                  ;
wire  [31:0]  write_ram_addr               ;
wire  [4:0]  read_reg_addr1                ;
wire  [4:0]  read_reg_addr2                ;
wire  write_reg_en                         ;
wire  [4:0]  write_reg_addr                ;
wire  [3:0]  alu_op                        ;
wire  [31:0]  op1                          ;
wire  [31:0]  op2                          ;

initial
begin
    #(PERIOD) ;
    pc = 32'h80000000;
    inst = 32'h0c123456;    // jal 0cxxxxxx
    stall_id = 0;
    pre_alu_res = 32'h11111111;
    read_ram_data = 32'h11111111;
    read_reg_data1 = 32'h11111111;
    read_reg_data2 = 32'h11111111;
    #(PERIOD) ;
    pc = 32'h80000004;
    inst = 32'h00200008;    // jr 
    stall_id = 0;
    pre_alu_res = 32'h22222222;
    read_ram_data = 32'h22222222;
    read_reg_data1 = 32'h22222222;
    read_reg_data2 = 32'h22222222;
    #(PERIOD) ;
    pc = 32'h80000008;
    inst = 32'h08123456;   // j
    stall_id = 0;
    pre_alu_res = 32'h33333333;
    read_ram_data = 32'h33333333;
    read_reg_data1 = 32'h33333333;
    read_reg_data2 = 32'h33333333;
    
    #(PERIOD) ;
    pc = 32'h8000000c;
    inst = 32'h18000000;  // bltz
    stall_id = 0;
    pre_alu_res = 32'h44444444;
    read_ram_data = 32'h44444444;
    read_reg_data1 = 32'h84444444;
    read_reg_data2 = 32'h84444444;
    
    #(PERIOD) ;
    pc = 32'h80000010;
    inst = 32'h1c400000;  // bgtz
    stall_id = 0;
    pre_alu_res = 32'h11111111;
    read_ram_data = 32'h22222222;
    read_reg_data1 = 32'h33333333;
    read_reg_data2 = 32'h44444444;

    #(PERIOD) ;
    pc = 32'h80000010;
    inst = 32'h10000000;   // beq
    stall_id = 0;
    pre_alu_res = 32'h11111111;
    read_ram_data = 32'h22222222;
    read_reg_data1 = 32'h33333333;
    read_reg_data2 = 32'h44444444;
    
    #(PERIOD) ;
    $finish;
end

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD) rst_n  =  0;
end

Inst_decoder  u_Inst_decoder (
    .clk                     ( clk                    ),
    .reset                   ( rst_n                  ),
    .pc                      ( pc              [31:0] ),
    .inst                    ( inst            [31:0] ),
    .stall_id                ( stall_id               ),
    .pre_alu_res             ( pre_alu_res     [31:0] ),
    .read_ram_data           ( read_ram_data   [31:0] ),
    .read_reg_data1          ( read_reg_data1  [31:0] ),
    .read_reg_data2          ( read_reg_data2  [31:0] ),

    .is_branch               ( is_branch              ),
    .target_pc               ( target_pc       [31:0] ),
    .read_ram_en             ( read_ram_en            ),
    .read_ram_addr           ( read_ram_addr   [31:0] ),
    .read_ram_be             ( read_ram_be     [3:0]  ),
    .write_ram_en            ( write_ram_en           ),
    .write_ram_be            ( write_ram_be    [3:0]  ),
    .write_ram_addr          ( write_ram_addr  [31:0] ),
    .read_reg_addr1          ( read_reg_addr1  [4:0]  ),
    .read_reg_addr2          ( read_reg_addr2  [4:0]  ),
    .write_reg_en            ( write_reg_en           ),
    .write_reg_addr          ( write_reg_addr  [4:0]  ),
    .alu_op                  ( alu_op          [3:0]  ),
    .op1                     ( op1             [31:0] ),
    .op2                     ( op2             [31:0] )
);



endmodule