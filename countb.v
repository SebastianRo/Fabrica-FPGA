module binary_counter
#(parameter MS_ON=7900)
(
	input clk, enable, rst_n, pulse100ms,
	output reg counting
);

	localparam 	 [1:0] IDLE_COUNTB  		= 2'b00,
							 ACTIVE_COUNTB		= 2'b01,
							 STAY_ON_STATE    = 2'b11;
	localparam STAY_ON = 500;
						 
	reg [12:0] counter;
	reg [1:0] state;

	// Reset if needed, or increment if counting is enabled
	always @ (posedge clk)
	begin
		if (rst_n)	begin
			counter  <= #1 MS_ON;
			counting <= #1 1'b0;
			state <= #1 IDLE_COUNTB;
		end else begin

		case(state)
		
		IDLE_COUNTB: begin
								counter  <= #1 MS_ON;
								counting <= #1 1'b0;
								if (enable) state <= #1 ACTIVE_COUNTB;
								else			state <= #1 IDLE_COUNTB;
							end
									
		ACTIVE_COUNTB: begin
								counting <= #1 1'b0;
								if (pulse100ms) counter  <= #1 counter - 1'b1;
								if (~|counter) begin
													state <= #1 STAY_ON_STATE;
													counter <= #1 STAY_ON;
								end
								else 				state <= #1 ACTIVE_COUNTB;
							end
							
		STAY_ON_STATE: begin
								counting <= #1 1'b1;
								if (pulse100ms) counter  <= #1 counter - 1'b1;
								if (~|counter) state 	 <= #1 IDLE_COUNTB;	
								else 				state 	 <= #1 STAY_ON_STATE;
							end
			
		endcase
		end
	end

endmodule



