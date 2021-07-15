`include "inst_define.v"

module Inst_decoder (
    input wire clk,
    input wire reset,
    input wire [31:0] pc,
    input wire [31:0] inst,

    input wire stall_id,
    
    input wire [31:0] pre_alu_res,

    output wire is_branch,
    output wire [31:0] target_pc,

    output wire read_ram_en,
    output wire [31:0] read_ram_addr,
    output wire [3:0] read_ram_be,
    input wire [31:0] read_ram_data,

    output reg write_ram_en,
    output reg [3:0] write_ram_be,
    output reg [31:0] write_ram_addr,

    output wire [4:0] read_reg_addr1,
    output wire [4:0] read_reg_addr2,
    input wire [31:0] read_reg_data1,
    input wire [31:0] read_reg_data2,

    output reg write_reg_en,
    output reg [4:0] write_reg_addr,

    output reg [3:0] alu_op,
    output reg [31:0] op1,
    output reg [31:0] op2

);
    // analysis inst
    wire [5:0] op_code;
    assign op_code = inst[31:26];
    
    wire [4:0] rs;
    assign rs = inst[25:21];

    wire [4:0] rt;
    assign rt = inst[20:16];

    wire [4:0] rd;
    assign rd = inst[15:11];

    wire [15:0] immediate;
    assign immediate = inst[15:0];

    wire is_reg1_conflict;
    wire is_reg2_conflict;
    wire is_ram_conflict;

    wire [31:0] sign_ext_imm;
    assign sign_ext_imm = {{16{immediate[15]}}, immediate};

    wire [31:0] zero_ext_imm;
    assign zero_ext_imm = {16'd0, immediate};

    wire [25:0] instr_index;
    assign instr_index = inst[25:0];

    wire [10:6] sa;
    assign sa = inst[10:6];

    wire [5:0] funct;
    assign funct = inst[5:0];

    wire [31:0] ram_addr;
    assign ram_addr = (is_reg1_conflict ? pre_alu_res : read_reg_data1) + sign_ext_imm;

    // gen ram be
    reg [3:0] ram_be_temp;
    assign read_ram_be = ram_be_temp;
    always @(*) begin
        case (op_code)
            `LW, `SW : ram_be_temp = 4'b0000;
            default: ram_be_temp = 4'b1111;
        endcase
    end


    // gen read after write conflict signal
    assign is_reg1_conflict = (read_reg_addr1 == write_reg_addr) & write_reg_en;
    assign is_reg2_conflict = (read_reg_addr2 == write_reg_addr) & write_reg_en;
    assign is_ram_conflict = (read_ram_addr == write_ram_addr) & write_ram_en;
    // sovle conflict data
    wire [31:0] reg1_data;
    assign reg1_data = is_reg1_conflict ? pre_alu_res : read_reg_data1;
    wire [31:0] reg2_data;
    assign reg2_data = is_reg2_conflict ? pre_alu_res : read_reg_data2;
    wire [31:0] ram_data;
    assign ram_data = is_ram_conflict ? pre_alu_res : read_ram_data;

    // gen target_pc
    wire [31:0] j_target_pc;
    assign j_target_pc = {pc[31:28], instr_index, 2'b00};

    wire [31:0] b_target_pc;
    wire [31:0] late_pool_pc;
    assign late_pool_pc = pc + 4;
    assign b_target_pc = late_pool_pc + {{14{immediate[15]}}, immediate , 2'b00};

    assign target_pc = ~is_branch ? 32'd0 :
                       (op_code == `BNE) ? b_target_pc :j_target_pc;
    
    // gen is branch signal
    reg is_branch_temp;
    assign is_branch = is_branch_temp;
    always @(*) begin
        case (op_code)
            `BNE : is_branch_temp = (reg1_data != reg2_data);
            default: is_branch_temp = 0;
        endcase
    end

    // gen read ram en
    assign read_ram_en = reset ? 0 : (op_code == `LW);
    
    // gen read ram addr
    assign read_ram_addr = reset ? 0 : ram_addr;

    // gen write ram en
    wire write_ram_en_temp;
    assign write_ram_en_temp = (op_code == `SW);

    // gen read reg addr
    assign read_reg_addr1 = rs;
    assign read_reg_addr2 = rt;

    // gen write reg en
    wire write_reg_en_temp;
    assign write_reg_en_temp = ( op_code == `SPECIAL |
                                 op_code == `LW      |
                                 op_code == `ORI     |
                                 op_code == `LUI
                               );

    // gen write reg addr
    wire [4:0] write_reg_addr_temp;
    assign write_reg_addr_temp = ( op_code == `LW |
                                   op_code == `ORI | 
                                   op_code == `LUI
                                 ) ? rt : rd;

    // gen alu op
    reg [3:0] alu_op_temp;
    
    always @(*) begin
        if(op_code == `SPECIAL) begin
            case (funct)
                `ADDU_FUNCT : alu_op_temp = `OP_ADDU;
                default: alu_op_temp = `OP_NOP;
            endcase
        end
        else begin
            case (op_code)
                `ORI : alu_op_temp = `OP_OR;
                `LUI : alu_op_temp = `OP_LUI;
                default: alu_op_temp = `OP_NOP;
            endcase
        end
    end

    // gen alu op1 op2
    reg [31:0] op1_temp;
    reg [31:0] op2_temp;
    
    always@(*) begin
        case (op_code)
            `SPECIAL : begin
                op1_temp = reg1_data;
                op2_temp = reg2_data;
            end 
            `ORI : begin
                op1_temp = reg1_data;
                op2_temp = zero_ext_imm; 
            end
            `LW : begin
                op1_temp = ram_data;
                op2_temp = 0;
            end
            `LUI : begin
                op1_temp = 0;
                op2_temp = zero_ext_imm;
            end
            `SW : begin
                op1_temp = reg2_data;
                op2_temp = 0;
            end
            default: begin
                op1_temp = 0;
                op2_temp = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        
        write_ram_en <= reset ? 0 : write_ram_en_temp;
        write_ram_be <= reset ? 0 : ram_be_temp;
        write_ram_addr <= reset ? 0 : ram_addr;

        write_reg_en <= reset ? 0 : write_reg_en_temp;
        write_reg_addr <= reset ? 0 : write_reg_addr_temp;

        alu_op <= reset ? 0 : alu_op_temp;
        op1 <= reset ? 0 : op1_temp;
        op2 <= reset ? 0 : op2_temp;
        
        
    end

endmodule