
`timescale 1ns / 100ps

module tb_crossbar_structural;

	reg in1, in2, select;
	wire out1, out2;

	crossbar_structural U1 (
		.in1(in1), .in2(in2), .select(select),
		.out1(out1),.out2(out2)
	);

	initial begin
		
		select = 0;
		in1 = 1; in2 = 0;
		#15;
		in1 = 0; in2 = 1;
		#15;
		
		select = 1; 
		in1 = 1; in2 = 0;
		#15;
		in1 = 0; in2 = 1;
		#15;
		
		$finish;
	end
                
endmodule






