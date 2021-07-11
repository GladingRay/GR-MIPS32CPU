`timescale  1ns / 1ps

module tb_Control_ram;

// Control_ram Parameters
parameter PERIOD  = 10;


// Inst_fetch Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   is_branch                            = 0 ;
reg   [31:0]  target_pc                    = 0 ;

// Inst_fetch Outputs
wire  [31:0]  pc     ;



// Control_ram Inputs
reg   [31:0]  inst_addr                    = 0 ;
reg   id_read_ram_en                       = 0 ;
reg   [31:0]  id_read_ram_addr             = 0 ;
reg   [3:0]  read_be                       = 0 ;
reg   wb_write_ram_en                      = 0 ;
reg   [31:0]  wb_write_ram_addr            = 0 ;
reg   wb_write_ram_data                    = 0 ;
reg   [3:0]  write_be                      = 0 ;

// Control_ram Outputs
wire  pc_stall                             ;    
wire  [31:0]  inst                         ;    
wire  [31:0]  id_read_ram_data             ;    
wire  id_stall                             ;    
wire  base_ram_ce_n                        ;    
wire  base_ram_oe_n                        ;
wire  base_ram_we_n                        ;
wire  [3:0]  base_ram_be_n                 ;
wire  [19:0]  base_ram_addr                ;
wire  ext_ram_ce_n                         ;
wire  ext_ram_oe_n                         ;
wire  ext_ram_we_n                         ;
wire  [3:0]  ext_ram_be_n                  ;
wire  [19:0]  ext_ram_addr                 ;

// Control_ram Bidirs
wire  [31:0]  base_ram_data                ;
wire  [31:0]  ext_ram_data                 ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD/2) reset  =  1;
    #(PERIOD*2) reset = 0;
end

Inst_fetch  u_Inst_fetch (
    .clk                     ( clk               ),
    .reset                   ( reset             ),
    .stall_pc                ( pc_stall          ),
    .is_branch               ( is_branch         ),
    .target_pc               ( target_pc  [31:0] ),
    .current_pc              ( pc         [31:0] )
);



Control_ram  u_Control_ram (
    .inst_addr               ( pc          [31:0] ),
    .id_read_ram_en          ( id_read_ram_en            ),
    .id_read_ram_addr        ( id_read_ram_addr   [31:0] ),
    .read_be                 ( read_be            [3:0]  ),
    .wb_write_ram_en         ( wb_write_ram_en           ),
    .wb_write_ram_addr       ( wb_write_ram_addr  [31:0] ),
    .wb_write_ram_data       ( wb_write_ram_data         ),
    .write_be                ( write_be           [3:0]  ),

    .pc_stall                ( pc_stall                  ),
    .inst                    ( inst               [31:0] ),
    .id_read_ram_data        ( id_read_ram_data   [31:0] ),
    .id_stall                ( id_stall                  ),
    .base_ram_ce_n           ( base_ram_ce_n             ),
    .base_ram_oe_n           ( base_ram_oe_n             ),
    .base_ram_we_n           ( base_ram_we_n             ),
    .base_ram_be_n           ( base_ram_be_n      [3:0]  ),
    .base_ram_addr           ( base_ram_addr      [19:0] ),
    .ext_ram_ce_n            ( ext_ram_ce_n              ),
    .ext_ram_oe_n            ( ext_ram_oe_n              ),
    .ext_ram_we_n            ( ext_ram_we_n              ),
    .ext_ram_be_n            ( ext_ram_be_n       [3:0]  ),
    .ext_ram_addr            ( ext_ram_addr       [19:0] ),

    .base_ram_data           ( base_ram_data      [31:0] ),
    .ext_ram_data            ( ext_ram_data       [31:0] )
);

// BaseRAM 仿真模型
sram_model base1(/*autoinst*/
            .DataIO(base_ram_data[15:0]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[0]),
            .UB_n(base_ram_be_n[1]));
sram_model base2(/*autoinst*/
            .DataIO(base_ram_data[31:16]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[2]),
            .UB_n(base_ram_be_n[3]));
// ExtRAM 仿真模型
sram_model ext1(/*autoinst*/
            .DataIO(ext_ram_data[15:0]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[0]),
            .UB_n(ext_ram_be_n[1]));
sram_model ext2(/*autoinst*/
            .DataIO(ext_ram_data[31:16]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[2]),
            .UB_n(ext_ram_be_n[3]));

parameter BASE_RAM_INIT_FILE = "E:\\aGr_CPU\\lab1.bin"; //BaseRAM初始化文件，请修改为实际的绝对路径
parameter EXT_RAM_INIT_FILE = "E:\\aGr_CPU\\ext_ram.bin";    //ExtRAM初始化文件，请修改为实际的绝对路径

// 从文件加载 BaseRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(BASE_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open BaseRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("BaseRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        base1.mem_array0[i] = tmp_array[i][24+:8];
        base1.mem_array1[i] = tmp_array[i][16+:8];
        base2.mem_array0[i] = tmp_array[i][8+:8];
        base2.mem_array1[i] = tmp_array[i][0+:8];
    end
end

// 从文件加载 ExtRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(EXT_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open ExtRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("ExtRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        ext1.mem_array0[i] = tmp_array[i][24+:8];
        ext1.mem_array1[i] = tmp_array[i][16+:8];
        ext2.mem_array0[i] = tmp_array[i][8+:8];
        ext2.mem_array1[i] = tmp_array[i][0+:8];
    end
end

initial
begin
    is_branch = 0 ;
    target_pc = 0 ;
    # (PERIOD*5) ;
    id_read_ram_en = 1 ;
    id_read_ram_addr = 32'h80000010 ;
    read_be = 0 ;
    wb_write_ram_en = 0 ;
    wb_write_ram_addr = 32'h80000010 ;
    wb_write_ram_data = 32'h12345678 ;
    write_be = 0 ;
    # (PERIOD*5) ;
    $finish ;
end


endmodule