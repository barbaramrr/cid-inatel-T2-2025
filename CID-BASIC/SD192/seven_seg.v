// Coversão em Hexa: o segmento DP(decimal point) tem como intuito sinalizar que o valor mostrado no display
// é um numero decimal, permanecendo ele desligado quando for uma letra.

module display7seg(
    input  [3:0] data,
    input  error, en,
    output reg [7:0] seg   // Segmentos do display {a,b,c,d,e,f,g,dp}
);

always @(*) begin

    if (error) begin
        seg = 8'b00000001;   // Indicativo de Erro (somente o ponto (dp) ligado)
    end else if (!en) begin
        seg = 8'b00000000; // apagado
        end
    else begin
        case (data)
            4'h0: seg = 8'b11111101; // 0
            4'h1: seg = 8'b01100001; // 1
            4'h2: seg = 8'b11011011; // 2
            4'h3: seg = 8'b11110011; // 3
            4'h4: seg = 8'b01100111; // 4
            4'h5: seg = 8'b10110111; // 5
            4'h6: seg = 8'b10111111; // 6
            4'h7: seg = 8'b11100001; // 7
            4'h8: seg = 8'b11111111; // 8
            4'h9: seg = 8'b11110111; // 9

            4'hA: seg = 8'b11101110; // A
            4'hB: seg = 8'b00111110; // b
            4'hC: seg = 8'b10011100; // C
            4'hD: seg = 8'b01111010; // d
            4'hE: seg = 8'b10011110; // E
            4'hF: seg = 8'b10001110; // F

            default: seg = 8'b00000000; // apagado
        endcase
    end
end
endmodule


