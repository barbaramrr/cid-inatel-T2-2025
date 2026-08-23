module mux2x1_10_2 (
    input in1, in2, select,
    output out
);
    assign out = select ? in2 : in1;
endmodule
