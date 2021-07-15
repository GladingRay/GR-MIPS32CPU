module Inst_fetch (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire stall_id,
    input wire is_branch,
    input wire [31:0] target_pc,

    output wire [31:0] current_pc,

    input wire [31:0] inst_in,
    output reg [31:0] inst_out_id,
    output reg [31:0] pc_out_id
);
    wire [31:0] new_pc;
    
    Gen_new_PC  u_Gen_new_PC (
        .reset                   ( reset        ),
        .is_branch               ( is_branch    ),
        .current_pc              ( current_pc   ),
        .target_pc               ( target_pc    ),

        .new_pc                  ( new_pc       )
    );

    PC  u_PC (
        .clk                     ( clk          ),
        .stall_pc                ( stall_pc     ),
        .new_pc                  ( new_pc       ),

        .current_pc              ( current_pc   )
    );

    always @(posedge clk) begin
        if(~stall_id) begin
            inst_out_id <= reset ? 0 : inst_in;
            pc_out_id <= reset ? 0 :( is_branch ? target_pc : current_pc);
        end
        
    end
endmodule