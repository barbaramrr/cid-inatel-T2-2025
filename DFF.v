module DFF (
    input D, clk,rst,
    output Q
);

assign Q = rst ? 1'b0: D;

endmodule