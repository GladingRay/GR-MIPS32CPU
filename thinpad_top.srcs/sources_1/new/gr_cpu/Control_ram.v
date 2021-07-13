module Control_ram (
    input wire [31:0] current_inst_addr,
    input wire [31:0] branch_inst_addr,
    input wire is_branch,

    output wire pc_stall,
    output wire [31:0] inst, 

    input wire id_read_ram_en,
    input wire [31:0] id_read_ram_addr,
    input wire [3:0] read_be,
    output wire [31:0] id_read_ram_data, 
    output wire id_stall,  

    input wire wb_write_ram_en,
    input wire [31:0] wb_write_ram_addr,
    input wire wb_write_ram_data,
    input wire [3:0] write_be,

    output wire base_ram_ce_n,
    output wire base_ram_oe_n,
    output wire base_ram_we_n,
    output wire [3:0] base_ram_be_n,
    output wire [19:0] base_ram_addr,
    inout wire [31:0] base_ram_data,

    output wire ext_ram_ce_n,
    output wire ext_ram_oe_n,
    output wire ext_ram_we_n,
    output wire [3:0] ext_ram_be_n,
    output wire [19:0] ext_ram_addr,
    inout wire [31:0] ext_ram_data


);
    wire inst_ram;
    wire read_ram;
    wire write_ram;
    wire [31:0] inst_addr;
    assign inst_addr = is_branch ? branch_inst_addr : current_inst_addr; 
    assign inst_ram = inst_addr[22];   // 0 为baseram
    assign read_ram = id_read_ram_addr[22];
    assign write_ram = wb_write_ram_addr[22];


    assign ext_ram_ce_n = 0;
    assign base_ram_ce_n = 0;

    wire pc_stall_t;
    wire id_stall_t;
    assign pc_stall = pc_stall_t;
    assign id_stall = id_stall_t;

    // gen pc_stall signal
    assign pc_stall_t = (id_read_ram_en & ~(inst_ram ^ read_ram) |
                        wb_write_ram_en & ~(inst_ram ^ write_ram) |
                        id_stall_t) ? 1:0;

    // gen id_stall signal
    assign id_stall_t = (id_read_ram_en & 
                        wb_write_ram_en & 
                        ~(read_ram ^ write_ram)) ? 1:0;
    // fecth inst
    assign inst = pc_stall_t ? 32'd0 : (~inst_ram ? base_ram_data : ext_ram_data);
    // assign inst = inst_ram ? base_ram_data : ext_ram_data;
    // gen base ram signals
    assign base_ram_oe_n = ~(~inst_ram & ~pc_stall_t | 
                             ~read_ram & id_read_ram_en & ~id_stall_t) ;
    assign base_ram_we_n = ~(wb_write_ram_en & ~write_ram) ;

    assign base_ram_be_n = wb_write_ram_en & ~write_ram ? write_be : 
                           id_read_ram_en & ~read_ram   ? read_be : 4'd0;

    assign base_ram_addr = wb_write_ram_en & ~write_ram ? wb_write_ram_addr[21:2] : 
                           id_read_ram_en & ~read_ram   ? id_read_ram_addr[21:2] : 
                           inst_addr[21:2];
    assign base_ram_data = wb_write_ram_en & ~write_ram ? wb_write_ram_data : 32'bz;

    // gen ext_ram_signals
    assign ext_ram_oe_n = ~(inst_ram & ~pc_stall_t | 
                             read_ram & id_read_ram_en & ~id_stall_t) ;
    assign ext_ram_we_n = ~(wb_write_ram_en & write_ram) ;

    assign ext_ram_be_n = wb_write_ram_en & write_ram ? write_be : 
                           id_read_ram_en & read_ram   ? read_be : 4'd0;

    assign ext_ram_addr = wb_write_ram_en & write_ram ? wb_write_ram_addr[21:2] : 
                           id_read_ram_en & read_ram   ? id_read_ram_addr[21:2] : 
                           inst_addr[21:2];
    assign ext_ram_data = wb_write_ram_en & write_ram ? wb_write_ram_data : 32'bz;

    // gen id signals
    assign id_read_ram_data = id_read_ram_en & ~id_stall_t ? 
                              (read_ram ? ext_ram_data : base_ram_data) : 32'bz;

endmodule