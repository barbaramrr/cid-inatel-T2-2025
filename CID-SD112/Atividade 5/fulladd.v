module fulladd (
    input a,b,cin,
    output sum,carry_out
);

    assign sum = a^b^cin;
    assign carry_out = (a&b)|( cin & (a^b)) ;


endmodule
