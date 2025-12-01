`timescale 1ns/1ps
module tb_reset_sync;
    reg           clk_A;
    reg           n_rst;
    reg    [1:0]  D_in;
    wire   [1:0]  Q_out;

    reset_sync U1 (
        .clk_A(clk_A),
        .n_rst(n_rst),
        .D_in(D_in),
        .Q_out(Q_out)
    );

    initial begin
        clk_A = 1'b0;
        forever #10 clk_A = ~clk_A; 
    end

    initial begin
        D_in = 2'b00;
        n_rst = 1'b0; 

        #10;
        n_rst = 1'b1;

        #100;
        
        D_in = 2'b10;
        #20; 
        
        D_in = 2'b01;
        #20; 
        
        D_in = 2'b11;
        #20; 
        
        n_rst = 1'b0; 
        
        #30; 
        n_rst = 1'b1;
        
        #80;
        
        $finish; 
    end

endmodule