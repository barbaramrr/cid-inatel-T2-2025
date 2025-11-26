module counter #(parameter WIDTH = 8)(
    input clk, reset, en,
    output reg [WIDTH-1:0] count,
    output reg carry
);

always @(posedge clk) begin
    if (reset) begin
        count <= {WIDTH{1'b0}};
        carry <= 1'b0;
    end
   else if (en) begin 
        count <= count;
        carry <= 0; 
    end
    else begin 
        if (count == {WIDTH{1'b1}}) begin
            count <= {WIDTH{1'b0}};
            carry <= 1'b1;
        end else begin
            count <= count + 1;
            carry <= 1'b0;
        end
    end
end

endmodule
