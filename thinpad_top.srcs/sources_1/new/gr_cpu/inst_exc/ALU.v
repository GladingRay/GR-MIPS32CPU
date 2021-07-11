`include "inst_define.v"
module ALU (
    input wire [3:0] alu_op,
    input wire [15:0] op1,
    input wire [15:0] op2,

    output reg [31:0] res
);
    wire [31:0] add_res;
    assign add_res = op1 + ( alu_op == `OP_SUBU ?
                            ~op2 : op2 );
    
    wire [31:0] sub_res;
    assign sub_res = add_res + 1;

    wire [31:0] nop_res;
    assign nop_res = 0;

    wire [31:0] lui_res;
    assign lui_res = {op2[15:0], 16'd0};

    always @(*) begin
        case (alu_op)
            `OP_NOP : res = nop_res;
            `OP_ADDU : res = add_res;
            `OP_LUI : res = lui_res;
            `OP_SUBU : res = sub_res;
            default : res = nop_res;
        endcase
    end

endmodule