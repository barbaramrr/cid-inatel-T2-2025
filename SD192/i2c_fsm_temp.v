

//////////////////////////////////////////////////////////
////         Módulo MESTRE I2C              //////////////
////////////////////////////////////////////////////////

module i2c_fsm_v2 (
    input           clock,                  // Clock do sistema 
    input           clock100,               // Usado para contar os ciclos de SCl, já possui mesma fase e frequência. Usado pois em casos que SCL é 1 não há como contar ciclos sem usar essa entrada
    input           ack,                // Ack enviado pelo mestre ao Bit_shi, que manda para esse módulo tratar
    input           send,              // Recebe do módulo  Bit_shit, indica que o ack foi recebido e está sendo enviado a esse modulo para analise
    input           nReset,           // reset geral do sistema, volta para o ocioso
    input   [6:0]   endereco,        // Endereço de 7 bits do slave
    input   [6:0]   posicao_reg,     // Posição do dado na Memória 
    input           start,            // Sinal de início do processo de leitura do I2C
    input           sclHigh,        // Sinal do módulo SclGen, indica que o clock SCL está em nível alto
    input           sclFall,
    input           sclRise,
	input           shiftDone,      // Sinal do módulo BitShift, indica que um byte completo (8 bits) foi transmitido ou recebido
	input   [7:0]   rxByte,         // Byte recebido do escravo pelo módulo BitShift
    input           SCL,

	output  [1:0]   shiftMode,      // Define o modo de operação do módulo BitShift (IDLE, LOAD, TX ou RX)
	output  [7:0]   txByte,         // Byte que o mestre deseja transmitir no barramento I2C
	output          sdaDrive,        // Valor lógico que o mestre coloca na linha SDA quando está dirigindo o barramento
	output          enableSdaDrive,   // Habilita o mestre a dirigir a linha SDA (1 = mestre controla SDA, 0 = alta impedância)
    output  [7:0]   data,          // Saída para display de 7 segmentos
    output          Led,                // LED indica erro 
    output          scl_en              // Coloca SCL =1 para gerar Start, Restart e Stop

    
);

    reg [3:0]   current_state; 
    reg [3:0]   next_state;
    reg [1:0]   contador_acks;          // Para verificar se foram recebidos todos os acks antes de mostrar
    reg [1:0]   sclCycle;               // Contador de ciclos SCL
    reg [3:0]   timeout;                // Para gerar o erro se estourar/não chegar o ack no tempo
    reg         erro;                   // Indica erro
    reg [7:0]   Data;                   // Registrador para armazenar dados recebidos serialmente
    reg         rscl_en;                // reg para atribuir scl_en
    reg         startGen, stopGen;      // Indica que start e stop foram gerados, habilitando a transição para proximo estado
    reg         ackrx;                  // reg para atribuir ack

	//registradores internos
    reg [1:0]   rShiftMode;             // reg para atrinuir   shiftMode
    reg [7:0]   rTxByte;                // reg para atrinuir   txByte
    reg         rSdaDrive;              // reg para atrinuir   sdaDrive
    reg         rEnableSdaDrive;        // reg para atrinuir   enableSdaDrive
    reg         restart;                // Indica que restart foi gerados, habilitando a transição para proximo estado


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
    localparam MODE_TX   = 2'b01;
    localparam MODE_RX   = 2'b10;
    localparam MODE_RX_ACK = 2'b11;



    always @(posedge clock or negedge nReset) begin
        if (!nReset) begin // se receber o reset, zera de cara
            current_state   <= S0;
            timeout         <= 4'b0000;
            contador_acks   <= 2'b00;
            erro            <= 1'b0;
            Data            <= 8'b00000000;
            restart         <= 0;
            sclCycle        <= 2'b00;
            startGen        <= 1'b0;
            stopGen         <= 1'b0;
            ackrx           <= 0;

        end else begin
          
           current_state <= next_state;

            if  (sclRise &&(current_state == S3 || current_state == S5 || current_state == S8)) begin
                if (timeout != 4'b1111)
                    timeout <= timeout + 1'b1;
            end else begin
                timeout <= 0;
            end

            if (sclRise && (current_state == S3 || current_state == S5 || current_state == S8)) begin
                if (!ack)
                    contador_acks <= contador_acks + 1'b1;

            end else if (current_state == S0) begin
                contador_acks <= 2'b00;
            end
        end
    end




       always @(posedge clock100 or negedge nReset) begin
        if (!nReset)
            sclCycle <= 0;
        else if (current_state != S1 && current_state != S6 && current_state != S11  && current_state != S12 
                 && current_state != S10 &&  current_state != S13 )
            sclCycle <= 0;
        else if (sclHigh) begin
            if (sclCycle != 2'd3)
                sclCycle <= sclCycle + 1'b1;
        end
    end

    always @(*) begin
        next_state = current_state; 
        case (current_state)
            S0: next_state = (start )       ? S1: S0;              // Espera start externo
            S1: next_state = (startGen )    ? S2: S1;           
            S2: next_state = (shiftDone)    ? S3: S2;           // Espera a contagem de ciclos terminar indicando que os dados foram enviados. Mesma lógica para S4,S7

            S3: begin                                       // S3,S5 e S8 tem mesma lógica mudando apenas o estado de mudança caso esteja tudo correto.
                if (send) begin
                    if (!ack && timeout != 4'b1111)         // Se ack = 0 e time out não estouro habita a transição para estado seguite. Caso contrário vai para erro.
                        next_state = S4;  
                    else
                        next_state = S12;
                end

            end

            S4: next_state = (shiftDone)    ? S5:S4;   

            S5: begin
                if (send) begin
                    if (!ack && timeout != 4'b1111) 
                        next_state = S6;  
                    else
                        next_state = S12; 
                end 
              end

            S6: next_state = (restart)      ? S7: S6;        
            S7: next_state = (shiftDone)    ? S8: S7;

            S8: begin
                if (send) begin
                    if (!ack && timeout != 4'b1111)
                        next_state = S9;  
                    else
                        next_state = S12; // Erro
                end
            end

            S9:  next_state = (shiftDone)   ? S10: S9;         // Espera a contagem de ciclos terminar indicando que os dados foram recebidos
            S10: next_state = (sclCycle==1) ? S11: S10;         // Garante que a fsm fique no estado por um ciclo de SCL
            S11: begin

                if (stopGen) begin
                    if (erro)
                        next_state = S0;
                    else
                        next_state = S13;
                end
                else
                    next_state = S11;

            end
            S12: next_state =(sclCycle==1)? S11: S12;           // Garante que a fsm fique no estado por um ciclo de SCL
            S13: next_state =(sclCycle==2)? S0: S13;            // Garante que a fsm fique no estado por um ciclo de SCL. Como estado anterior usou, neste é preciso verifar se sclCycle =2
            default: next_state = S0;
        endcase
    end


    always @(*) begin

            rShiftMode        = MODE_IDLE;
            rTxByte           = 8'h00;
            rEnableSdaDrive   = 1'b0;
            rSdaDrive         = 1'b1;
            restart           = 0;
            rscl_en           = 1'b0; 
            startGen          = 1'b0;
            stopGen           = 1'b0;


        case (current_state)

			// Idle
            S0: begin
                rEnableSdaDrive = 1'b1;
                rSdaDrive       = 1'b1;

            end

            // GERA_START - pulso de início
            S1: begin
                rEnableSdaDrive = 1'b1;
                case (sclCycle )
                    2'd0:begin
                        rSdaDrive = 1'b1;
                        rscl_en = 1'b0;
                    end 
                    2'd1: begin
                        rSdaDrive = 1'b0;
                        rscl_en = 1'b1;
                        startGen = 1;
                    end

                endcase
            end

			// ENVIA_ENDERECO_ESCRITA via Mode_tx
            S2: begin
                rEnableSdaDrive = 1'b1;
                rTxByte         = {endereco, 1'b0};
                rShiftMode      = MODE_TX;
                rscl_en         = 1;
        
            end

			// AGUARDA_ACK_1,3
            S3, S8: begin
                rEnableSdaDrive = 1'b0; 
                rscl_en         = 1'b1;  
                rShiftMode      = MODE_RX_ACK;
                ackrx             = ack;

            end

			// ENVIA_ENDERECO_MEMORIA
            S4: begin
                rEnableSdaDrive = 1'b1;
                rTxByte         = {posicao_reg, 1'b0};
                rShiftMode      = MODE_TX;
                rscl_en         = 1'b1; 
            end
            // AGUARDA_ACK_2 
             S5: begin
                rEnableSdaDrive = 1'b0; 
                rShiftMode      = MODE_RX_ACK;
                ackrx             = ack;

             end

			// GERA_RESTART
          
            S6: begin

                rEnableSdaDrive = 1'b1;
                case (sclCycle)
                    2'd0:begin
                        rSdaDrive = 1'b1; // PASSO 1: Prepara SDA em ALTO
                        rscl_en = 1'b0;   // Trava SCL em ALTO
                    end 
                    2'd1: begin
                        rSdaDrive = 1'b1; // PASSO 2: Mantém SDA em ALTO de forma estável
                        rscl_en = 1'b0;
                    end
                    2'd2: begin           
                        rSdaDrive = 1'b0; // PASSO 3: SDA desce enquanto SCL está ALTO (Gera o RESTART perfeito!)
                        rscl_en = 1'b1;   // Libera o SCL para voltar a oscilar e transmitir o endereço
                        restart = 1'b1;
                    end
                    default: begin
                        rSdaDrive = 1'b0;
                        rscl_en = 1'b1;
                    end
                endcase
                   
            end


			// ENVIA_ENDERECO_LEITURA
            S7: begin
                rscl_en = 1;
                rSdaDrive = 1'b0;
                rEnableSdaDrive = 1'b1;
                rTxByte         = {endereco, 1'b1};
                rShiftMode      = MODE_TX;
            end

			// LE_DADO
            S9: begin
                rEnableSdaDrive = 1'b0;
                rShiftMode      = MODE_RX;
                rscl_en         = 1'b1; 
                if (shiftDone) begin
                    Data = rxByte;        // Captura o dado recebido
                end

            end

			// ENVIA_NACK
            S10: begin
                rscl_en = 1'b1;   
                rEnableSdaDrive = 1'b1;
                rSdaDrive       = 1'b1;
            end
            

			// GERA_STOP    
            S11: begin
                rEnableSdaDrive = 1'b1;
                rSdaDrive = 1'b1;
                case (sclCycle )
                    2'd0:begin
                        rSdaDrive = 1'b1;
                        rscl_en = 1'b0;
                    end 
                    2'd1: begin
                        rSdaDrive = 1'b0;
                        rscl_en = 1'b0;

                    end
                    2'd2: begin             //Garante
                        rSdaDrive = 1'b1;
                        rscl_en = 1'b1;
                        stopGen = 1'b1;
                    end
                endcase
            end

			// ERRO
            S12: begin
                erro        = 1'b1;
            end

			// Manda o valor lido para o display
            S13: begin
                Data = Data;
            end

            default: begin
                Data = 8'b00000000;
            end
        endcase
        
 
    end

    assign shiftMode        = rShiftMode;
    assign txByte           = rTxByte;
    assign sdaDrive         =rSdaDrive;
    assign enableSdaDrive   = rEnableSdaDrive;
    assign data             = Data;
    assign Led              = erro;
    assign scl_en           = rscl_en;


endmodule
