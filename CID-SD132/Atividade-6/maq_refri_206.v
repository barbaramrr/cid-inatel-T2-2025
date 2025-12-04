module maq_refri_206 (
    input           clk, rst,
    input [1:0]     moeda,
    output          D1,
    output  [1:0]   T
);

reg D;
reg [1:0] T_aux;

reg [2:0] current_state, next_state;

parameter   T0  = 2'b00, // Sem troco
            T5  = 2'b01, // Troco de 5 centavos
            T10 = 2'b10, // Troco de 10 centavos
            T20 = 2'b11; // Troco de 20 centavos
         
parameter   S0 = 3'b000,    // inicial
            S1 = 3'b001,   // montante = 5
            S2 = 3'b010,   // montante = 10
            S3 = 3'b011,  // montante = 15 
            S4 = 3'b100; // montante = 20  c

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= S0;
        D <= 1'b0;
        T_aux <= T0; 
    end
  
    else
        current_state <= next_state;
end

always @ (moeda or current_state) begin
    next_state = current_state;
    D     = 1'b0;
    T_aux = T0;

    case (current_state)

        S0:
            case (moeda)
                2'b00: next_state = S0;
                2'b01: next_state = S1; 
                2'b10: next_state = S2;

                2'b11: begin
                    next_state = S0; // moeda inserida de 25 centavos
                    D = 1'b1;
                    T_aux = T0;
                end 
      
                default: next_state = S0;
            endcase

        ///////////////// Estado montante = 5 centavos/////////////
        S1:
            case (moeda)
                2'b00: next_state = S1;

                2'b01: begin
                    next_state = S1; // Invalido Limite de moeda
                    D = 1'b0;
                    T_aux = T10;
                end

                2'b10: next_state = S3; 

                default: next_state = S0;
            endcase

        ///////////////// Estado montante = 10 centavos/////////////
        S2:
            case (moeda)
                2'b00: next_state = S2;
                2'b01: next_state = S3; 
                2'b10: next_state = S4; 
                default: next_state = S0;
            endcase

        //////////////// Estado montante = 15 centavos/////////////
        S3:
            case (moeda)
                2'b00: next_state = S3;
                2'b01: next_state = S4;

                2'b10: begin
                    next_state = S0;
                    D = 1'b1; 
                    T_aux = T0;
                end

                default: next_state = S0;
            endcase

        //////////////// Estado montante = 20 centavos/////////////
        S4:
            case (moeda)
                2'b00: next_state = S4;

                2'b01: begin
                    next_state = S0;
                    D = 1'b1;
                    T_aux = T0;
                end 

                2'b10: begin 
                    next_state = S0;
                    D = 1'b1;
                    T_aux = T5;
                end

                default: next_state = S0;
            endcase

    endcase
end

assign D1 = D;
assign T = T_aux;

endmodule
