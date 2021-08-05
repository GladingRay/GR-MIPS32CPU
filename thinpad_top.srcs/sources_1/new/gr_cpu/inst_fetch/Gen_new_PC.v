module Gen_new_PC (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire is_branch,
    input wire [31:0] target_pc,
    output reg is_branch_pre,
    output reg [31:0] new_pc
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
    assign next_pc = new_pc + 4;
    wire [31:0] new_pc_temp;
    assign new_pc_temp = reset ? 32'h80000000 : (is_branch ? target_pc :
                                                  is_branch_temp ? target_pc_temp : next_pc);

    wire is_branch_pre_temp;
    // assign is_branch_pre_temp = reset ? 0 : (stall_pc ? 0 : is_branch);
    assign is_branch_pre_temp = 0;
    always @(posedge clk) begin
        if(~stall_pc) begin
            new_pc <= new_pc_temp;
            is_branch_pre <= is_branch | is_branch_temp;
        end
        
    end
endmodule