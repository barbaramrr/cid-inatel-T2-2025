set_units -capacitance 1fF
set_units -time 1ps
create_clock -name "clk_src" -period 1000.0 -waveform {0.0 500.0} [get_ports clk_src]
create_clock -name "clk_dest" -period 5000.0 -waveform {0.0 2500.0} [get_ports clk_dest]
set_clock_gating_check -setup 0.0
set_max_delay -from [get_clocks clk_src] -to [get_clocks clk_dest] 1000.0

#set_clock_groups -asynchronous -group [get_clocks clk_src] -group [get_clocks clk_dest]
