
create_clock -name src_clk -period 10.000 [get_ports src_clk]
create_clock -name dest_clk -period 14.000 [get_ports dest_clk]

set_clock_groups -asynchronous -group {src_clk} -group {dest_clk}