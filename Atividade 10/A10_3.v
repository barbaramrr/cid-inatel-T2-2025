module A10_3 (
	input a, b, c, d,
	output s 
);
	

	wire n_a, n_b, n_d, and_1, or_1, nor_1, nor_2;

 	not (n_a, a);
 	not (n_b, b);
 	not (n_d, d);
 	
 	
 	and (and_1, n_a, b);
 	or	(or_1, c, n_d);
 	nor (nor_1, n_b, d);
 	
 	nor (nor_2, and_1, or_1);

 	nand (s, nor_2, nor_1);
 	
 endmodule