`timescale 1ns/1ps
module tb_flip_flop_D_primitive;

    reg d, clk, rst;
    wire q;

    flip_flop_D_primitive U1 (q, d, clk, rst);

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end


    initial begin

        rst = 1; d = 1; #10;
        rst = 0; #10;

        d = 1; #10;
        d = 0; #10;
        #20;
        $finish;
    end

endmodule
