module sh_generator	(
							clk,
							rst_n,
							data_out
						);
					
input						clk;
input						rst_n;
output reg 				data_out;

localparam 	 [1:0] STATE_SH_HIGH 	 = 2'b00,
                   STATE_SH_LOW  	 = 2'b01;
						 
//localparam			 SH_HIGH				 = 24;
//localparam			 SH_LOW				 = 27500;

localparam			 SH_HIGH				 = 25;    // should be around 0.5us
localparam			 SH_LOW				 = 60000; // should be around 1.2ms = 1200us
						
reg			 [15:0]	counter;
reg			 [1:0]	state;

//=======================================================
//  Structural coding
//=======================================================

always @(posedge clk)
begin
	if	(!rst_n)  begin
			data_out <= #1 1'b1;
			state    <= #1 STATE_SH_HIGH;
			counter	<= #1 SH_HIGH;
	end else  begin
		
	case(state)
		
			STATE_SH_HIGH: begin
									if (|counter) begin
										counter	<= #1 counter - 1'b1;
										data_out <= #1 1'b1;
										state    <= #1 STATE_SH_HIGH;
									end
									
									else begin
										counter	<= #1 SH_LOW;
										data_out <= #1 1'b0;
										state    <= #1 STATE_SH_LOW;
									end
										
			end
			
			STATE_SH_LOW: begin
									if (|counter) begin
										counter	<= #1 counter - 1'b1;
										data_out <= #1 1'b0;
										state    <= #1 STATE_SH_LOW;
									end
									
									else begin
										counter	<= #1 SH_HIGH;
										data_out <= #1 1'b1;
										state    <= #1 STATE_SH_HIGH;
									end
		  end									
			
		endcase
	end
				
end

endmodule
