module Gen_new_PC (
    input wire reset,
    input wire is_branch,
    input wire [31:0] current_pc,
    input wire [31:0] target_pc,
    output wire [31:0] new_pc
);
    wire [31:0] next_pc;
    assign  next_pc = current_pc + 4;
    assign new_pc = reset ? 32'h80000000 : (is_branch ? target_pc : next_pc);

endmodule