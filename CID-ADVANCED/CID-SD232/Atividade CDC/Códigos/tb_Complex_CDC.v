`timescale 1ns / 1ps

module tb_Complex_CDC;

    reg src_clk;
    reg src_arstn;
    reg [3:0] src_data;
    reg src_valid;

    reg dest_clk;
    reg dest_arstn;

    wire [3:0] dest_data;

    Complex_CDC dut (
        .src_clk(src_clk),
        .src_arstn(src_arstn),
        .src_data(src_data),
        .src_valid(src_valid),
        .dest_clk(dest_clk),
        .dest_arstn(dest_arstn),
        .dest_data(dest_data)
    );

  
    always #5 src_clk  = ~src_clk;
    always #7 dest_clk = ~dest_clk;

    initial begin

        src_clk     = 0;
        dest_clk    = 0;
        src_arstn   = 0;
        dest_arstn  = 0;
        src_data    = 4'h0;
        src_valid   = 1'b0;


        #30;
        src_arstn  = 1;
        dest_arstn = 1;

        #20;

      
        // Novo dado

        wait(dut.busy_src == 0);

        @(posedge src_clk);
        src_data  <= 4'hA;
        src_valid <= 1'b1;

        @(posedge src_clk);
        src_valid <= 1'b0;

        wait(dut.busy_src == 1);
        wait(dut.busy_src == 0);

        // Novo dado

        @(posedge src_clk);
        src_data  <= 4'h5;
        src_valid <= 1'b1;

        @(posedge src_clk);
        src_valid <= 1'b0;

        wait(dut.busy_src == 1);
        wait(dut.busy_src == 0);

        // Novo dado

        @(posedge src_clk);
        src_data  <= 4'hC;
        src_valid <= 1'b1;

        @(posedge src_clk);
        src_valid <= 1'b0;

        wait(dut.busy_src == 1);
        wait(dut.busy_src == 0);

        #100;
        $finish;
    end

endmodule