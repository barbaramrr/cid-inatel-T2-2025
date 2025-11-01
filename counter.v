module counter #(parameter WIDTH = 8)(
    input clk, reset, en,
    output reg [WIDTH-1:0] count,
    output reg carry
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        carry <= 0;
    end
   else if (en) begin 
        count <= count;
        carry <= 0; 
    end
    else begin 
        if (count == {WIDTH{1'b1}}) begin
            count <= 0;
            en    <= 1
            carry <= 1;
        end else begin
            count <= count + 1;
            carry <= 0;
        end
    end
end

endmodule