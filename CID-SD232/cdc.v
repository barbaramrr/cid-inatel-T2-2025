`timescale 1 ns / 1 ps

module cdc (
    input clk_src,       
    input clk_dest,      
    input rst_n,
    input [3:0] count,   
    output [3:0] sync_out 
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
        end else begin
            q1       <= q_src; 
            q2       <= q1;    
        end
    end
    
    assign sync_out = rst_n ? q2 : 4'b0;

endmodule
