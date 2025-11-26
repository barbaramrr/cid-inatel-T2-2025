module A12_4 #(parameter CONST=10,WIDTH=8)(
    input clk,rst,
    output out

);

wire out_comp;
wire [WIDTH-1:0] out_counter;


contador_8bits #(.WIDTH (8))            C1 (.clk(clk), .rst(rst), .en(out_comp), .out(out_counter));
comparador #(.CONST(CONST), .WIDTH(8)) C2  (.in(out_counter),.result(out_comp));
DFF                                     C3  (.clk(clk),.rst(rst),.D(out_comp),.Q(out));


endmodule
