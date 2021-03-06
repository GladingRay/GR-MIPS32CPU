module GR_core (
    input wire clk,
    input wire reset,

    //BaseRAM信号
    inout wire [31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire [19:0] base_ram_addr, //BaseRAM地址
    output wire [3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire [31:0] ext_ram_data,  //ExtRAM数据
    output wire [19:0] ext_ram_addr, //ExtRAM地址
    output wire [3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,        //ExtRAM写使能，低有效

    output wire is_read_serial_data,
    input wire [31:0] read_serial_data,
    output wire is_read_serial_state,
    output wire is_write_serial_data, 
    output wire [7:0] write_serial_data
);
    // Inst_fetch Outputs
    wire  [31:0]  current_pc;
    wire  [31:0]  ram_inst;
    wire  [31:0]  cache_inst;
    wire  [31:0]  pc_out_id;
    wire  is_cache_hit;
    wire is_hit_to_id;

    // Control_ram Outputs
    wire  pc_stall;
    wire  [31:0]  inst;
    wire  [31:0]  read_ram_data;
    wire  id_stall;
    /**************** cpu out *************/
    // wire  base_ram_ce_n;  
    // wire  base_ram_oe_n;  
    // wire  base_ram_we_n;  
    // wire  [3:0]  base_ram_be_n;    
    // wire  [19:0]  base_ram_addr;   
    // wire  ext_ram_ce_n;
    // wire  ext_ram_oe_n;
    // wire  ext_ram_we_n;
    // wire  [3:0]  ext_ram_be_n;
    // wire  [19:0]  ext_ram_addr;
    
    // Control_ram Bidirs
    // wire  [31:0]  base_ram_data;
    // wire  [31:0]  ext_ram_data;
    /**************** cpu out *************/


    // Inst_decoder Outputs
    wire  is_branch;
    wire  [31:0]  target_pc;
    wire  read_ram_en;
    wire  write_ram_en;
    wire  [31:0]  ram_addr;
    wire  [3:0]  ram_be;
    wire  [31:0] write_ram_data;
    wire  [4:0]  read_reg_addr1;
    wire  [4:0]  read_reg_addr2;
    wire  id_write_reg_en;
    wire  [4:0]  id_write_reg_addr;
    wire  [3:0]  alu_op;
    wire  [31:0]  op1;
    wire  [31:0]  op2;


    // Inst_excute Outputs
    wire  [31:0]  write_reg_data;
    

    // Reg_file Outputs
    wire  [31:0]  read_reg_data1;
    wire  [31:0]  read_reg_data2;

    /* ram controller begin */ 
    

    Control_ram  u_Control_ram (
        .current_inst_addr       ( current_pc          ),
        .inst_cache_hit          ( is_cache_hit        ),
        .reset                   ( reset               ),
        .pc_stall                ( pc_stall            ),
        .inst                    ( inst                ),

        .read_ram_en             ( read_ram_en         ),
        .write_ram_en            ( write_ram_en        ),
        .ram_addr                ( ram_addr            ),
        .ram_be                  ( ram_be              ),
        .write_ram_data          ( write_ram_data      ),
        .read_ram_data           ( read_ram_data       ),

        .id_stall                ( id_stall            ),
        .base_ram_ce_n           ( base_ram_ce_n       ),
        .base_ram_oe_n           ( base_ram_oe_n       ),
        .base_ram_we_n           ( base_ram_we_n       ),
        .base_ram_be_n           ( base_ram_be_n       ),
        .base_ram_addr           ( base_ram_addr       ),
        .ext_ram_ce_n            ( ext_ram_ce_n        ),
        .ext_ram_oe_n            ( ext_ram_oe_n        ),
        .ext_ram_we_n            ( ext_ram_we_n        ),
        .ext_ram_be_n            ( ext_ram_be_n        ),
        .ext_ram_addr            ( ext_ram_addr        ),

        .base_ram_data           ( base_ram_data       ),
        .ext_ram_data            ( ext_ram_data        ),
        .is_read_serial_data     ( is_read_serial_data ),
        .read_serial_data        ( read_serial_data    ),
        .is_read_serial_state    ( is_read_serial_state),
        .is_write_serial_data    ( is_write_serial_data),
        .write_serial_data       ( write_serial_data   )
    );

    /* ram controller end */


    /* inst fetch begin */

    Inst_fetch  u_Inst_fetch (
        .clk                     ( clk           ),
        .reset                   ( reset         ),
        .stall_pc                ( pc_stall      ),
        .stall_id                ( id_stall      ),
        .is_branch               ( is_branch     ),
        .target_pc               ( target_pc     ),
        .inst_in                 ( inst          ),

        .is_cache_hit            ( is_cache_hit  ),
        .current_pc              ( current_pc    ),
        .ram_inst                ( ram_inst      ),
        .cache_inst              ( cache_inst    ),
        .pc_out_id               ( pc_out_id     ),
        .is_hit_to_id            ( is_hit_to_id  )
    );

    /* inst fetch end */

    /* inst decode begin */
    wire [31:0] inst_to_id;
    assign inst_to_id = is_hit_to_id ? cache_inst : ram_inst;

    Inst_decoder  u_Inst_decoder (
        .clk                     ( clk               ),
        .reset                   ( reset             ),
        .pc                      ( pc_out_id         ),
        .inst                    ( inst_to_id        ),
        .stall_id                ( id_stall          ),
        .pre_write_reg_res             ( write_reg_data    ),
        
        .read_reg_addr1          ( read_reg_addr1    ),
        .read_reg_addr2          ( read_reg_addr2    ),
        .read_reg_data1          ( read_reg_data1    ),
        .read_reg_data2          ( read_reg_data2    ),

        .is_branch               ( is_branch         ),
        .target_pc               ( target_pc         ),

        .read_ram_en             ( read_ram_en       ),
        .write_ram_en            ( write_ram_en      ),
        .ram_addr                ( ram_addr          ),
        .ram_be                  ( ram_be            ),
        .write_ram_data          ( write_ram_data    ),

        .write_reg_en            ( id_write_reg_en   ),
        .write_reg_addr          ( id_write_reg_addr ),
        .alu_op                  ( alu_op            ),
        .op1                     ( op1               ),
        .op2                     ( op2               )
    );
    /* inst decode begin */

    /* inst excute begin */
    

    Inst_excute  u_Inst_excute (
        .clk                     ( clk                 ),
        .reset                   ( reset               ),
        .alu_op                  ( alu_op              ),
        .op1                     ( op1                 ),
        .op2                     ( op2                 ),
        .read_ram_data           ( read_ram_data       ),
        .is_read_ram             ( read_ram_en         ),

        .write_reg_data          ( write_reg_data      )
    );
    /* inst excute begin */

    /* registers begin */
    

    Reg_file  u_Reg_file (
        .clk                     ( clk               ),
        .reset                   ( reset             ),
        .read_reg_addr1          ( read_reg_addr1    ),
        .read_reg_addr2          ( read_reg_addr2    ),
        .write_reg_en            ( id_write_reg_en   ),
        .write_reg_addr          ( id_write_reg_addr ),
        .write_reg_data          ( write_reg_data    ),

        .read_reg_data1          ( read_reg_data1    ),
        .read_reg_data2          ( read_reg_data2    )
    );
    /* registers end */
endmodule