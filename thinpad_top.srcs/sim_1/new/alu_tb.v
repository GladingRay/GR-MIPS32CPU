`timescale  1ns / 1ps
`include "inst_define.v"
module tb_ALU;

// ALU Parameters
parameter PERIOD  = 10;


// ALU Inputs
reg   [3:0]  alu_op                       = 0 ;
reg   [15:0]  op1                          = 0 ;
reg   [15:0]  op2                          = 0 ;

// ALU Outputs
wire  [31:0]  res                          ;


// initial
// begin
//     forever #(PERIOD/2)  clk=~clk;
// end

// initial
// begin
//     #(PERIOD*2) rst_n  =  1;
// end

ALU  u_ALU (
    .alu_op                 ( alu_op  [3:0]  ),
    .op1                     ( op1      [15:0] ),
    .op2                     ( op2      [15:0] ),

    .res                     ( res      [31:0] )
);

initial
begin
    #(PERIOD*2);
    alu_op = `OP_NOP;
    op1 = 16'h0123;
    op2 = 16'hffff;

    #(PERIOD*2);
    alu_op = `OP_ADD;
    op1 = 16'h0123;
    op2 = 16'hffff;

    #(PERIOD*2);
    alu_op = `OP_LUI;
    op1 = 16'h0123;
    op2 = 16'h4567;

    #(PERIOD*2);
    alu_op = `OP_SUB;
    op1 = 16'hf123;
    op2 = 16'h4567;
    #(PERIOD*2);
    $finish;
end

endmodule