module DFF (
    input D, clk,rst,
    output reg Q
);


always @(posedge clk)
begin
  if (rst)
    Q <= 0;
  else
    Q <= D;
end


endmodule
