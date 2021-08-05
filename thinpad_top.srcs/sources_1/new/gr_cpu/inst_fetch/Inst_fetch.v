module Inst_fetch (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire stall_id,
    input wire is_branch,
    input wire [31:0] target_pc,

    output wire [31:0] current_pc,

    input wire [31:0] inst_in,

    output wire is_cache_hit,
    output reg [31:0] inst_out_id,
    output reg [31:0] pc_out_id
);

    wire [31:0] new_pc;
    wire is_branch_pre;
    Gen_new_PC  u_Gen_new_PC (
        .clk                     ( clk          ),
        .reset                   ( reset        ),
        .is_branch               ( is_branch    ),
        .stall_pc                ( stall_pc     ),
        .target_pc               ( target_pc    ),
        .is_branch_pre           ( is_branch_pre),
        .new_pc                  ( new_pc       )
    );

    wire is_cache_hit_temp;
    assign is_cache_hit_temp = 0;


    PC  u_PC (
        .clk                     ( clk          ),
        .stall_pc                ( stall_pc     ),
        .new_pc                  ( new_pc       ),
        .is_cache_hit_temp       ( is_cache_hit_temp ),

        .is_cache_hit            ( is_cache_hit ),
        .current_pc              ( current_pc   )
    );

    always @(posedge clk) begin
        inst_out_id <= reset | is_branch_pre ? 32'h34000000 : inst_in;
        pc_out_id <= reset ? 0 : current_pc;
        
    end
endmodule