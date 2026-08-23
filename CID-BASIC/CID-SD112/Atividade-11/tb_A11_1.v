`timescale 1ns/100ps

module tb_A11_1;

reg clk, rst;
wire out;

A11_1 U2 (.clk(clk),.rst(rst),
         .out(out)
);



always #10 clk = ~clk;


initial begin
    clk = 1'b0; 
    rst = 1'b1; 
    #600; 
    rst = 0;
    #30; 
    #200;
    $finish;
end

endmodule