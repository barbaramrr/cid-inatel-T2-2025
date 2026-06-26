module contador_sincrono (
    input wire clk_src,                       
    input wire rst_n,                                            
    output reg [3:0] count               
);

    always @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
            count <= 4'b0;
        end else begin
            if (count >= 4'b1111) begin
                count <= 4'b0;        // Retorna a zero ao atingir o máximo
            end else begin
                count <= count + 1'b1;     // Incrementa a contagem
            end
        end
    end

endmodule
