module A12_4 (
    input clk,rst,
    output out

);

wire out_comp;
wire [23:0] out_counter;


comparador #(.CONST(10), .WIDTH(24))    C2  (.in(out_counter),.result(out_comp));
counter_24 #(.W(24))                    C1  (.clk(clk),.reset(rst),.en(out_comp),.count(out_counter));
DFF                                     C3  (.clk(clk),.rst(rst),.D(out_comp),.Q(out));

endmodule