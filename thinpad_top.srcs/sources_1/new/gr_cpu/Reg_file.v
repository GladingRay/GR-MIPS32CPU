module Reg_file (
    input wire clk,
    input wire reset,
    input wire [4:0] read_reg_addr1,
    input wire [4:0] read_reg_addr2,
    output wire [31:0] read_reg_data1,
    output wire [31:0] read_reg_data2,

    input wire write_reg_en,
    input wire [4:0] write_reg_addr,
    input wire [31:0] write_reg_data
);
    reg [31:0] reg_file[31:0];
    assign read_reg_data1 = (read_reg_addr1 == 0) ? 0 : reg_file[read_reg_addr1];
    assign read_reg_data2 = (read_reg_addr2 == 0) ? 0 : reg_file[read_reg_addr2];
    integer i;
    always @(posedge clk) begin
        if(reset) begin
            for (i = 0; i< 32; i = i + 1) begin
                reg_file[i] <= 0;
            end
        end
        else begin
            if(write_reg_en) begin
                reg_file[write_reg_addr] <= write_reg_data;
            end
        end 
    end

endmodule