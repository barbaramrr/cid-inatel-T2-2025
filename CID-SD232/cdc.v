module cdc (
    input wire clk_src,       
    input wire clk_dest,      
    input wire rst_n,
    input wire [3:0] count,   
    output reg [3:0] sync_out 
);

    reg [3:0] q_src; 
    reg [3:0] q1, q2; 

    always @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
            q_src <= 4'b0;
        end else begin
            q_src <= count;
        end
    end

    always @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            q1       <= 4'b0;
            q2       <= 4'b0;
            sync_out <= 4'b0;
        end else begin
  
            q1       <= q_src; 
            q2       <= q1;
            sync_out <= q2;    
        end
    end

endmodule