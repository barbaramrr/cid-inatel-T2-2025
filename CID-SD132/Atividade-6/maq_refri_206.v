// Mealy Method 
module maq_refri_206 (
	input				clk, rst,
	input		[1:0]   moeda, // coin 
	output reg   		D,
	output reg	[1:0] 	T
);

	// [ ] Remover os reg e usar wires
	// reg 		D_aux= 1'b0;
	// reg [1:0]	T_aux; // = T0

	reg [2:0]	current_state, next_state;

	// Quantidade de coins disponíveis. 
	// Troco de:  
	localparam  T0  = 2'b00, // 0 centavos - Sem troco
				T5  = 2'b01, // 5 centavos
				T10 = 2'b10, // 10 centavos
				T20 = 2'b11; // 20 centavos
			 
	localparam  S0 = 3'b000, // inicial
				S1 = 3'b001, // montante = 5
				S2 = 3'b010, // montante = 10
				S3 = 3'b011, // montante = 15
				S4 = 3'b100; // montante = 20
	
	// Analisar o número de coins inseridas
	// Mealy depende do clock ??? <- remover dependência
	always @ (posedge clk or posedge rst) begin 
		current_state <= rst ? S0 : next_state; 
	end

	always @ (*) begin // coin change the state
		
		/*			
		D	<= 1'b0; // << !
		T	<= T0;
		*/
	// Condições inconsistentes
	
		case (current_state)

			S0	:	case (moeda)
						2'b00: begin 
								next_state	<= S0;
										D	<= 1'b0;
										T	<= T0;
							end
						2'b01: next_state <= S1; 
						2'b10: next_state <= S2;
						2'b11: begin
								// Mudar o estado ???
								next_state	<= S0; // moeda inserida de 25 centavos
								D	<= 1'b1;
								T	<= T0;
					end 
					default: next_state <= S0;
				endcase

			// Estado montante = 5 centavos
			S1	:	case (moeda)
						2'b00: next_state <= S1;
						2'b01: begin
								next_state	<= S1; // Invalido Limite de moeda
										D	<= 1'b0;
										T	<= T10;
								// count coins 
								// Ao atingir devolver o acumulado.
							end
						2'b10:	 next_state	<= S3;
						default: next_state <= S0;
					endcase

			// Estado montante = 10 centavos
			S2	:	case (moeda)
						2'b00	: next_state <= S2;
						2'b01	: next_state <= S3; 
						2'b10	: next_state <= S4; 
					default		: next_state <= S0;
				endcase
			// Estado montante = 15 centavos
			S3	:	case (moeda)
						2'b00: next_state <= S3;
						2'b01: next_state <= S4;
						2'b10: begin
							next_state <= S0;
							D = 1'b1; 
							T = T0;
						end
					default: next_state <= S0;
				endcase

			// Estado montante = 20 centavos
			S4	:	case (moeda)
						2'b00: next_state <= S4;
						2'b01: begin
								next_state <= S0;
								D = 1'b1;
								T = T0;
							end 
						2'b10: begin 
							next_state <= S0;
							D <= 1'b1;
							T <= T5;
						end
					default: next_state <= S0;
				endcase
			default: next_state <= S0;
		endcase
		// cs <= ns
	end

	// Característica Moore... 
	// assign D_aux = D;
	// assign T = T_aux;

endmodule
