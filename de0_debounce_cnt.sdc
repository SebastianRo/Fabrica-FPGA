## Generated SDC file "de0_debounce_cnt.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.1 Build 177 11/07/2012 SJ Web Edition"

## DATE    "Sun Sep 29 23:42:29 2013"

##
## DEVICE  "EP3C16F484C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_g50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -divide_by 25 -master_clock {clk_g50} [get_pins { clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0] }] 
create_generated_clock -name {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 50 -master_clock {clk_g50} [get_pins { clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1] }] 
create_generated_clock -name {clocksh} -source [get_ports {GPIO0_CLKOUT[1]}] -duty_cycle 0.001 -multiply_by 1 -divide_by 1100 -master_clock {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]} [get_pins { sh_generator_inst|data_out|q }] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clocksh}] -rise_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocksh}] -fall_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocksh}] -rise_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocksh}] -fall_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clk_g50}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clk_g50}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clk_g50}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clk_g50}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {clk_g50}] -rise_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_g50}] -fall_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_g50}] -rise_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_g50}] -fall_to [get_clocks {clk_g50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

