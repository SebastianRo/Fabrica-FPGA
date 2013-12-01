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
		GPIO1_CLKOUT,					//	GPIO Connection 1 Clock Out Bus
		GPIO0_D							//	GPIO Connection 1 Data Bus
);

parameter 			[3:0] WAIT_START			 				 = 2'b00,
								DETECT_START_PART_MEMORIZE 	 = 2'b01,
								MEMORIZE_PART						 = 2'b10;
								
localparam BUFFER_LENGTH = 882; //1018?

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
output	[31:0]GPIO0_D;				//	GPIO Connection 1 Data Bus


//==================================================================
//  REG/WIRE declarations
//==================================================================

wire	 				 [ 9:0]	SW;							// Reset Switch

wire					 [ 2:0]	ORG_BUTTON;       		// Button 
wire     			 [ 2:0]	BUTTON;						// Button after debounce

wire								ccd_clk;
wire								m_clk;
wire								sh_clk;
wire								internal_ccd_clk;

wire								BUTTON0_fall;
wire 								ccd_SH_fall;
wire 								ccd_SH_rise;
wire								ccd_clk_rise;
wire 								ccd_clk_fall;
reg								en_CCD_read;
wire								datavalid;
wire 					  [11:0] CCD_data;

reg						[1:0] state, state_next;

reg	  				 [ 9:0]	part_mem_address;			// Memory address
reg	  				 [ 9:0]	part_mem_address_next;	// Registered memory address
reg				    [11:0]	part_mem_in;				// Memory input
reg				    [11:0]	part_mem_in_reg;			// Registered Memory input
//wire				    [10:0]	part_mem_out;				// Memory output
reg								part_mem_wren;				// Memory Write Enable signal
reg								part_mem_wren_next;		// Registered Memory Write Enable signal

reg								en_CCD_read_reg;

      
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

TFF for_ccd_int(
	.t(1'b1), 
	.clk(ccd_clk), 
	.clrn(), 
	.prn(), 
	.q(internal_ccd_clk)
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
	.c1 ( m_clk ),
	.c2 (  )
	);
	
// This module creates the Sample/Hold signal
	
sh_generator sh_generator_inst (
	.rst_n (SW[0]),
	.clk (CLOCK_50),
	.data_out (sh_clk )
	);

// This is BUTTON[0] Debounce Circuit //
button_debouncer	button_debouncer_inst0(
	.clk     (CLOCK_50),
	.rst_n   (SW[0]),
	.data_in (ORG_BUTTON[0]),
	.data_out(BUTTON[0])			
	);	
	
// This module detects a falling edge on Button 0
edge_detector button0_edge(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(BUTTON[0]),
	.rise_out(),
	.fall_out(BUTTON0_fall)
	);

// This module detects the rising and falling edge on the SH signal
edge_detector SH_input(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(sh_clk),
	.rise_out(ccd_SH_rise),
	.fall_out(ccd_SH_fall)
	);

// This module detects the rising and falling edges of the CCD clock	
edge_detector ccd_mclk_input(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(internal_ccd_clk),
	.rise_out(ccd_clk_rise),
	.fall_out(ccd_clk_fall)
	);		
	
// This module handles the CCD Reader logic
ccd_reader ccdreader (
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.data_in(GPIO0_D[0]),
	.enable (en_CCD_read),
	.sh_pulse_fall (ccd_SH_fall),
	.sh_pulse_rise(ccd_SH_rise),
	.ccd_pulse (ccd_clk_rise|ccd_clk_fall),
	.data_out (CCD_data),
	.data_out_valid(datavalid),
	.readall_samples()
);


part_mem	part_mem_inst (
	.address ( part_mem_address ),
	.clock ( CLOCK_50 ),
	.data ( part_mem_in ),
	.rden (  ),
	.wren ( part_mem_wren ),
	.q (  )
	);

always @(posedge CLOCK_50)
begin
	if (!SW[0]) begin
		state 				<= WAIT_START;
				
		en_CCD_read_reg   <= 1'b0;
		
		part_mem_address 	<= 10'b0;
		part_mem_wren 		<= 1'b0;
		part_mem_in_reg	<= 11'b0;
						
	end else begin
		state 				<= state_next;
		
		en_CCD_read_reg   <= en_CCD_read;
		
		part_mem_address  <= part_mem_address_next;
		part_mem_wren 	 	<= part_mem_wren_next;
		part_mem_in_reg	<= part_mem_in;
	end
end	

always @ (*)
begin
		state_next = WAIT_START;
		
		en_CCD_read = en_CCD_read_reg;
		
		part_mem_address_next = part_mem_address;
		part_mem_wren_next = part_mem_wren;
		part_mem_in = part_mem_in_reg;		
								
		case(state)
							
		WAIT_START:
		begin
			part_mem_wren_next = 1'b0;
			part_mem_address_next = 10'b0;
			if (BUTTON0_fall) begin
				part_mem_wren_next = 1'b1;
				state_next = DETECT_START_PART_MEMORIZE;
			end
			else state_next = WAIT_START;
		end

		DETECT_START_PART_MEMORIZE:
		begin
			en_CCD_read = 1'b1;
			if (datavalid) begin
				if (CCD_data == BUFFER_LENGTH) state_next = DETECT_START_PART_MEMORIZE;
				else begin	
					state_next = MEMORIZE_PART;
				end
			end else state_next = DETECT_START_PART_MEMORIZE;
		end	
				
		MEMORIZE_PART:
		begin
			en_CCD_read = 1'b1;
			if (datavalid) begin
				if (CCD_data == BUFFER_LENGTH) begin
					part_mem_wren_next = 1'b0;
					en_CCD_read = 1'b0;
					state_next = WAIT_START;
				end else begin
					if( CCD_data != 11'b0) begin
						part_mem_in = CCD_data;
						part_mem_address_next = part_mem_address_next + 1'b1;
					end
					state_next = MEMORIZE_PART;
				end
			end else state_next = MEMORIZE_PART;
		end	
				
	default: state_next = WAIT_START;
	
	endcase
end

endmodule					
