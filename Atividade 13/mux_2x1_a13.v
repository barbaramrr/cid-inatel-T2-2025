primitive mux_2x1_a13(
	output y,
	input in1, in2, sel
);	

	table
//	   in1 in2 sel    out
		0	?   1	:	0;
		1   ?	1	:	1;
		?	0   0	:	0;
		?   1	0	:	1;
		0	0	?	:	0;
		1	1	?	:	1;
		
	endtable

endprimitive