module valve_cmd	(
							clk,
							rst_n,
							part_ready,
							valve1_decision,
							valve2_decision,
							valve1_cmd,
							valve2_cmd
						);
											
input						clk;
input						rst_n;
input						part_ready;
input						valve1_decision;
input						valve2_decision;
output reg 				valve1_cmd;
output reg				valve2_cmd;

parameter 	 [2:0] IDLE_VALVE  		= 3'b000,
                   WRITE_VALVE 		= 3'b001,
                   READ_VALVE_CMD 	= 3'b010,
						 READ_VALVE_EXEC 	= 3'b011,
                   COUNT_VALVE 	 	= 3'b100,
                   WRITE_VALVE_COUNT= 3'b101;
						 
localparam MAX = 3050;
						
reg			 [12:0]	counter_100us;
reg			 [14:0]	counter;					// counts up to 3276,8 ms 
reg			 [2:0]	state, state_next;
//reg			 [9:0]	counter_next;
wire						enable_100us;

reg			 [14:0]  counter_fifo_in;
wire			 [14:0]	counter_fifo_out;
wire						cnt_fifo_empty;
reg						cnt_rdreq_sig;
reg						cnt_wrreq_sig;

reg						valve1_rdreq_sig;
reg						valve1_wrreq_sig;
wire						valve1_dec_out;

reg						valve2_rdreq_sig;
reg						valve2_wrreq_sig;
wire						valve2_dec_out;

//reg			[ 9:0]	valve_open_cnt;
reg						en_valve1_open_cnt;
reg						en_valve2_open_cnt;
reg						local_read_valve1;
reg						local_read_valve2;

wire						cmd_wire_valve1;
wire						cmd_wire_valve2;

FIFO	FIFO_cnt (
	.aclr ( !rst_n ),
	.clock ( clk ),
	.data ( counter_fifo_in ),
	.rdreq ( cnt_rdreq_sig ),
	.wrreq ( cnt_wrreq_sig ),
	.empty ( cnt_fifo_empty ),
	.full (  ),
	.q ( counter_fifo_out )
	);

FIFO2	FIFO_valve1 (
	.aclr ( !rst_n ),
	.clock ( clk ),
	.data ( valve1_decision ),
	.rdreq ( valve1_rdreq_sig ),
	.wrreq ( valve1_wrreq_sig ),
	.empty (  ),
	.full (  ),
	.q ( valve1_dec_out )
	);

FIFO2	FIFO_valve2 (
	.aclr ( !rst_n ),
	.clock ( clk ),
	.data ( valve2_decision ),
	.rdreq ( valve2_rdreq_sig ),
	.wrreq ( valve2_wrreq_sig ),
	.empty (  ),
	.full (  ),
	.q ( valve2_dec_out )
	);	
	
binary_counter #(.MS_ON(1)) counter_valve1(
	.clk(clk), 
	.rst_n( !rst_n ), 
	.enable(en_valve1_open_cnt), 
	.pulse100ms(enable_100us),
	.counting(cmd_wire_valve1)
);

binary_counter #(.MS_ON(3850)) counter_valve2(
	.clk(clk), 
	.rst_n( !rst_n ), 
	.enable(en_valve2_open_cnt), 
	.pulse100ms(enable_100us),
	.counting(cmd_wire_valve2)
);

//=======================================================
//  Structural coding
//=======================================================

assign enable_100us = ~|counter_100us;

always	@(posedge clk)
begin
	if	(!rst_n)  counter_100us <= #1 5000; // coresponds to 100 microseconds
   else begin      
		valve1_cmd <= #1 cmd_wire_valve1;
		valve2_cmd <= #1 cmd_wire_valve2;
		if (|counter_100us) counter_100us <= #1 counter_100us - 1'b1;
		else					  counter_100us <= #1 5000;
	end
end


always @(posedge clk)
begin
	if	(!rst_n)  begin
								state <= #1 IDLE_VALVE;
   end else  begin
		
	case(state)
		
			IDLE_VALVE: begin
								en_valve1_open_cnt    <= #1 1'b0;
								en_valve2_open_cnt    <= #1 1'b0;
								counter_fifo_in		<= #1 MAX;
								cnt_wrreq_sig 			<= #1 1'b0;
								valve1_wrreq_sig	 	<= #1 1'b0;
								valve2_wrreq_sig 		<= #1 1'b0;
								cnt_rdreq_sig 			<= #1 1'b0;
								valve1_rdreq_sig	 	<= #1 1'b0;
								valve2_rdreq_sig 		<= #1 1'b0;
								if (part_ready) 				state <= #1 WRITE_VALVE;
								else if (~cnt_fifo_empty)	state <= #1 READ_VALVE_CMD;
								else 				 				state <= #1 IDLE_VALVE;
							end
								
			WRITE_VALVE: begin
								en_valve1_open_cnt    <= #1 1'b0;
								en_valve2_open_cnt    <= #1 1'b0;
								counter_fifo_in		<= #1 MAX;
								cnt_wrreq_sig 			<= #1 1'b1;
								valve1_wrreq_sig	 	<= #1 1'b1;
								valve2_wrreq_sig 		<= #1 1'b1;
								cnt_rdreq_sig 			<= #1 1'b0;
								valve1_rdreq_sig	 	<= #1 1'b0;
								valve2_rdreq_sig 		<= #1 1'b0;
								state <= #1 READ_VALVE_CMD;									
							end
								
			READ_VALVE_CMD: begin
								en_valve1_open_cnt    <= #1 1'b0;
								en_valve2_open_cnt    <= #1 1'b0;
								counter_fifo_in		<= #1 MAX;
								cnt_wrreq_sig 			<= #1 1'b0;
								valve1_wrreq_sig	 	<= #1 1'b0;
								valve2_wrreq_sig 		<= #1 1'b0;
								cnt_rdreq_sig 			<= #1 1'b0;
								valve1_rdreq_sig	 	<= #1 1'b0;
								valve2_rdreq_sig 		<= #1 1'b0;
								local_read_valve1		<= #1 valve1_dec_out;
								local_read_valve2		<= #1 valve2_dec_out;
								counter					<= #1 counter_fifo_out;
								if (~cnt_fifo_empty) begin
												cnt_rdreq_sig 			<= #1 1'b1;
												valve1_rdreq_sig	 	<= #1 1'b1;
												valve2_rdreq_sig 		<= #1 1'b1;
												state <= #1 COUNT_VALVE;
								end
								else 						state <= #1 READ_VALVE_CMD;
							 end
								 			
			COUNT_VALVE: begin
								en_valve1_open_cnt    <= #1 1'b0;
								en_valve2_open_cnt    <= #1 1'b0;
								counter_fifo_in		<= #1 MAX;
								cnt_wrreq_sig 			<= #1 1'b0;
								valve1_wrreq_sig	 	<= #1 1'b0;
								valve2_wrreq_sig 		<= #1 1'b0;
								cnt_rdreq_sig 			<= #1 1'b0;
								valve1_rdreq_sig	 	<= #1 1'b0;
								valve2_rdreq_sig 		<= #1 1'b0;
								if (~|counter) 					state <= #1 IDLE_VALVE;
								else	if (part_ready) begin
																		counter_fifo_in 		<= #1 MAX - counter;
																		state <= #1 WRITE_VALVE_COUNT;
															 end
								else 									state <= #1 COUNT_VALVE;
								if (enable_100us) counter <= counter - 1'b1;
								if (~|counter)			begin
																en_valve1_open_cnt    <= #1 local_read_valve1;
																en_valve2_open_cnt    <= #1 local_read_valve2;
															end
							end
									
			WRITE_VALVE_COUNT: begin
									en_valve1_open_cnt    <= #1 1'b0;
									en_valve2_open_cnt    <= #1 1'b0;
									counter_fifo_in 		<= #1 MAX - counter;
									cnt_wrreq_sig 			<= #1 1'b1;
									valve1_wrreq_sig	 	<= #1 1'b1;
									valve2_wrreq_sig 		<= #1 1'b1;
									cnt_rdreq_sig 			<= #1 1'b0;
									valve1_rdreq_sig	 	<= #1 1'b0;
									valve2_rdreq_sig 		<= #1 1'b0;
									if (~|counter) 					state <= #1 IDLE_VALVE;
									else 									state <= #1 COUNT_VALVE;
									if (enable_100us) counter <= counter - 1'b1;
									if (~|counter)		begin
																en_valve1_open_cnt    <= #1 local_read_valve1;
																en_valve2_open_cnt    <= #1 local_read_valve2;
															end
								 end
			
		endcase
	end
				
end
	
endmodule
