module contador (
    input        clk,
    input        rst,
    output reg [3:0] cont = 4'b0000, 
    output reg dp = 1'b0,   
    output [7:0]     out
);

    display U3(.in_display(cont), .dp(dp), .out_display(out));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cont <= 4'b0000;
            dp   <= 1'b0;
        end else if ({dp,cont}>= 5'hF) begin
            cont <= 4'b0000;
            dp   <= 1;  
        end else begin
            cont <= cont + 1;
            dp   <= 0;
        end
    end

endmodule
