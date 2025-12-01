module  and_primitive (
    input a, b,
    output y
); 
    supply1 vdd; 
    supply0 gnd; 

    wire out_1, nmos_con;

    pmos (out_1, vdd, a);
    pmos (out_1, vdd, b);
    
    nmos (out_1, nmos_con, a); 
    nmos (nmos_con, gnd, b);

    pmos (y, vdd, out_1); 
    nmos (y, gnd, out_1); 

endmodule
