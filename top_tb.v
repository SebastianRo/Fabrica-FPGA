// Testbench Code Goes here
module top_tb;

reg clock, rstn, enpulse, shpulse, ccdpulse, datain; 
reg [2:0] buttons;
wire [6:0] led_display;
wire [1023:0] dataout;
wire 			  datavalid;
wire	[9:0]	  leddata;

initial begin
  //$monitor ("clock=%b,en_count=%b,count_up=%b,count_down=%b,dataout=%d", clock,encount,countup,countdown,dataout);
  clock = 0;
  buttons = 3'b0;
  rstn = 0;
  enpulse = 0;
  shpulse = 0;
  ccdpulse = 0;
  datain = 0;
  #15 rstn = 1;
  #5 enpulse = 1;
  //#15 shpulse = 1;
  #15 datain = 1;
  #103 datain = 0;
  #8300 datain = 1;
  #100600 datain = 0;
  #100600 datain = 1;
  #100600 datain = 0;
  #100600 datain = 1;
  #200600 datain = 0;
  #20600 datain = 1;
  //#15 $finish;
end

always begin
 #2 clock = ~clock;
end

always begin
 #100 ccdpulse = 1;
 #100 ccdpulse = 0;
end

always begin
 #54000 shpulse = 1;
 #600   shpulse = 0;
end

de0_debounce_cnt Utop (
.CLOCK_50(clock),
.CLOCK_50_2(),
.ORG_BUTTON(buttons),
.SW({9'h0,rstn}),
.HEX0_D(led_display),				//	Seven Segment Digit 0
.HEX0_DP(),				//	Seven Segment Digit DP 0
.HEX1_D(),				//	Seven Segment Digit 1
.HEX1_DP(),				//	Seven Segment Digit DP 1
.HEX2_D(),				//	Seven Segment Digit 2
.HEX2_DP(),				//	Seven Segment Digit DP 2
.HEX3_D(),				//	Seven Segment Digit 3
.HEX3_DP(),				//	Seven Segment Digit DP 3
////////////////////////////	LED		////////////////////////////
.LEDG(leddata),					//	LED Green[9:0]
////////////////////////	GPIO	////////////////////////////////
.GPIO0_CLKIN(),		//	GPIO Connection 0 Clock In Bus
.GPIO0_CLKOUT(),		//	GPIO Connection 0 Clock Out Bus
//.GPIO0_D[31](shpulse),				//	GPIO Connection 0 Data Bus
//.GPIO0_D[3](datain),
//.GPIO0_D[1](ccdpulse),
.GPIO0_D({shpulse,27'b0,datain,1'b0,ccdpulse,1'b0}),
.GPIO1_CLKIN(),		//	GPIO Connection 1 Clock In Bus
.GPIO1_CLKOUT(),		//	GPIO Connection 1 Clock Out Bus
.GPIO1_D()				//	GPIO Connection 1 Data Bus
);

endmodule
