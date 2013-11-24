// Testbench Code Goes here
module ccdreader_tb;

reg clock, rstn, enpulse, shpulse, ccdpulse, datain; 
wire [10:0] dataout;
wire 			  datavalid;

initial begin
  //$monitor ("clock=%b,en_count=%b,count_up=%b,count_down=%b,dataout=%d", clock,encount,countup,countdown,dataout);
  clock = 0;
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
  #800 shpulse = 1;
  #4 shpulse = 0;
  #26600 datain = 0;
  #14600 datain = 1;
  #14600 datain = 0;
  #203000 datain = 1;
  #58000 shpulse = 1;
  #4 shpulse = 0;
  #14900 datain = 0;
  #203000 datain = 1;
//  #100600 datain = 1;
//  #100600 datain = 0;
//  #100600 datain = 1;
//  #200600 datain = 0;
//  #20600 datain = 1;
  //#5 enpulse = 0;
  //#15 $finish;
end

always begin
 #2 clock = ~clock;
end

always begin
 #196 ccdpulse = 1;
 #4 ccdpulse = 0;
end

//always begin
// #54000 shpulse = 1;
// #600   shpulse = 0;
//end

ccd_reader U1 (
.clk(clock),
.rst_n(rstn),
.data_in(datain),
.en_pulse (enpulse),
.sh_pulse (shpulse),
.ccd_pulse (ccdpulse),
.data_out (dataout),
.data_out_valid(datavalid)
);

endmodule
