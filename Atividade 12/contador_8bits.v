module contador_8bits #(parameter WIDTH = 8)(
    input clk,             
    input rst,  
    input en,     
    output reg[WIDTH-1:0] out  
);


  always @ (posedge clk) begin
    if (rst)             
      out <= {WIDTH{1'b0}};
    else                    
      if (~en) 
        out <= out + 1;
      else
        out <= out;
  end
endmodule