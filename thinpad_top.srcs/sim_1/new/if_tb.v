`timescale  1ns / 1ps

module tb_Inst_fetch;

// Inst_fetch Parameters
parameter PERIOD  = 10;


// Inst_fetch Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   stall_pc                             = 0 ;
reg   is_branch                            = 0 ;
reg   [31:0]  target_pc                    = 0 ;

// Inst_fetch Outputs
wire  [31:0]  pc                           ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) reset  =  1;
end

Inst_fetch  u_Inst_fetch (
    .clk                     ( clk               ),
    .reset                   ( reset             ),
    .stall_pc                ( stall_pc          ),
    .is_branch               ( is_branch         ),
    .target_pc               ( target_pc  [31:0] ),

    .pc                      ( pc         [31:0] )
);

initial
begin
    # (10*PERIOD)
    # (2*PERIOD) stall_pc = 1;
    # (PERIOD) stall_pc = 0;
    # (10*PERIOD)
    $finish;
end

endmodule