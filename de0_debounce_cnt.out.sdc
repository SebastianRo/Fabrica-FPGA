## Generated SDC file "de0_debounce_cnt.out.sdc"

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

## DATE    "Sun Dec 01 19:09:53 2013"

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

create_clock -name {clk50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {clk50_virtual} -period 20.000 -waveform { 0.000 10.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 25 -master_clock {clk50} [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 100 -master_clock {clk50} [get_pins {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {ccd_sh_clk} -source [get_ports {CLOCK_50}] -edges { 1 51 120051 } -master_clock {clk50} -invert [get_nets {sh_generator_inst|data_out}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty
#set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clock_ccd_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk50}] -rise_to [get_clocks {clk50}]  0.020  
#set_clock_uncertainty -rise_from [get_clocks {clk50}] -fall_to [get_clocks {clk50}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk50}] -rise_to [get_clocks {clk50}]  0.020  
#set_clock_uncertainty -fall_from [get_clocks {clk50}] -fall_to [get_clocks {clk50}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



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

