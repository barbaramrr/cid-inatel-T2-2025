`timescale 1ns/1ps

module tb_display;
reg [3:0]    in_display;
reg                dp;
wire  [7:0]    out_display;

display U1(.in_display(in_display),.dp(dp),.out_display(out_display));

initial begin
    $monitor (dp,out_display);

                dp = 1'b0;
        in_display = 4'b0000; #5;
        in_display = 4'b0001; #5;
        in_display = 4'b0010; #5;
        in_display = 4'b0011; #5;
        in_display = 4'b0100; #5;
        in_display = 4'b0101; #5;
        in_display = 4'b0110; #5;
        in_display = 4'b0111; #5;
        in_display = 4'b1000; #5;
        in_display = 4'b1001; #5;
        in_display = 4'b1010; #5;
        in_display = 4'b1011; #5;
        in_display = 4'b1100; #5;
        in_display = 4'b1101; #5;
        in_display = 4'b1110; #5;
        in_display = 4'b1111; #5;
        dp = 1'b1; #5;
        in_display = 4'b111x; #5;
        

    $finish;

end
endmodule
