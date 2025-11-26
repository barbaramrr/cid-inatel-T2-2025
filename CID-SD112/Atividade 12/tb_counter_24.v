
`timescale 1ns / 100ps

module tb_counter_24;

	reg clk,reset,en;
    wire [23:0] count;

	counter_24 U1 (
		.clk(clk),.reset(reset), .en(en),
		.count(count)
	);

    

  always #5 clk = ~clk;
  
    initial begin
    clk = 0;
    reset = 1;
    en = 0;     
    #20;
    reset = 0;
    #1000;       
    $finish;
    end

    

                
endmodule






