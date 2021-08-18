`include "inst_define.v"

module Inst_decoder (
    input wire clk,
    input wire reset,
    input wire [31:0] pc,
    input wire [31:0] inst,

    input wire stall_id,
    
    input wire [31:0] pre_write_reg_res,

    output wire is_branch,
    output wire [31:0] target_pc,

    

    output wire [4:0] read_reg_addr1,
    output wire [4:0] read_reg_addr2,
    input wire [31:0] read_reg_data1,
    input wire [31:0] read_reg_data2,

    output reg [31:0] ram_addr,
    output reg [3:0] ram_be,
    output reg read_ram_en,
    output reg write_ram_en,
    output reg [31:0] write_ram_data,

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

    wire [31:0] ram_addr_temp;
    assign ram_addr_temp = (is_reg1_conflict ? pre_write_reg_res : read_reg_data1) + sign_ext_imm;

    // gen ram be
    reg [3:0] ram_be_temp;
    // assign read_ram_be = ram_be_temp;
    always @(*) begin
        case (op_code)
            `LW, `SW : ram_be_temp = 4'b0000;
            `LB, `SB : begin
                case (ram_addr_temp[1:0])
                    2'b00 : ram_be_temp = 4'b1110;
                    2'b01 : ram_be_temp = 4'b1101;
                    2'b10 : ram_be_temp = 4'b1011;
                    2'b11 : ram_be_temp = 4'b0111;
                    default: ram_be_temp = 4'b1110;
                endcase
            end 
            default: ram_be_temp = 4'b1111;
        endcase
    end


    // gen read after write conflict signal
    assign is_reg1_conflict = (read_reg_addr1 == write_reg_addr) & write_reg_en;
    assign is_reg2_conflict = (read_reg_addr2 == write_reg_addr) & write_reg_en;
    assign is_ram_conflict = (ram_addr_temp == ram_addr) & write_ram_en;
    // sovle conflict data
    wire [31:0] reg1_data;
    assign reg1_data = is_reg1_conflict ? pre_write_reg_res : read_reg_data1;
    wire [31:0] reg2_data;
    assign reg2_data = is_reg2_conflict ? pre_write_reg_res : read_reg_data2;
    wire [31:0] ram_data;
    assign ram_data = is_ram_conflict ? pre_write_reg_res : write_ram_data;
    
    //  JR instruction is a little special
    wire is_JR;
    assign is_JR = (op_code == `SPECIAL & funct == `JR_FUNCT);
    // //  SLL instruction's op2 is not reg2_data
    // wire is_SLL;
    // assign is_SLL = (op_code == `SPECIAL & funct == `SLL_FUNCT);

    // gen target_pc
    wire [31:0] j_target_pc;
    assign j_target_pc = is_JR ? reg1_data : {pc[31:28], instr_index, 2'b00};

    wire [31:0] b_target_pc;
    wire [31:0] late_pool_pc;
    assign late_pool_pc = pc + 4;
    assign b_target_pc = late_pool_pc + {{14{immediate[15]}}, immediate , 2'b00};

    assign target_pc = ~is_branch ? 32'd0 :
                       (op_code == `BNE  |
                        op_code == `BEQ  |
                        op_code == `BLEZ |
                        op_code == `BGTZ 
                       ) ? b_target_pc : j_target_pc;
                       
    
    // gen is branch signal
    reg is_branch_temp;
    assign is_branch = is_branch_temp;
    always @(*) begin
        case (op_code)
            `BNE : is_branch_temp = (reg1_data != reg2_data);
            `BEQ : is_branch_temp = (reg1_data == reg2_data);
            `BLEZ: is_branch_temp = reg1_data == 0 | reg1_data[31];
            `BGTZ: is_branch_temp = reg1_data[31];
            `J   : is_branch_temp = 1;
            `JAL : is_branch_temp = 1;
            // `JR  : is_branch_temp = 1;
            default: is_branch_temp = is_JR;
        endcase
    end

    // gen read ram en
    wire read_ram_en_temp;
    assign read_ram_en_temp = reset ? 0 : (op_code == `LW | op_code == `LB);

    // gen write ram en
    wire write_ram_en_temp;
    assign write_ram_en_temp = (op_code == `SW | op_code == `SB);

    // gen read reg addr
    assign read_reg_addr1 = rs;
    assign read_reg_addr2 = rt;

    // gen write reg en
    wire write_reg_en_temp;
    assign write_reg_en_temp = ( op_code == `SPECIAL & funct!= `JR_FUNCT |
                                 op_code == `LW      |
                                 op_code == `ORI     |
                                 op_code == `LUI     |
                                 op_code == `LB      |
                                 op_code == `ADDI    |
                                 op_code == `ADDIU   |
                                 op_code == `JAL     |
                                 op_code == `ANDI    |
                                 op_code == `MUL     |
                                 op_code == `XORI
                               );

    // gen write reg addr
    reg [4:0] write_reg_addr_temp;
    always @(*) begin
        case (op_code)
            `SPECIAL, `MUL : write_reg_addr_temp = rd;
            `JAL     : write_reg_addr_temp = 5'd31;
            default: write_reg_addr_temp = rt;
        endcase
    end

    // gen alu op
    reg [3:0] alu_op_temp;
    
    always @(*) begin
        if(op_code == `SPECIAL) begin
            case (funct)
                `ADDU_FUNCT : alu_op_temp = `OP_ADDU;
                `AND_FUNCT  : alu_op_temp = `OP_AND;
                `SLT_FUNCT  : alu_op_temp = `OP_SLT;
                `OR_FUNCT   : alu_op_temp = `OP_OR;
                `XOR_FUNCT  : alu_op_temp = `OP_XOR;
                `SLL_FUNCT  : alu_op_temp = `OP_LSHIFT;
                `SRL_FUNCT, `SRLV_FUNCT  : alu_op_temp = `OP_RSHIFT;
                default: alu_op_temp = `OP_NOP;
            endcase
        end
        else begin
            case (op_code)
                `ORI : alu_op_temp = `OP_OR;
                `LUI : alu_op_temp = `OP_LUI;
                `ADDI, `ADDIU, `JAL : alu_op_temp = `OP_ADDU;
                `ANDI : alu_op_temp = `OP_AND;
                `MUL : alu_op_temp = `OP_MUL;
                `XORI : alu_op_temp = `OP_XOR;
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
                op1_temp = (funct == `SLL_FUNCT | funct == `SRL_FUNCT) ? {27'd0, sa} : reg1_data;
                op2_temp = reg2_data;
            end 
            `MUL : begin
                op1_temp = reg1_data;
                op2_temp = reg2_data;
            end
            `ORI, `ANDI : begin
                op1_temp = reg1_data;
                op2_temp = zero_ext_imm; 
            end
            // `LW, `LB : begin
            //     op1_temp = ram_data;
            //     op2_temp = 0;
            // end
            `LUI : begin
                op1_temp = 0;
                op2_temp = zero_ext_imm;
            end
            `SW, `SB : begin
                op1_temp = reg2_data;
                op2_temp = 0;
            end
            `ADDI, `ADDIU : begin
                op1_temp = reg1_data;
                op2_temp = sign_ext_imm;
            end
            `JAL : begin
                op1_temp = pc;
                op2_temp = 32'd8;
            end
            `XORI : begin
                op1_temp = reg1_data;
                op2_temp = zero_ext_imm;
            end
            default: begin
                op1_temp = 0;
                op2_temp = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        
        ram_be <= reset | stall_id ? 0 : ram_be_temp;
        ram_addr <= reset | stall_id ? 0 : ram_addr_temp;
        read_ram_en <= reset ? 0 : read_ram_en_temp;
        write_ram_en <= reset | stall_id ? 0 : write_ram_en_temp;
        write_ram_data <= reset ? 0 : reg2_data;

        write_reg_en <= reset | stall_id ? 0 : write_reg_en_temp;
        write_reg_addr <= reset | stall_id ? 0 : write_reg_addr_temp;

        alu_op <= reset | stall_id ? 0 : alu_op_temp;
        op1 <= reset | stall_id ? 0 : op1_temp;
        op2 <= reset | stall_id ? 0 : op2_temp;
        
        
    end

endmodule