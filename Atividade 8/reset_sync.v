module reset_sync (
    input              clk_A, n_rst,
    input        [1:0] D_in,
    output  reg  [1:0] Q_out
);

reg Q_FF1, Q_FF2, Q_FF3;

always @(posedge clk_A, negedge n_rst) begin
    if (!n_rst) begin
        Q_FF1 <= 1'b0;
    end
    else begin
        Q_FF1 <= 1'b1;
    end 
end


always @(posedge clk_A, negedge n_rst) begin
       if (!n_rst) begin
        Q_FF2 <= 1'b0;
    end
    else begin
        Q_FF2 <= Q_FF1;
    end 
end


always @(posedge clk_A, negedge n_rst) begin
        if (!n_rst) begin
        Q_FF3 <= 1'b0;
    end
    else begin
        Q_FF3 <= Q_FF2;
    end
end

always @(posedge clk_A)begin
  if (!Q_FF3) begin
        Q_out <= 1'b0;
    end
    else begin
        Q_out <= D_in;
    end   
end

endmodule

   

