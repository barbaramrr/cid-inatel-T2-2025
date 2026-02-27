module SclGen (
	input systemClk, //Esse e o clock do sistema
	input enable, //Entrada para identificar se o i2c esta ou nao em modo ocioso
	input nReset, //Reset ativo em nivel baixo
	output scl, //clock do i2c
	output sclHigh, //Para identificar se o SCL esta em nivel alto (criado para mostrar explicitamente a informacao)
	output sclLow, //Para identificar se o SCL esta em nivel baixo (criado para mostrar explicitamente a informacao)
	output sclRise, //Para identificar se o SCL esta na borda de subida (criado para mostrar explicitamente a informacao)
	output sclFall, //Para identificar se o SCL esta na borda de descida (criado para mostrar explicitamente a informacao)
	output clk100
);

	parameter SYS_CLK_FREQ = 50_000_000;
    parameter I2C_FREQ = 100_000;
	
	localparam integer DIVIDER = SYS_CLK_FREQ / (I2C_FREQ * 2);
	
	reg [$clog2(DIVIDER):0] counter; //contador para a alterenancia do clock do i2c
    reg sclReg;
	reg clock_100;
    reg sclRegBefore; // para armazenar o clock anterior
	
	//Geracao do scl a partir do clock do sistema
		always @(posedge systemClk or negedge nReset) begin
			if (!nReset) begin
				counter   <= 0;
				sclReg    <= 1'b1;
				clock_100 <= 1'b1;

			end else begin
				if (counter == DIVIDER - 1) begin
					counter   <= 0;
					clock_100 <= ~clock_100;

					if (enable)
						sclReg <= ~sclReg;
					else
						sclReg <= 1'b1;   // idle do I2C
				end else begin
					counter <= counter + 1;
				end
			end
		end
	
	//Para armazenar o clock anterior e conseguir gerar os dados explicitos do scl
	always @(posedge systemClk or negedge nReset) begin
		if (!nReset) begin
			clock_100 <= 1'b1;
		end else begin
			sclRegBefore <= clock_100;
		end
	end
	
	assign scl = sclReg;
	assign sclHigh = clock_100;
    assign sclLow = ~clock_100;
    assign sclRise = (sclReg & ~sclRegBefore);
    assign sclFall = (~sclReg &  sclRegBefore);
	assign clk100 = clock_100;
	
endmodule