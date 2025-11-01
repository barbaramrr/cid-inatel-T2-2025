`timescale 1ns/1ps

module tb_contador;

    reg clk,rst;
    wire [3:0] cont;
    wire dp;
    wire [7:0] out;

    contador U3(.cont(cont), .dp(dp), .out(out), .clk(clk),.rst(rst));

    integer i;

    initial begin
        clk = 0;
        rst =0; 
        $monitor(cont, dp, out);
        for (i = 0; i < 18; i = i + 1) begin
            #5 clk = ~clk; 
            #5 clk = ~clk;  
        end

        rst = 1; 
        #5;
        rst = 0;
          for (i = 0; i < 4; i = i + 1) begin
            #5 clk = ~clk; 
            #5 clk = ~clk;  
        end

        $finish;
    end

endmodule
