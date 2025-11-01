module crossbar_structural(
	input in1, in2, select,
	output out1, out2
);

	mux2x1_rtl_1 mux1(in1, in2, select, out1);
	mux2x1_rtl_1 mux2(in2, in1, select, out2);

endmodule
