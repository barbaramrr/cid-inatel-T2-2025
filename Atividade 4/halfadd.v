module halfadd (
    input a, b,
    output Sum, Carry
);

assign Sum = a ^ b;
assign Carry = a & b;

endmodule
