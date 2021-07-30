module Control_ram (
    input wire [31:0] current_inst_addr,
    input wire [31:0] branch_inst_addr,
    input wire is_branch,
    input wire reset,
    output wire pc_stall,
    output wire [31:0] inst, 

    input wire read_ram_en,
    input wire write_ram_en,
    input wire [31:0] ram_addr,
    input wire [3:0] ram_be,
    input wire [31:0] write_ram_data,
    output wire [31:0] read_ram_data, 
    output wire id_stall,  

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
    inout wire [31:0] ext_ram_data,

    output wire is_read_serial_data,
    input wire [31:0] read_serial_data,
    output wire is_read_serial_state,
    output wire is_write_serial_data,
    output wire [7:0] write_serial_data

);
    wire inst_ram;
    wire read_ram;
    wire write_ram;
    wire [31:0] inst_addr;
    // assign inst_addr = is_branch ? branch_inst_addr : current_inst_addr; 
    assign inst_addr = current_inst_addr; 
    assign inst_ram = inst_addr[22];   // 0 为baseram
    assign data_ram = ram_addr[22];
    
    assign is_read_serial_data  = read_ram_en  & 
                                  ram_addr[29] &
                                  ram_addr[28] &
                                  ram_addr[3]  &
                                  ~ram_addr[2];

    assign is_read_serial_state = read_ram_en  &
                                  ram_addr[29] &
                                  ram_addr[28] &
                                  ram_addr[3]  &
                                  ram_addr[2];

    assign is_write_serial_data = write_ram_en &
                                  ram_addr[29] & 
                                  ram_addr[28] & 
                                  ram_addr[3]  &
                                  ~ram_addr[2];
    
    wire is_serial;
    assign is_serial = is_read_serial_data | is_read_serial_state | is_write_serial_data;
    assign write_serial_data = write_ram_data[7:0];
    // assign write;
    assign ext_ram_ce_n = 0;
    assign base_ram_ce_n = 0;

    wire pc_stall_t;
    wire id_stall_t;
    assign pc_stall = reset ? 0 : pc_stall_t;
    assign id_stall = reset ? 0 : id_stall_t;

    // gen pc_stall signal
    assign pc_stall_t = (read_ram_en|write_ram_en) & ~(is_serial) & ~(inst_ram ^ data_ram) | id_stall_t;

    // gen id_stall signal
    assign id_stall_t = 0;

    // fecth inst
    assign inst = pc_stall_t | reset ? 32'd0 : (~inst_ram ? base_ram_data : ext_ram_data);
    
    // gen base ram signals 
    assign base_ram_oe_n = ~(
                                ~inst_ram & ~pc_stall_t | read_ram_en & ~is_serial & ~data_ram & ~id_stall_t
                            );
    // assign base_ram_oe_n = ~(~inst_ram & ~pc_stall_t | 
    //                          ~read_ram & id_read_ram_en & ~id_stall_t) & ~id_serial;
    assign base_ram_we_n = ~(
                                write_ram_en & ~is_serial & ~data_ram
                            );
    // assign base_ram_we_n = ~(wb_write_ram_en & ~write_ram & ~is_write_serial_data) ;

    assign base_ram_be_n = pc_stall_t ? ram_be : 4'b0000;

    // assign base_ram_be_n = wb_write_ram_en & ~write_ram & ~is_write_serial_data ? write_be : 
    //                        id_read_ram_en & ~read_ram  & ~id_serial ? read_be : 4'd0;

    assign base_ram_addr = pc_stall_t ? ram_addr[21:2] : inst_addr[21:2];


    assign base_ram_data = write_ram_en & ~is_serial & ~data_ram ? write_ram_data : 32'bz;
    reg [31:0] base_ram_be_data;
    always @(*) begin
        case (ram_be)
            4'b1110 : base_ram_be_data = {{28{base_ram_data[7]}},base_ram_data[7:0]};
            4'b1101 : base_ram_be_data = {{28{base_ram_data[15]}},base_ram_data[15:8]};
            4'b1011 : base_ram_be_data = {{28{base_ram_data[23]}},base_ram_data[23:16]};
            4'b0111 : base_ram_be_data = {{28{base_ram_data[31]}},base_ram_data[31:24]};
            default: base_ram_be_data = base_ram_data;
        endcase
    end
    // gen ext_ram_signals

    assign ext_ram_oe_n = ~(
                                inst_ram & ~pc_stall_t | read_ram_en & ~is_serial & data_ram
                           );

    // assign ext_ram_oe_n = ~(inst_ram & ~pc_stall_t | 
    //                          read_ram & id_read_ram_en & ~id_stall_t) ;
    assign ext_ram_we_n = ~(
                                write_ram_en & ~is_serial & data_ram
                           );
    // assign ext_ram_we_n = ~(wb_write_ram_en & write_ram) ;

    assign ext_ram_be_n = write_ram_en | read_ram_en ? ram_be : 4'b0000;

    // assign ext_ram_be_n = wb_write_ram_en & write_ram ? write_be : 
    //                        id_read_ram_en & read_ram   ? read_be : 4'd0;

    assign ext_ram_addr = pc_stall_t ? ram_addr[21:2] : inst_addr[21:0];

    // assign ext_ram_addr = wb_write_ram_en & write_ram ? wb_write_ram_addr[21:2] : 
    //                        id_read_ram_en & read_ram   ? id_read_ram_addr[21:2] : 
    //                        inst_addr[21:2];
    assign ext_ram_data = write_ram_en & ~is_serial & write_ram ? write_ram_data : 32'bz;
    reg [31:0] ext_ram_be_data;
    always @(*) begin
        case (ram_be)
            4'b1110 : ext_ram_be_data = {{28{ext_ram_data[7]}},ext_ram_data[7:0]};
            4'b1101 : ext_ram_be_data = {{28{ext_ram_data[15]}},ext_ram_data[15:8]};
            4'b1011 : ext_ram_be_data = {{28{ext_ram_data[23]}},ext_ram_data[23:16]};
            4'b0111 : ext_ram_be_data = {{28{ext_ram_data[31]}},ext_ram_data[31:24]};
            default: ext_ram_be_data = ext_ram_data;
        endcase
    end
    // gen read data
    assign read_ram_data = read_ram_en ? 
                           ( is_serial ? read_serial_data : 
                           ( data_ram ? ext_ram_be_data : base_ram_be_data ) ) : 0;
    // assign read_ram_data = id_serial ? read_serial_data : (id_read_ram_en & ~id_stall_t ? 
    //                           (read_ram ? ext_ram_be_data : base_ram_be_data) : 32'bz);

endmodule