module comparador #(parameter CONST = 10, parameter WIDTH = 4)(
    input  [WIDTH-1:0] in,
    output result
);

assign result = (CONST == in);

endmodule 
