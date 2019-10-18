/****************************************Copyright (c)**************************************************
**                                      Adong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           LED
** Last modified Date:  2017-6-1
** Last Version:        1.1
** Descriptions:        LED
**------------------------------------------------------------------------------------------------------
** Created by:          adong
** Created date:        2017-6-1
** Version:             1.0
** Descriptions:        USB 68013 TEST SPEED
**
********************************************************************************************************/

module fpga_master_sync (
input                 inclk0               , // system clock;

input                 flaga                , // EP2 empty flag
input                 flagd                , // EP6 full flag

inout      [15:0]	    fdata                , // FIFO data lines.
output reg [ 1:0]     faddr                , // FIFO select lines 
output reg [ 3:0]     gstate               , // debug lines
output reg            slrd                 , // 
output reg            slwr                 , //
output reg            sloe                 , // Slave Output Enable control 
output wire led8
);

wire sys_clk ;

reg [6:0]                curr_st             ;    // FSM current state
reg [6:0]                next_st             ;    // FSM next    state

reg [7:0]               fifodatabyte        ;    
reg [15:0]               fdata_tmp           ;    

reg                      sloe_i             ;    
reg                      slrd_i             ;    
reg                      slwr_i             ;    
reg [15:0]               faddr_i            ;    
reg [ 3:0]               gstate_i           ;    


parameter A = 4'b0000;
parameter B = 4'b0001;
parameter C = 4'b0010;
parameter D = 4'b0011;
parameter E = 4'b0100;
parameter F = 4'b0101;
parameter G = 4'b0110;
parameter H = 4'b0111;

//**************************************************************************
//**                             Main Code
//**************************************************************************/

/*
// 50M分频到47M
pll (
.inclk0  ( inclk0  )             ,
.c0      ( sys_clk )      
 );
*/
assign sys_clk = inclk0;

assign led8 = 0;

// 时序逻辑输出，有更好的时序特性
//always @(posedge sys_clk )begin
always @( * )begin
	slrd	  <= slrd_i;
	slwr	  <= slwr_i;
	faddr   <= faddr_i;
	gstate  <= gstate_i;
	sloe 	  <= sloe_i;
end 

// 状态机控制状态跳转
always @( posedge sys_clk ) begin 
    curr_st <= next_st;
end

//FSM state logic 
always @(*) begin 
    case (curr_st) 
        A: begin  
                next_st = E;
            end
        B: begin 
                next_st = A;
            end
        C: begin 
                next_st = A;
            end
        D: begin 
                next_st = A;
            end
        E: begin 
             if ( flagd == 1'b1 )		
                next_st = E;
			    else 
                next_st = A;
           end
        F: begin 
                next_st = A;
            end
        G: begin 
                next_st = A;
            end
        default: next_st = A;
    endcase
end

always @(posedge sys_clk )begin
    if ( curr_st == A ) begin
		sloe_i        <= 1'b1    ;                         
		faddr_i       <= 2'b10   ;        
		slrd_i        <= 1'b1    ;      
		slwr_i        <= 1'b1    ;      
		fifodatabyte  <= 8'h0   ;
		gstate_i      <= 4'b0001 ;
	end
	else if ( curr_st == E ) begin
		sloe_i        <= 1'b1    ;                         
		faddr_i       <= 2'b10   ;        
		slrd_i        <= 1'b1    ;      
		if ( flagd == 1'b1 ) begin              //不满则一直写FIFO，该程序只有SLAVE FIFO 写，没有读控制，读的话是从FIFO中读数据到FPGA里面。
		    slwr_i        <= 1'b0    ;      
          fdata_tmp     <= {fifodatabyte+1,fifodatabyte};
			 fifodatabyte  <= fifodatabyte + 2'd2  ;
		 end
       else 
          slwr_i        <= 1'b1    ;      
	end
	else begin
		sloe_i   <= 1'b1    ;                         
		faddr_i  <= 2'b00   ;        
		slrd_i   <= 1'b1    ;      
		slwr_i   <= 1'b1    ;      
		gstate_i <= 4'b1000 ;
	end
end 

assign fdata = fdata_tmp ;

endmodule
