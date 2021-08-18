`ifndef INST_DEFINE_V_
`define INST_DEFINE_V_

// op_code
`define ORI     6'b001101
`define LUI     6'b001111
`define SPECIAL 6'b000000
`define ADDI    6'b001000
`define MUL     6'b011100
`define ANDI    6'b001100
`define ADDIU   6'b001001
`define BNE     6'b000101
`define BEQ     6'b000100 
`define BLEZ    6'b000110 
`define BGTZ    6'b000111
`define J       6'b000010
`define JAL     6'b000011
`define LW      6'b100011
`define SW      6'b101011
`define LB      6'b100000
`define SB      6'b101000 
`define XORI    6'b001110


// funct
`define ADDU_FUNCT  6'b100001
`define AND_FUNCT   6'b100100
`define JR_FUNCT    6'b001000 
`define OR_FUNCT    6'b100101
`define SRLV_FUNCT  6'b000110
`define SLL_FUNCT   6'b000000 
`define SRL_FUNCT   6'b000010 
`define XOR_FUNCT   6'b100110 
`define SLT_FUNCT   6'b101010

// alu_op
`define OP_NOP 4'd0
`define OP_ADDU 4'd1
`define OP_LUI 4'd2
`define OP_OR 4'd4
`define OP_AND 4'd5
`define OP_XOR 4'd6
`define OP_RSHIFT 4'd7
`define OP_LSHIFT 4'd8
`define OP_MUL 4'd9
`define OP_SLT 4'd10

`endif 