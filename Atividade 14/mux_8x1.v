module mux_8x1 (
    input  wire [7:0] in,
    input  wire [2:0] sel,
    output wire       out
);

    assign out = in[sel];

endmodule