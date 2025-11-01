
`timescale 1ns / 100ps

module tb_mux2x1_10_2;


	reg in1, in2, select;
	wire out;

	mux2x1_10_2 U1 (
		.in1(in1), .in2(in2), .select(select),
		.out(out)
	);

	initial begin
		
		select = 0;
		in1 = 0; in2 = 1;
		#15
		in1 = 1; in2 = 0;
		#15;
		
		select = 1; 
		in1 = 0; in2 = 1;
		#15;
		in1 = 1; in2 = 0;
		#15;
		
		$finish;
	end
                
endmodule
