module fulladd_inst (
    input a,b,cin,
    output sum,carry_out
);
wire sum1, carry1, carry2;

    halfadd U1(.a(a),.b(b),.Carry(carry1),.Sum(sum1));
    halfadd U2(.a(sum1),.b(cin),.Sum(sum),.Carry(carry2));
    or U3 (carry_out,carry2,carry1);

endmodule