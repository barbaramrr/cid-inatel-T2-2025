
`timescale 1ns / 100ps

module tb_mux_2x1_a13;

	

	reg in1, in2, sel;
	wire y;

	mux_2x1_a13 U1 (y,in1,in2,sel);

	initial begin
		
		sel = 0;
		in1 = 1; in2 = 0;
		#15;
		in1 = 0; in2 = 1;
		#15;
		
		sel = 1; 
		in1 = 1; in2 = 0;
		#15;
		
		in1 = 0; in2 = 1;
		#10;
		
		$finish;
	end
                
endmodule
