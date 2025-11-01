
`timescale 1ns / 100ps

module tb_A10_3;
	
	reg a, b,c, d;
	wire s;

	A10_3 U1 (
		.a(a), .b(b), .c(c),.d(d),.s(s)
	);

	initial begin
		
		a = 0; b = 0; c = 0; d = 0;
		#5
		a = 0; b = 1; c = 0; d = 1;
		#5;
		a = 0; b = 0; c = 0; d = 1;
		#5;
		a = 0; b = 0; c = 1; d = 0;
        #5;
		a = 1; b = 1; c = 0; d = 1;
        #5;
        a = 0; b = 1; c = 0; d = 0;
        #5;
        a = 1; b = 0; c = 1; d = 0;
        #5;

		
		$finish;
	end
                
endmodule

