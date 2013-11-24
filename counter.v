module counter	(
							clk,
							rst_n,
							en_count,
							count_up,
							count_down,
							data_out			
						);
					
input						clk;
input						rst_n;
input						en_count;
input						count_up;
input						count_down;
output	reg [3:0]	data_out;

reg			 [3:0]	count_next;
//reg						count_up_dld;
//reg						count_down_dld;
//reg						rise_up, rise_down;
//reg						fall_down, fall_up;

//=======================================================
//  Structural coding
//=======================================================

always @(*)
begin
	count_next = data_out;
	if	(en_count) begin
//		if (~count_up & count_down)
//		begin
//			if (count_next < 4'b1001) count_next = count_next + 1;
//			else 							  count_next = 4'b1001;
//		end
//		if (~count_down & count_up)
//		begin
//			if (count_next >= 4'b0001) count_next = count_next - 1;
//			else 						 		count_next = 4'b0001;
//		end 
		case ({count_up,count_down})
		
		2'b10: begin	
					if (count_next <= 4'b1001) count_next = count_next + 1'b1;
					else 							  count_next = 4'b1000;
				 end
				 
		2'b01: begin
					if (count_next >= 4'b0001) count_next = count_next - 1'b1;
					else 								count_next = 4'b0000;
				 end
		
		default: count_next = data_out;
		
		endcase
		
			
	end 
end

always	@(posedge clk)
begin
	if	(!rst_n) data_out <= 4'b0000;	
	else data_out <= count_next;
end

//always @ (posedge clk )
//	begin
//		count_up_dld <= count_up;
//		count_down_dld <= count_down;
//	end

//always @ (posedge clk )
//	begin
//		fall_up <= count_up_dld & !count_up;
//		rise_up <= count_up & !count_up_dld;
//		fall_down <= count_down_dld & !count_down;
//		rise_down <= count_down & !count_down_dld;
//	end
	
endmodule

