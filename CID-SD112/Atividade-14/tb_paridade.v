
`timescale 1ns / 1ps

module tb_paridade;

    localparam WIDTH = 8;

    reg [WIDTH-1:0] in;
    wire            out;

    paridade #(.WIDTH(WIDTH)) U1 (
        .in(in),
        .out(out)
    );

    initial begin
        
       	in = 8'b00000000;#10;
        in = 8'b00000001;#10;
        
        in = 8'b10000010;#10;
        in = 8'b00000011;#10;

        in = 8'b10101010;#10;
        in = 8'b00101010;#10;

        in = 8'b01110001;#10;
        in = 8'b11100011;#10;

        in = 8'b10001010;#10;
        in = 8'b11111111;#20;

        $finish; 
        
    end

endmodule