
`timescale 1ns / 100ps

module tb_and_primitive;

	reg a,b;
    wire y;

	and_primitive U1 (
		.a(a),.b(b),
		.y(y)
	);

    initial begin
        a = 0; b = 0;
        #20;
        a = 0; b = 1;
        #20;
        a = 1; b = 0;
        #20;
        a = 1; b = 1;
        #20;          
        
    end
               
endmodule






