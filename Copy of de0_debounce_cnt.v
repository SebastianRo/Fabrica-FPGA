// --------------------------------------------------------------------
// Copyright (c) 2013 by Sebastian Jacota 
// --------------------------------------------------------------------
// 
//
// Major Functions:	Decide if a part is compliant with defined dimensions of that part.
//							Controls and reads CCD sensor array
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
// Ver:| Author : Sebastian Jacota  | Mod. Date : 2013/03/14 | Changes Made: Initial Release
// --------------------------------------------------------------------

module de0_debounce_cnt
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_50,						//	50 MHz
		CLOCK_50_2,						//	50 MHz
		////////////////////	Push Button		////////////////////
		ORG_BUTTON,						//	Pushbutton[2:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[9:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0_D,							//	Seven Segment Digit 0
		HEX0_DP,							//	Seven Segment Digit DP 0
		HEX1_D,							//	Seven Segment Digit 1
		HEX1_DP,							//	Seven Segment Digit DP 1
		HEX2_D,							//	Seven Segment Digit 2
		HEX2_DP,							//	Seven Segment Digit DP 2
		HEX3_D,							//	Seven Segment Digit 3
		HEX3_DP,							//	Seven Segment Digit DP 3
		////////////////////////	LED		////////////////////////
		LEDG,								//	LED Green[9:0]
		////////////////////	GPIO	////////////////////////////
		GPIO0_CLKIN,					//	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT,					//	GPIO Connection 0 Clock Out Bus
		GPIO0_D,							//	GPIO Connection 0 Data Bus
		GPIO1_CLKIN,					//	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT,					//	GPIO Connection 1 Clock Out Bus
		GPIO1_D							//	GPIO Connection 1 Data Bus
	);

////////////////////////	Clock Input	 	////////////////////////
input				CLOCK_50;			//	50 MHz
input				CLOCK_50_2;			//	50 MHz
////////////////////////	Push Button		////////////////////////
input		[2:0]	ORG_BUTTON;			//	Pushbutton[2:0]
////////////////////////	DPDT Switch		////////////////////////
input		[9:0]	SW;					//	Toggle Switch[9:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;				//	Seven Segment Digit 0
output			HEX0_DP;				//	Seven Segment Digit DP 0
output	[6:0]	HEX1_D;				//	Seven Segment Digit 1
output			HEX1_DP;				//	Seven Segment Digit DP 1
output	[6:0]	HEX2_D;				//	Seven Segment Digit 2
output			HEX2_DP;				//	Seven Segment Digit DP 2
output	[6:0]	HEX3_D;				//	Seven Segment Digit 3
output			HEX3_DP;				//	Seven Segment Digit DP 3
////////////////////////////	LED		////////////////////////////
output	[9:0]	LEDG;					//	LED Green[9:0]
////////////////////////	GPIO	////////////////////////////////
input		[1:0]	GPIO0_CLKIN;		//	GPIO Connection 0 Clock In Bus
output	[1:0]	GPIO0_CLKOUT;		//	GPIO Connection 0 Clock Out Bus
input 	[31:0]GPIO0_D;				//	GPIO Connection 0 Data Bus
input		[1:0]	GPIO1_CLKIN;		//	GPIO Connection 1 Clock In Bus
output	[1:0]	GPIO1_CLKOUT;		//	GPIO Connection 1 Clock Out Bus
output	[31:0]GPIO1_D;				//	GPIO Connection 1 Data Bus

//==================================================================
//  FSM Coding
//==================================================================

parameter 			[2:0] SELECT_PART  						 = 3'b000,
								WAIT_START			 				 = 3'b001,
								//WAIT_START_MEMORIZE 	 			 = 3'b010,
								DETECT_START_PART_MEMORIZE 	 = 3'b010,
								MEMORIZE_PART						 = 3'b011,
								DETECT_START_PART_COMPARE	 	 = 3'b100,
								COMPARE_PART						 = 3'b101,
								DECIDE_PART							 = 3'b110,
								//SH_HIGH	 	 = 3'b010,
								//SH_LOW		 = 3'b011,
								//DECIDE_PART	 = 3'b100,
								//PROCESS_PART = 3'b101;	
								CCD_CALIBRATION					 = 3'b111;
	
localparam 					BUFFER_LENGTH = 1010; //1018?	

//defparam part_mem_inst.lpm_hint = "ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = ID_1";
						

//==================================================================
//  REG/WIRE declarations
//==================================================================
//wire           reset_n;        	// Reset

wire					  [2:0]	ORG_BUTTON;       // Button 
wire     			  [2:0]  BUTTON;				// Button after debounce
reg       						out_BUTTON_1;   	// Button1 Register output
reg       						out_BUTTON_2;   	// Button2 Register output
reg       						out_BUTTON_3;   	// Button2 Register output

reg					  [2:0]  state, state_next;

//reg					  [3:0]  iDIG_1;         	// 7SEG 1
reg				     [3:0]  iDIG_2;				// 7SEG 2
reg					  [9:0]	LED_Drive;	
reg					  [9:0]	LED_Drive_next;	

wire					  [3:0]  counter_value;
reg								en_count;
wire	 				  [9:0]  SW;
reg 					  [2:0]	cmd_valve;
reg								cmd_motor;
reg								cmd_vibrate;
wire								BUTTON0_fall;
wire								BUTTON1_fall;
wire								BUTTON2_fall;
wire 								CCD_mClk;
wire								CCD_Clk;
//reg								enable_clks;
//reg	  				 [18:0]  SH_cntr_low;
//reg								CCD_SH_go_high;
//reg								CCD_SH_low_cntr_en;
//reg	  				  [4:0]  SH_cntr_high;
//reg								CCD_SH_go_low;
//reg								CCD_SH_high_cntr_en;

wire								ccd_SH_fall;
wire								ccd_mclk_fall;
wire								ccd_mclk_rise;
//reg	[BUFFER_LENGTH-1:0]	CCD_data_local;
//reg	[BUFFER_LENGTH-1:0]	CCD_data_local_next;
wire	[BUFFER_LENGTH-1:0]	CCD_data;
reg 								en_CCD_read;
wire								CCD_data_valid;
wire								datavalid;
reg					  [4:0]	state_indicator;
reg	  				 [9:0]	part_mem_address;
reg	  				 [9:0]	part_mem_address_next;
reg				  [1023:0] 	part_mem_in;
wire				  [1023:0]	part_mem_out;
reg								part_mem_rden;
reg								part_mem_wren;
reg								part_mem_rden_next;
reg								part_mem_wren_next;
reg								part_ok;
reg								part_ok_next;
reg					[3:0]			selected_part;
reg					[3:0]			selected_part_next;
reg				  [BUFFER_LENGTH-1:0] 	CCD_calib; 
reg				  [BUFFER_LENGTH-1:0] 	CCD_calib_next; 
reg					[1023:0] 	part_mem_sample; 
reg									read_sample;
reg									read_sample_next;


       
//==================================================================
//  Structural coding
//==================================================================

// This is BUTTON[0] Debounce Circuit //
button_debouncer	button_debouncer_inst0(
	.clk     (CLOCK_50),
	.rst_n   (SW[0]),
	.data_in (ORG_BUTTON[0]),
	.data_out(BUTTON[0])			
	);
	
// This is BUTTON[1] Debounce Circuit //
button_debouncer	button_debouncer_inst1(
	.clk     (CLOCK_50),
	.rst_n   (SW[0]),
	.data_in (ORG_BUTTON[1]),
	.data_out(BUTTON[1])			
	);
	
// This is BUTTON[2] Debounce Circuit //
button_debouncer	button_debouncer_inst2(
	.clk     (CLOCK_50),
	.rst_n   (SW[0]),
	.data_in (ORG_BUTTON[2]),
	.data_out(BUTTON[2])			
	);

// This is SEG0 Display//
SEG7_LUT	SEG0(
				 .oSEG   (HEX0_D),
				 .oSEG_DP(HEX0_DP),
				 .iDIG   (counter_value)
				 );
				 
// This is SEG1 Display//
SEG7_LUT	SEG1(
				 .oSEG   (HEX1_D),
				 .oSEG_DP(HEX1_DP),
				 .iDIG   (selected_part)
				 );
				 
// This is SEG2 Display//
SEG7_LUT	SEG2(
				 .oSEG   (HEX2_D),
				 .oSEG_DP(HEX2_DP),
				 .iDIG   (iDIG_2)
				 );
				 
// This is SEG3 Display//				 
SEG7_LUT	SEG3(
				 .oSEG   (HEX3_D),
				 .oSEG_DP(HEX3_DP),
				 .iDIG   (state)
				 );
	
	
// This is the part counter//
counter part_count(
				 .clk(CLOCK_50),
				 .rst_n(SW[0]),
				 .en_count(en_count),
				 .count_up(BUTTON0_fall),
				 .count_down(BUTTON1_fall),
				 .data_out(counter_value)			
				 );
				 
// This module creates the clocks for the CCD sensor

//clock_ccd	clock_ccd_inst (
//	.areset ( SW[0] ),
//	.inclk0 ( CLOCK_50 ),
//	.c0 ( CCD_mClk ),
//	.c1 ( CCD_Clk )
//	);
	
edge_detector button0_edge(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(BUTTON[0]),
	.rise_out(),
	.fall_out(BUTTON0_fall)
	);
	
edge_detector button1_edge(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(BUTTON[1]),
	.rise_out(),
	.fall_out(BUTTON1_fall)
	);
	
edge_detector button2_edge(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(BUTTON[2]),
	.rise_out(),
	.fall_out(BUTTON2_fall)
	);	
	
edge_detector SH_input(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(GPIO0_D[31]),
	.rise_out(),
	.fall_out(ccd_SH_fall)
	);
		
edge_detector ccd_mclk_input(
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.signal_in(GPIO0_D[1]),
	.rise_out(ccd_mclk_rise),
	.fall_out(ccd_mclk_fall)
	);	
	
ccd_reader ccdreader (
	.clk(CLOCK_50),
	.rst_n(SW[0]),
	.data_in(GPIO0_D[3]),
	.en_pulse (en_CCD_read),
	.sh_pulse (ccd_SH_fall),
	.ccd_pulse (ccd_mclk_rise|ccd_mclk_fall),
	.data_out (CCD_data),
	.data_out_valid(datavalid)
);

part_mem	part_mem_inst (
	.address ( part_mem_address ),
	.clock ( CLOCK_50 ),
	.data ( part_mem_in ),
	.rden ( part_mem_rden ),
	.wren ( part_mem_wren ),
	.q ( part_mem_out )
	);
	
//ALT_OUTBUF_TRI CCD_Clk_Buff_Tri (
//						.i(CCD_Clk), 
//						.oe(enable_clks), 
//						.o(GPIO0_CLKOUT[0])	
//						);
//
//ALT_OUTBUF_TRI CCD_mClk_Buff_Tri (
//						.i(CCD_mClk), 
//						.oe(enable_clks), 
//						.o(GPIO0_CLKOUT[1])	
//						);
//						
//ALT_OUTBUF SH_OUT (.i(CCD_SH), .o(GPIO0_D[0]));
				 
//assign iDIG_2    = 4'd0;
//assign iDIG_3    = 4'd0;
//assign reset_n   = BUTTON[0]; 			 		 
//assign counter_1 = ((BUTTON[1] == 0) && (out_BUTTON_1 == 1)) ?1:0;
//assign counter_2 = ((BUTTON[2] == 0) && (out_BUTTON_2 == 1)) ?1:0;

//====================================================================
// After debounce output with register
//====================================================================
//always @ (posedge CLOCK_50 )
//	begin
//		out_BUTTON_1 <= BUTTON[0];
//		out_BUTTON_2 <= BUTTON[1];
//		out_BUTTON_3 <= BUTTON[2];
//	end

//====================================================================
// Edge detector
//====================================================================	

//always @ (posedge CLOCK_50 )
//	begin
//		rise_BUTTON_1 <= out_BUTTON_1 & !BUTTON[0];
//		fall_BUTTON_1 <= BUTTON[0] & !out_BUTTON_1;
//	end
//
//always @ (posedge CLOCK_50 )
//	begin
//		fall_BUTTON_3 <= out_BUTTON_3 & !BUTTON[2];
//		rise_BUTTON_3 <= BUTTON[2] & !out_BUTTON_2;
//	end	
	
//====================================================================
// Main FSM 
//====================================================================	

always @(posedge CLOCK_50)
    if (!SW[0]) begin
		state <= SELECT_PART;
		part_mem_address <= 10'b0;
//		CCD_data_local <= 1017'b0;
		part_ok <= 1'b0;
		selected_part <= 4'b0;
		CCD_calib <= 1024'b0;
		part_mem_wren <= 1'b0;
		part_mem_rden <= 1'b0;
		part_mem_sample <= 1024'b0;
		read_sample <= 1'b0;
    end else begin
		state <= state_next;
		part_mem_address <= part_mem_address_next;
//		CCD_data_local <= CCD_data_local_next;
		part_ok <= part_ok_next;
		selected_part <= selected_part_next;
		CCD_calib <= CCD_calib_next; 
		part_mem_wren <= part_mem_wren_next;
		part_mem_rden <= part_mem_rden_next;
		part_mem_sample <= part_mem_out;
		read_sample <= read_sample_next;
	 end

always @ (*)
	begin
//			iDIG_1  = 4'hF;
			iDIG_2  = 4'hF;
			cmd_valve[2:0] = 3'h0;
			cmd_motor	= 1'b0;
			cmd_vibrate = 1'b0;
			en_count = 1'b0;
			state_next = SELECT_PART;
//			CCD_SH_low_cntr_en = 1'b0;
//			CCD_SH_high_cntr_en = 1'b0;
			en_CCD_read = 1'b0;
			part_mem_address_next = part_mem_address;
			part_ok_next = part_ok;
			part_mem_in = 1024'b0;
			selected_part_next = selected_part;
			CCD_calib_next = CCD_calib;
			part_mem_wren_next = part_mem_wren;
			part_mem_rden_next = part_mem_rden;
			read_sample_next = read_sample;
			
						
			case(state)
			
			SELECT_PART:
				begin
					en_count = 1'b1;
					if (BUTTON2_fall)
					begin
						state_next = WAIT_START;
						selected_part_next = counter_value;
						en_count = 1'b0;
					end
					else begin
						state_next = SELECT_PART;
					end
				end
				
			WAIT_START:
				begin
					//en_count = 1'b0;
					case ({BUTTON2_fall,BUTTON1_fall})
//					2'b10: state_next = SH_HIGH;
					2'b10: begin
								en_CCD_read = 1'b1;
								state_next = CCD_CALIBRATION;
							 end
					2'b01: state_next = SELECT_PART;
					default: state_next = WAIT_START;
					endcase
				end
			
			CCD_CALIBRATION:
				begin
					en_CCD_read = 1'b1;
					if (datavalid) begin
						CCD_calib_next = CCD_data;
						if (selected_part == 4'h0) begin
							read_sample_next = 1'b0;
							part_mem_rden_next = 1'b0;
							part_mem_wren_next = 1'b1;
							state_next = DETECT_START_PART_MEMORIZE;
						end
						else begin
							read_sample_next = 1'b0;
							part_mem_address_next = 10'b0;
							part_ok_next = 1'b1;
							part_mem_rden_next = 1'b1;
							part_mem_wren_next = 1'b0;
							state_next = DETECT_START_PART_COMPARE;
						end
					end else state_next = CCD_CALIBRATION;					
				 end
		
			DETECT_START_PART_MEMORIZE:
				begin
					read_sample_next = !read_sample_next;
					en_CCD_read = 1'b1;
					if (read_sample) begin
						if (datavalid) begin
							if (CCD_data == CCD_calib) state_next = DETECT_START_PART_MEMORIZE;
							else begin
								part_mem_in = CCD_data;
								part_mem_rden_next = 1'b0;
								part_mem_wren_next = 1'b1;
								part_mem_address_next = part_mem_address_next + 1'b1;
								state_next = MEMORIZE_PART;
							end
						end else state_next = DETECT_START_PART_MEMORIZE;
					end else state_next = DETECT_START_PART_MEMORIZE;
				end	
				
			MEMORIZE_PART:
				begin
					read_sample_next = !read_sample_next;
					en_CCD_read = 1'b1;
					if (read_sample) begin
						if (datavalid) begin
							if (CCD_data == CCD_calib) begin
								part_mem_wren_next = 1'b0;
								state_next = SELECT_PART;
							end else begin
								part_mem_in = CCD_data;
								part_mem_address_next = part_mem_address_next + 1'b1;
								state_next = MEMORIZE_PART;
							end
						end else state_next = MEMORIZE_PART;
					end else state_next = MEMORIZE_PART;
				end	
				
			DETECT_START_PART_COMPARE:
				begin
					read_sample_next = !read_sample_next;
					en_CCD_read = 1'b1;
					if (read_sample) begin
						if (datavalid) begin
							if (CCD_data == CCD_calib) state_next = DETECT_START_PART_COMPARE;
							else begin
								if (CCD_data != part_mem_sample) part_ok_next = 1'b0;
								part_mem_rden_next = 1'b1;
								part_mem_wren_next = 1'b0;
								part_mem_address_next = part_mem_address_next + 1'b1;
								state_next = COMPARE_PART;
							end
						end else state_next = DETECT_START_PART_COMPARE;
					end else state_next = DETECT_START_PART_COMPARE;
				end	
				
			COMPARE_PART:
				begin
					read_sample_next = !read_sample_next;
					en_CCD_read = 1'b1;
					if (read_sample) begin
						if (datavalid) begin
							if (CCD_data == CCD_calib) begin
								state_next = SELECT_PART;
								part_mem_rden_next = 1'b0;
							end else begin
								if ({7'b0,CCD_data} != part_mem_sample) part_ok_next = 1'b0;
								part_mem_address_next = part_mem_address_next + 1'b1;
								part_mem_rden_next = 1'b1;
								part_mem_wren_next = 1'b0;
								state_next = COMPARE_PART;
							end
						end else state_next = COMPARE_PART;
					end else state_next = COMPARE_PART;
				end		
					
				
//			SH_HIGH:	
//				begin
//					CCD_SH		= 1'b1;
//					enable_clks = 1'b1;
//					CCD_SH_high_cntr_en = 1'b1;
//					if (CCD_SH_go_low) 
//					begin
//						CCD_SH_high_cntr_en = 1'b0;
//						state_next = SH_LOW;
//					end else state_next = SH_HIGH;
//				end
//				
//			SH_LOW:	
//				begin
//					CCD_SH		= 1'b0;
//					enable_clks = 1'b1;
//					CCD_SH_low_cntr_en = 1'b1;
//					if (CCD_SH_go_high) 
//					begin
//						CCD_SH_low_cntr_en = 1'b0;
//						state_next = SH_HIGH;
//					end else if (BUTTON2_fall) state_next = WAIT_START;
//					else state_next = SH_LOW;
//				end
			
			default: state_next = SELECT_PART;
			
			endcase
	end

assign  LEDG = LED_Drive;
assign  GPIO1_D[3] = ccd_SH_fall;
assign  GPIO1_D[5] = ccd_mclk_rise|ccd_mclk_fall;
assign  GPIO1_D[7] = GPIO0_D[31];
assign  GPIO1_D[9] = GPIO0_D[1];
assign  GPIO1_D[11] = GPIO0_D[3];
assign  GPIO1_D[13] = datavalid;
assign  GPIO1_D[15] = part_ok;

//assign LEDG[0] = (part_ok) ? 1'b1 : 1'b0;

always @(*)
begin
	LED_Drive_next = LED_Drive;
	if (datavalid /*&& (state == SH_HIGH)*/) begin
						LED_Drive_next[0] = |CCD_data[99:0];
						LED_Drive_next[1] = (|(CCD_data[199:100]));
						LED_Drive_next[2] = (|(CCD_data[299:200]));
						LED_Drive_next[3] = (|(CCD_data[399:300]));
						LED_Drive_next[4] = (|(CCD_data[499:400]));
						LED_Drive_next[5] = (|(CCD_data[599:500]));
						LED_Drive_next[6] = (|(CCD_data[699:600]));
						LED_Drive_next[7] = (|(CCD_data[799:700]));
						LED_Drive_next[8] = (|(CCD_data[899:800]));
						LED_Drive_next[9] = (|(CCD_data[BUFFER_LENGTH-1:900]));
	end
end

always @ (posedge CLOCK_50)
begin
	if (!SW[0]) LED_Drive <= 10'b0;
	else 			LED_Drive <= LED_Drive_next;
end

//always @ (posedge CLOCK_50)
//begin
//	if (!SW[0]) 
//	begin
//		SH_cntr_high <= 5'd25;
//		CCD_SH_go_low <= 1'b0;
//	end else begin		
//		if (CCD_SH_high_cntr_en) begin
//			if (|SH_cntr_high) SH_cntr_high <= SH_cntr_high - 1'b1;
//			else CCD_SH_go_low <= 1'b1;
//		end else	begin
//			SH_cntr_high <= 5'd25;
//			CCD_SH_go_low <= 1'b0;
//		end
//	end
//end
//
//always @ (posedge CLOCK_50)
//begin
//	if (!SW[0]) 
//	begin
//		SH_cntr_low <= 19'd499975;
//		CCD_SH_go_high <= 1'b0;
//	end else begin
//		if (CCD_SH_low_cntr_en) begin
//			if (|SH_cntr_low) SH_cntr_low <= SH_cntr_low - 1'b1;
//			else CCD_SH_go_high <= 1'b1;
//		end else	begin
//			SH_cntr_low <= 19'd499975;
//			CCD_SH_go_high <= 1'b0;
//		end
//	end
//end


			
endmodule					
	
//always @ (posedge CLOCK_50)
//begin
//	if (!SW[0]) SH_cntr <= 19'd500_000;
//	else begin
//		if (CCD_SH_cntr_en) begin
//			if (|SH_cntr) begin
//				SH_cntr <= SH_cntr - 1;
//				if 
//			else begin
//				SH_cntr <= 19'd500_000;
//				CCD_SH_go_high <= 1'b1;
//			end

	
//====================================================================
// Display process
//====================================================================
//always @ (posedge CLOCK_50 or negedge reset_n)
//	begin
//		if(!reset_n)
//			begin
//				iDIG_0  <= 0;
//				iDIG_1  <= 0;
//			end
//		else begin
//				if(counter_1)
//					begin
//						if(iDIG_0 >= 4'd15)
//							begin
//								iDIG_0 <= 4'd0;
//								iDIG_1 <= iDIG_1 + 1'd1;
//					        end
//					    else begin
//								iDIG_0 <= iDIG_0 +1'd1;
//					         end
//					end
//				else if(counter_2)
//					 begin
//						if(iDIG_0 < 1)
//							begin
//								iDIG_0 <= 4'd15;
//								iDIG_1 <= iDIG_1 - 1'd1;
//					        end
//						else if(iDIG_1 == 0 && iDIG_0 == 0 )
//								begin
//									iDIG_0 <= 4'd15;
//								end
//					    else begin
//								iDIG_0 <= iDIG_0 - 1'd1;
//					         end
//					 end
//				else begin
//						iDIG_0 <= iDIG_0;
//						iDIG_1 <= iDIG_1;
//					 end
//		     end
//	end
//endmodule