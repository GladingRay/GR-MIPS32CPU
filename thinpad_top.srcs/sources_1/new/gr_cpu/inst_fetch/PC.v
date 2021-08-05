module PC (
    input wire clk,
    input wire stall_pc,
    input wire [31:0] new_pc,
    input wire is_cache_hit_temp,

    output reg is_cache_hit,
    output reg [31:0] current_pc
);
    always @(posedge clk) begin
        if(~stall_pc) begin
            current_pc <= new_pc;
            is_cache_hit <= is_cache_hit_temp;
        end
    end
endmodule