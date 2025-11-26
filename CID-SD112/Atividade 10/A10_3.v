

module A10_3 (
	input a, b, c, d,
	output s 
);
	
	wire n_a, n_b, n_c, n_d, and_1, or_1, nor_1, nor_2;

 	not n1	(n_a, a);
 	not n2	(n_b, b);
 	not n3	(n_d, d);
 	 	
 	and a1	(and_1, n_a, b);
 	or	o1	(or_1, c, n_d);
 	nor nr1	(nor_1, n_b, d);
 	
 	nor nr2	(nor_2, and_1, or_1);

 	nand (s, nor_2, nor_1);
 	
 endmodule
