// Testbench Code Goes here
module counter_tb;

reg clock, rstn, encount, countup, countdown; //countpulse;
wire [3:0] dataout;

initial begin
  $monitor ("clock=%b,en_count=%b,count_up=%b,count_down=%b,dataout=%d", clock,encount,countup,countdown,dataout);
  clock = 0;
  rstn = 0;
  encount = 0;
  countup = 1;
  countdown = 1;
  #5 rstn = 0;
  #15 rstn = 1;
  #5 encount = 1;
  #5 countup = 0;
  #15 countup = 1;
  #5 countup = 0;
  #15 countup = 1;
  #5 countup = 0;
  #15 countup = 1;
  #5 countup = 0;
  #15 countup = 1;
  #5 countdown = 0;
  #15 countdown = 1;
  #5 countdown = 0;
  #15 countdown = 1;
  #30 encount = 0;
  #5 countdown = 0;
  #15 countdown = 1;
  #5 countdown = 0;
  #15 countdown = 1;
  //#15 $finish;
end

always begin
 #5 clock = !clock;
end

counter U0 (
.clk(clock),
.rst_n(rstn),
.en_count (encount),
//.cnt_pulse(countpulse),
.count_up (countup),
.count_down (countdown),
.data_out (dataout)
);

endmodule
