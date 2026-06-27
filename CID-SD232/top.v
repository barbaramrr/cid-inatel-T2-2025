`include "contador_sincrono.v"
`include "cdc.v"
`include "compare.v"

`timescale 1 ns / 1 ps

module top (
    
    input clk_dest, clk_src,
    input rst_n,
    output  [3:0] data_out
    
);
	wire [3:0] count_cdc_in, count_cdc_out;

	contador_sincrono COUNTER_SYNC_module (  
		.clk_src(clk_src),
		.rst_n (rst_n),
		.count (count_cdc_in)
	);

	cdc CDC_module (   
		.clk_dest(clk_dest),
		.clk_src (clk_src),
		.rst_n(rst_n),
		.count(count_cdc_in),
		.sync_out(count_cdc_out)
	);

	compare COMPARE_module ( 
		.clk_dest(clk_dest),
		.rst_n (rst_n),
		.count(count_cdc_out),
		.even_count(data_out)
	);

endmodule
