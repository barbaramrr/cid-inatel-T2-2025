`timescale 1ns / 1ps

module tb_halfadd;
    reg a, b;         
    wire Sum, Carry;      

    halfadd U1 (
        .a(a),
        .b(b),
        .Sum(Sum),
        .Carry(Carry)
    );

    initial begin

        $monitor (Sum, Carry);

        a = 0; b = 0; #5;
        a = 0; b = 1; #5;
        a = 1; b = 0; #5;
        a = 1; b = 1; #5;

        $finish;
    end
endmodule
