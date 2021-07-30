module Gen_new_PC (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire is_branch,
    input wire [31:0] current_pc,
    input wire [31:0] target_pc,
    output wire [31:0] new_pc
);
    
    reg is_branch_temp;
    reg [31:0] target_pc_temp;
    always @(posedge clk) begin
        if(stall_pc)begin
            is_branch_temp <= is_branch;
            target_pc_temp <= target_pc;
        end
        else begin
            is_branch_temp <= 0;
            target_pc_temp <= 0;
        end
        
    end

    wire [31:0] next_pc;
    assign next_pc = current_pc + 4;

    assign new_pc = reset ? 32'h80000000 : (is_branch ? target_pc :
                                            is_branch_temp ? target_pc_temp : next_pc);

endmodule