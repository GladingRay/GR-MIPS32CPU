`ifndef INST_DEFINE_V_
`define INST_DEFINE_V_

// op_code
`define ORI     6'b001101
`define LUI     6'b001100
`define ADDU    6'b000000
`define BNE     6'b000101
`define LW      6'b100011
`define SW      6'b101011

// funct
`define ADDU_FUNCT 6'b100001

// alu_op
`define OP_NOP 4'd0
`define OP_ADDU 4'd1
`define OP_LUI 4'd2
`define OP_SUBU 4'd3

`endif 