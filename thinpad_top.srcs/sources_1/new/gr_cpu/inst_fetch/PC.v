module PC (
    input wire clk,
    input wire reset,
    input wire stall_pc,
    input wire [31:0] new_pc,
    input wire is_branch,
    output reg [31:0] current_pc
);
    always @(posedge clk) begin
        if(~stall_pc) begin
            current_pc <= new_pc;
        end
    end
endmodule