`include "inst_define.v"
module ALU (
    input wire [3:0] alu_op,
    input wire [31:0] op1,
    input wire [31:0] op2,

    output reg [31:0] res
);
    wire [31:0] add_res;
    assign add_res = op1 + op2;

    wire [31:0] nop_res;
    assign nop_res = op1;

    wire [31:0] lui_res;
    assign lui_res = {op2[15:0], 16'd0};

    wire [31:0] or_res;
    assign or_res = op1 | op2;

    wire [31:0] xor_res;
    assign xor_res = op1 ^ op2;

    wire [31:0] lshift_res;
    assign lshift_res = op1 << op2;

    wire [31:0] rshift_res;
    assign rshift_res = op1 >> op2;

    wire [31:0] mul_res;
    assign mul_res = op1 * op2;

    always @(*) begin
        case (alu_op)
            `OP_NOP : res = nop_res;
            `OP_ADDU : res = add_res;
            `OP_LUI : res = lui_res;
            `OP_OR : res = or_res;
            `OP_XOR : res = xor_res;
            `OP_LSHIFT : res = lshift_res;
            `OP_RSHIFT : res = rshift_res;
            `OP_MUL : res = mul_res;
            default : res = nop_res;
        endcase
    end

endmodule