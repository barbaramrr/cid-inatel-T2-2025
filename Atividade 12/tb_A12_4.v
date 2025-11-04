`timescale 1ns/100ps

module tb_A12_4;

reg clk, rst;
wire out;

A12_4 #(.CONST(10), .WIDTH (8)) U2 (.clk(clk),.rst(rst),
         .out(out)
);



always #5 clk = ~clk;

initial begin
    
    clk <= 0;
    rst <= 1'b1; 
    #60; 
    rst <= 0;
    #30; 
    #200;
    $finish;
end

endmodule
