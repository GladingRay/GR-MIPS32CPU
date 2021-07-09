module Inst_fetch (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire is_branch,
    input wire [31:0] target_pc,
    output wire [31:0] current_pc
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
endmodule