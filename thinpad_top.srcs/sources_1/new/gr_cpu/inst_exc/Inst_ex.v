module Inst_excute (
    input wire clk,
    input wire [3:0] alu_op,
    input wire [31:0] op1,
    input wire [31:0] op2,

    input wire write_ram_en_in,
    input wire [19:0] write_ram_addr_in, 

    output wire [31:0] write_reg_data,
    
    output reg write_ram_en,
    output reg [19:0] write_ram_addr,
    output reg [31:0] write_ram_data
     
);

    // ALU Inputs
    wire  [31:0]  res;

    ALU  u_ALU (
        .alu_op                  ( alu_op   ),
        .op1                     ( op1      ),
        .op2                     ( op2      ),

        .res                     ( res      )
    );

    assign write_reg_data = res;

    always @(posedge clk) begin
        write_ram_en <= write_ram_en_in;
        write_ram_addr <= write_ram_addr_in;
        write_ram_data <= res;
    end
    
endmodule