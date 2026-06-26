module compare(
    input clk_dest,
    input rst_n,
    input       [3:0] count,
    output reg  [3:0] even_count
);

always @(posedge clk_dest or negedge rst_n) begin
    if (rst_n) begin
        even_count <= 4'b0;
    end else
        if(count[0]==0) begin
            even_count <= even_count + 1;
        end
    
end

endmodule