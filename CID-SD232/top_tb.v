`include "top.v"
`timescale 1 ns / 1 ps

module top_tb ();

	// Declaração de sinais
	reg clk_src;
	reg clk_dest;
	reg rst_n;
	wire [3:0] data_out;

	// Instanciação do DUT (Device Under Test)
	top dut (
		.clk_dest(clk_dest),
		.clk_src(clk_src),
		.rst_n(rst_n),
		.data_out(data_out)
	);

	// 250 MHz
	always #( (1.0/250.0) * 10**3) clk_src = ~clk_src;
	// 491.52 MHz
	always #( (1.0/491.52) * 10**3) clk_dest = ~clk_dest;

	// Monitoramento dos Sinais (Scoreboard Simples)
	initial begin
		// Format: scale to ns (-9, 2 decimal digits, min width of 10 chars;
		$timeformat( -9, 1, "", 10);
		$dumpfile("dump.vcd");
		$dumpvars(0, top_tb);
		$display("Tempo	(ns)	|rst_n	|Count_Src	|Dest_Sync	|Even_Count	|");
		$monitor("|%0t		|%b	|%d		|%d		|%d		|", 
		$realtime, rst_n, dut.COUNTER_SYNC_module.count, dut.CDC_module.sync_out, data_out);
	
	end

	// Geração de Estímulos e Reset
	initial begin
		// Reset
		clk_src	 = 1'b0;
		clk_dest = 1'b0;
		rst_n 	 = 1'b0;

		#15;
		rst_n = 1'b1;

		// Contador: reiniciar (overflow)
		#200;

		$finish;
	end

endmodule
