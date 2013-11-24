// --------------------------------------------------------------------
// Copyright (c) 2013 by Sebastian Jacota 
// --------------------------------------------------------------------
// 
//
// Major Functions:	Decide if a part is compliant with defined dimensions of that part.
//							Controls and reads CCD sensor array
//
// --------------------------------------------------------------------
// Revision History :
// --------------------------------------------------------------------
// Ver:| Author : Sebastian Jacota  | Mod. Date : 2013/03/14 | Changes Made: Initial Release
// --------------------------------------------------------------------

module de0_debounce_cnt
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_50,						//	50 MHz
		CLOCK_50_2,						//	50 MHz
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[9:0]
		////////////////////	GPIO	////////////////////////////
		GPIO0_CLKIN,					//	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT,					//	GPIO Connection 0 Clock Out Bus
		GPIO1_CLKIN,					//	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT					//	GPIO Connection 1 Clock Out Bus
);

////////////////////////	Clock Input	 	////////////////////////
input				CLOCK_50;			//	50 MHz
input				CLOCK_50_2;			//	50 MHz
////////////////////////	DPDT Switch		////////////////////////
input		[9:0]	SW;					//	Toggle Switch[9:0]
////////////////////////	GPIO	////////////////////////////////
input		[1:0]	GPIO0_CLKIN;		//	GPIO Connection 0 Clock In Bus
output	[1:0]	GPIO0_CLKOUT;		//	GPIO Connection 0 Clock Out Bus
input		[1:0]	GPIO1_CLKIN;		//	GPIO Connection 1 Clock In Bus
output	[1:0]	GPIO1_CLKOUT;		//	GPIO Connection 1 Clock Out Bus


//==================================================================
//  REG/WIRE declarations
//==================================================================

wire	 				 [ 9:0]	SW;							// Reset Switch

wire					 [ 2:0]	ORG_BUTTON;       		// Button 
wire     			 [ 2:0]	BUTTON;						// Button after debounce

wire								ccd_clk;
wire								m_clk;
wire								sh_clk;
      
//==================================================================
//  Structural coding
//==================================================================

TFF for_ccd(
	.t(1'b1), 
	.clk(ccd_clk), 
	.clrn(), 
	.prn(), 
	.q(GPIO0_CLKOUT[0])
	);
	
TFF for_m(
	.t(1'b1), 
	.clk(m_clk), 
	.clrn(), 
	.prn(), 
	.q(GPIO0_CLKOUT[1])
	);
	
TFF for_sh(
	.t(1'b1), 
	.clk(sh_clk), 
	.clrn(), 
	.prn(), 
	.q(GPIO1_CLKOUT[0])
	);
			 
// This module creates the clocks for the CCD sensor

clock_ccd	clock_ccd_inst (
	.areset ( !SW[0] ),
	.inclk0 ( CLOCK_50 ),
	.c0 ( ccd_clk ),
	.c1 ( m_clk )
	);
	
sh_generator sh_generator_inst (
	.rst_n (SW[0]),
	.clk (CLOCK_50),
	.data_out (sh_clk )
	);

//ALT_OUTBUF_TRI CCD_Clk_Buff_Tri (
//						.i(CCD_Clk), 
//						.oe(enable_clks), 
//						.o(GPIO0_CLKOUT[0])	
//						);
//
//ALT_OUTBUF_TRI CCD_mClk_Buff_Tri   
//						.i(CCD_mClk), 
//						.oe(enable_clks), 
//						.o(GPIO0_CLKOUT[1])	
//						);
//						
//ALT_OUTBUF SH_OUT (.i(CCD_SH), .o(GPIO0_D[0]));


endmodule					
