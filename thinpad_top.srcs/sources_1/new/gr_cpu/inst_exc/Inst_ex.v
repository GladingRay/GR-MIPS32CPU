module Inst_excute (
    input wire clk,
    input wire reset,
    input wire [3:0] alu_op,
    input wire [31:0] op1,
    input wire [31:0] op2,

    input wire [31:0] read_ram_data;
    input wire is_read_ram;
    // input wire write_ram_en_in,
    // input wire [31:0] write_ram_addr_in, 
    // input wire [3:0]  write_ram_be_in,

    output wire [31:0] write_reg_data,
    
    // output reg write_ram_en,
    // output reg [31:0] write_ram_addr,
    // output reg [31:0] write_ram_data,
    // output reg [3:0]  write_ram_be,
    
    output wire [31:0] res_to_id
);


    wire  [31:0]  ALU_res;
    assign res_to_id = reset ? 0 : res;
    ALU  u_ALU (
        .alu_op                  ( alu_op   ),
        .op1                     ( op1      ),
        .op2                     ( op2      ),

        .res                     ( ALU_res  )
    );

    assign write_reg_data = reset ? 0 :
                            is_read_ram ? read_ram_data : ALU_res;

    // always @(posedge clk) begin
    //     write_ram_en <= reset ? 0 : write_ram_en_in;
    //     write_ram_addr <= reset ? 0 : write_ram_addr_in;
    //     write_ram_data <= reset ? 0 : res;
    //     write_ram_be <= reset ? 0 : write_ram_be_in;
    // end
    
endmodule