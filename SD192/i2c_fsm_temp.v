/*
Programa: CI Digital/INATEL  - Turma: 2 
Trabalho Orientado I  - MESTRE I2C PARA LEITURA DE MEMÓRIA
Orientador: Felipe Rocha 
Grupo: 4
Integrantes: 
Alessandra Carolina Domiciano  
Bruno Augusto Caetano Coura  
Bárbara Mariana Rocha Raimundo  Emmanuel Priestley Titus 
Fábio Henrique Moreira  
Gabriel Kenedy Alves  
Julia de Freitas Carvalho  
Lucas Lares Fonseca  
Luis Henrique Azevedo dos Santos
Mateus Nassar Gouvêa Pereira  
Samuel Josias Ross

Data: Fevereiro/2026
*/
//////////////////////////////////////////////////////////
////         Módulo MESTRE I2C              //////////////
////////////////////////////////////////////////////////

module i2c_fsm_v2 (
    input           clock,          // Clock do sistema 
    input           ack,
    input           nReset,           // reset geral do sistema, volta para o ocioso
    input   [6:0]   endereco,        // Endereço de 7 bits do slave
    input   [6:0]   posicao_reg,     // Posição do dado na Memória 
    input           start,            // Sinal de início do processo de leitura do I2C
    input           sclHigh,        // Sinal do módulo SclGen, indica que o clock SCL está em nível alto
    input           sclRise,
	input           shiftDone,      // Sinal do módulo BitShift, indica que um byte completo (8 bits) foi transmitido ou recebido
	input   [7:0]   rxByte,         // Byte recebido do escravo pelo módulo BitShift
    input           SCL,

	output  [1:0]   shiftMode,      // Define o modo de operação do módulo BitShift (IDLE, LOAD, TX ou RX)
	output  [7:0]   txByte,         // Byte que o mestre deseja transmitir no barramento I2C
	output          sdaDrive,        // Valor lógico que o mestre coloca na linha SDA quando está dirigindo o barramento
	output          enableSdaDrive,   // Habilita o mestre a dirigir a linha SDA (1 = mestre controla SDA, 0 = alta impedância)
    output  [7:0]   display,          // Saída para display de 7 segmentos
    output          Led,                // LED indica erro 
    output          scl_en

    
);

    reg [3:0]   current_state; 
    reg [3:0]   next_state;
    reg [1:0]   contador_acks;        // Para verificar se foram recebidos todos os acks antes de mostrar
    reg [1:0]   gen_state ;
    reg [3:0]   timeout;              // Para gerar o erro se estourar/não chegar o ack no tempo
    reg         erro;                  // Indica erro
    reg [7:0]   Data;                 // Registrador para armazenar dados recebidos serialmente
    reg         rscl_en;
    reg         start_in;

	//registradores internos
    reg [1:0]   rShiftMode;
    reg [7:0]   rTxByte;
    reg         rSdaDrive;
    reg         rEnableSdaDrive;
    reg [7:0]   display_reg;
    reg         restart;

    // Definição dos estados
    localparam  S0  = 4'b0000, // OCIOSO - aguarda novo início
                S1  = 4'b0001, // GERA_START - pulso de início
                S2  = 4'b0010, // ENVIA_ENDERECO_ESCRITA
                S3  = 4'b0011, // AGUARDA_ACK_1
                S4  = 4'b0100, // ENVIA_ENDERECO_MEMORIA
                S5  = 4'b0101, // AGUARDA_ACK_2
                S6  = 4'b0110, // GERA_RESTART
                S7  = 4'b0111, // ENVIA_ENDERECO_LEITURA
                S8  = 4'b1000, // AGUARDA_ACK_3
                S9  = 4'b1001, // LE_DADO
                S10 = 4'b1010, // ENVIA_NACK
                S11 = 4'b1011, // GERA_STOP (mostra no display)
                S12 = 4'b1100, // ERRO
                S13 = 4'b1101; // Manda o valor lido para o display

	// Definição dos modos do BitShift
    localparam MODE_IDLE = 2'b00;
    localparam MODE_LOAD = 2'b01;
    localparam MODE_TX   = 2'b10;
    localparam MODE_RX   = 2'b11;



    always @(posedge clock or negedge nReset) begin
        if (!nReset) begin // se receber o reset, zera de cara
            current_state   <= S0;
            timeout         <= 4'b0000;
            contador_acks   <= 2'b00;
            erro            <= 1'b0;
            Data            <= 8'b00000000;
            display_reg     <= 8'b00000000;
            restart         <= 0;
            gen_state     <= 0;
        end else begin
            current_state <= next_state;

            if (current_state == S3 || current_state == S5 || current_state == S8) begin
                if (timeout != 4'b1111)
                    timeout <= timeout + 1'b1;
            end else begin
                timeout <= 0;
            end

            if ((current_state == S3 || current_state == S5 || current_state == S8) && !ack)
                contador_acks <= contador_acks + 1'b1;
            else if (current_state == S0)
                contador_acks <= 2'b00;

        end
    end

    always @(negedge clock) begin
        next_state = current_state; 
        case (current_state)
            S0: next_state <= (start)? S1: S0;
            S1: next_state <= (start_in)? S2: S1;
            S2: next_state <= (shiftDone)? S3: S2;

            S3: begin
                if (!ack && timeout != 4'b1111)
                    next_state <= S4;  
                else
                    next_state <= S12;
            end

            S4: next_state <= (shiftDone)? S5:S4;

            S5: begin
                if (!ack && timeout != 4'b1111) 
                    next_state <= S6;  
                else
                    next_state <= S12; 
            end

            S6: next_state <= (restart)? S7: S6;
            S7: next_state <= (shiftDone)? S8: S7;

            S8: begin
                if (!ack && timeout != 4'b1111)
                    next_state <= S9;  
                else
                    next_state <= S12; 
            end

            S9:  next_state <= (shiftDone)? S10: S9;
            S10: next_state <= S11;
            S11: next_state <= (erro)? S0: S13;
            S12: next_state <= S11; 
            S13: next_state <= S0; 
            default: next_state <= S0;
        endcase
    end

    always @(*) begin

            rShiftMode        <= MODE_IDLE;
            rTxByte           <= 8'h00;
            rEnableSdaDrive   <= 1'b0;
            rSdaDrive         <= 1'b1;
            restart           <= 0;

        case (current_state)

			// GERA_START - pulso de início
            S0: begin
                rEnableSdaDrive <= 1'b1;
                gen_state <= 0;
                rSdaDrive <= 1'b1;
                erro <= 0;
            end

            S1: begin
                rEnableSdaDrive <= 1'b1;
                case (gen_state )
                    2'd0:begin
                            rSdaDrive <= 1'b1;
                            rscl_en <= 1'b0;
                            gen_state  <= 2'd1;
                    end 
                    2'd1: begin
                        rSdaDrive <= 1'b0;
                        rscl_en <= 1'b1;
                        gen_state  <= 2'd2;
                        start_in <= 1;
                    end

                endcase
            end

			// ENVIA_ENDERECO_ESCRITA via Mode_tx
            S2: begin
                gen_state       <= 0;
                rEnableSdaDrive <= 1'b1;
                rTxByte         <= {endereco, 1'b0};
                rShiftMode      <= MODE_TX;
                rscl_en         <= 1;
        
            end

			// AGUARDA_ACK_1,2 e 3
            S3, S8: begin
                rEnableSdaDrive <= 1'b0;  

            end

			// ENVIA_ENDERECO_MEMORIA
            S4: begin
                rEnableSdaDrive <= 1'b1;
                rTxByte         <= {posicao_reg, 1'b0};
                rShiftMode      <= MODE_TX;
            end

             S5: begin
                rEnableSdaDrive <= 1'b0;  

             end

			// GERA_RESTART
            S6: begin
                rEnableSdaDrive <= 1'b1;
              // if (sclHigh) begin
                case (gen_state )
                    2'd0:begin
                            rSdaDrive <= 1'b1;
                            rscl_en <= 1'b0;
                            gen_state  <= 2'd1;
                    end 
                    2'd1: begin
                        rSdaDrive <= 1'b0;
                        rscl_en <= 1'b1;
                        gen_state  <= 2'd2;
                        
                    end
                    2'd2: begin
                        rSdaDrive <= 1'b0;
                        rscl_en <= 1'b1;
                         restart <= 1;
                    end

                endcase
             //  end
               

            end

			// ENVIA_ENDERECO_LEITURA
            S7: begin
                gen_state <= 0;
                rscl_en <= 1;
                rEnableSdaDrive <= 1'b1;
                rTxByte         <= {endereco, 1'b1};
                 rShiftMode      <= MODE_TX;
   
            end

			// LE_DADO
            S9: begin
                rEnableSdaDrive <= 1'b0;
                rShiftMode      <= MODE_RX;

            end

			// ENVIA_NACK
            S10: begin
               // if(sclHigh)
                rEnableSdaDrive <= 1'b1;
                rSdaDrive       <= 1'b1;
                
            end

			// GERA_STOP
            S11: begin
                if (sclHigh)
                    rSdaDrive <= 1'b1;
            end

			// ERRO
            S12: begin
                
                erro        <= 1'b1;
                display_reg <= 8'b00000110; //Mostrar E no display
                Data        <= 8'b00000110;
            end

			// Manda o valor lido para o display
            S13: begin
                display_reg <= Data;
            end

            default: begin
                display_reg <= 8'b00000000;
            end
        endcase
        
        if (current_state == S9 && shiftDone) begin
             Data <= rxByte[7:0];
        end
               
    end

    assign shiftMode      = rShiftMode;
    assign txByte         = rTxByte;
    //assign sdaDrive       = rEnableSdaDrive? rSdaDrive: 1'bz;
    assign sdaDrive        =rSdaDrive;
    assign enableSdaDrive = rEnableSdaDrive;
    assign display        = display_reg;
    assign Led            = erro;
    assign scl_en         = rscl_en;


endmodule