primitive flip_flop_D_primitive (q, d, clk, rst);
    output q;
    input  d, clk, rst;
    reg    q;

    table
    // d  clk  rst  : q : q+
       ?   ?    1  : ? : 0;   
       0  (01)  0  : ? : 0;   
       1  (01)  0  : ? : 1;   
       ?  (?0)  0  : ? : -;   
       
    endtable
endprimitive
