`timescale 1ns/1ps

module tb_demux_3x8;

    reg [2:0] in;
    wire [7:0] out;

    demux_3x8 U1 (
        .in(in),
        .out(out)
    );

    initial begin

        in  = 3'b000;#10;

        in  = 3'b001;#10;

        in  = 3'b010;#10;

        in  = 3'b011;#10;

        in  = 3'b100;#10;

        in = 3'b101; #10;

        in = 3'b110; #10;

        in = 3'b111; #10;

        #10 $stop; 
    end

endmodule
