module ccd_reader	(
	input clk,
	input rst_n,
	input data_in,
	input enable,
	input sh_pulse_rise,
	input sh_pulse_fall,
	input ccd_pulse,
	output reg [11:0] data_out,
	output reg data_out_valid,
	output reg readall_samples
);
					
parameter 	 [1:0] IDLE_CCD_READ  = 2'b00,
                   DUMMY_CCD_READ = 2'b01,
                   READ_CCD_ONE 	 = 2'b10,
                   READ_CCD_ZERO  = 2'b11;
						
reg			 [10:0]	counter;
reg			 [1:0]	state, state_next;
//reg						count_up_dld;
reg			 [10:0]	counter_next;
reg			 [11:0]	data_out_next;
reg						signal_dld;
reg						ccd_pulse_chng;
reg						dummy_over;

reg						data_debounced;
reg			[10:0]	counter_debounce;			
//=======================================================
//  Structural coding
//=======================================================


always	@(posedge clk)
begin
	if	(!rst_n)  state <= #1 IDLE_CCD_READ;
   else         state <= #1 state_next;
end

always @(*)
begin
		state_next = 3'bX;
		
		if (enable)
		
			case (state)
			
			IDLE_CCD_READ:  begin	
								if (sh_pulse_fall) begin	
									if (data_in == 1'b1)    state_next = READ_CCD_ONE;
									else						   state_next = READ_CCD_ZERO;
								end else 						state_next = IDLE_CCD_READ;
							end
					 
			READ_CCD_ONE:	begin
								if (readall_samples)			state_next = IDLE_CCD_READ;
								else begin
										if (ccd_pulse_chng)  state_next = READ_CCD_ZERO;
										else						state_next = READ_CCD_ONE;			
								end
							end
			
			READ_CCD_ZERO:	begin
								if (readall_samples)			state_next = IDLE_CCD_READ;
								else begin
										if (ccd_pulse_chng)  state_next = READ_CCD_ONE;
										else						state_next = READ_CCD_ZERO;			
								end
							end
							  
			endcase
		
		else state_next = IDLE_CCD_READ;
		 
end

always @(*)
begin
	counter_next = counter;
	data_out_next = data_out;
	case(state)
	
		IDLE_CCD_READ:  begin
							counter_next = 11'b0;
							data_out_next = 12'b0;
						end
		
		READ_CCD_ONE:	begin
							if (!sh_pulse_rise) begin
								if (ccd_pulse) counter_next = counter_next + 1'b1;
								if (ccd_pulse_chng) data_out_next = {1'b1, counter};
							end else data_out_next = {1'b1, counter};
						end
		
		READ_CCD_ZERO:  begin
							if (!sh_pulse_rise) begin
								if (ccd_pulse) counter_next = counter_next + 1'b1;
								if (ccd_pulse_chng) data_out_next = {1'b0, counter};
							end else data_out_next = {1'b0, counter};
						end
		
	endcase
end

always @(posedge clk)
begin
	if	(!rst_n)  begin
			data_out <= #1 12'h0;
			data_out_valid <= #1 1'b0;
			readall_samples <= #1 1'b0;
			counter <= #1 11'b0;
						
   end else  begin
			data_out <= #1 data_out_next;
			data_out_valid <= #1 1'b0;
			readall_samples <= #1 1'b0;
			counter <= #1 counter_next;
		
			case(state_next)
				
					IDLE_CCD_READ: data_out <= #1 12'h0;	
														
					READ_CCD_ONE: begin
										 if (sh_pulse_rise) begin
											data_out_valid <= #1 1'b1;
											readall_samples <= #1 1'b1;
										 end else if (ccd_pulse_chng) begin
											data_out_valid <= #1 1'b1;
										 end
					end
					
					READ_CCD_ZERO: begin
										 if (sh_pulse_rise) begin
											data_out_valid <= #1 1'b1;
											readall_samples <= #1 1'b1;
										 end else if (ccd_pulse_chng) begin
											data_out_valid <= #1 1'b1;
										 end
					end
					
			endcase
		
	end
				
end

//this circuit detects a transition in the CCD pulse
// !!!!!!!!!!!! REVIEW THIS !!!!!!!!!! WHY THE DATA_DEBOUNCED??? !!!!!!!!!!!!!

always @ (posedge clk )
begin
	if (ccd_pulse) data_debounced <= #1 data_in;
	signal_dld <= #1 data_debounced;
	ccd_pulse_chng <= #1(signal_dld & !data_debounced) | (data_debounced & !signal_dld);
end
	
endmodule
