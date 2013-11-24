module edge_detector(
							clk,
							rst_n,
							signal_in,
							rise_out,
							fall_out
						);
					
input						clk;
input						rst_n;
input						signal_in;
output		reg		rise_out;
output		reg		fall_out;

reg						signal_dld;

always @ (posedge clk )
begin
	signal_dld <= signal_in;
end
always @ (posedge clk )
begin
	fall_out = signal_dld & !signal_in;
	rise_out = signal_in & !signal_dld;
end

endmodule
