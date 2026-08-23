  module eeprom (
    input           clock, // Clock do sistema
    input           nReset, // Reset ativo em nível baixo
    inout           SDA, // Linha de dados I2C
    input          SCL  // Linha de clock I2C
    
  );


    //---------------- Lendo os dados da memoria de um arq txt --------------------------//////
        reg [7:0] memoria [0:15];

        initial begin
        $readmemh("Dados.txt", memoria);
        end  
    
        // ----- Estados da FSM -----
        
        localparam  IDLE            = 4'd0,     // estado inicial zera alguns sinais. Espera a detecção do Start
                    RX_DEV_ADDR     = 4'd1,     // recebe endereço do dispositivo
                    ACK_DEV         = 4'd2,     // enviando ack do endereço
                    RX_MEM_ADDR     = 4'd3,     // recebendo endereço interno da memoria
                    ACK_MEM         = 4'd4,     // enviando ack do endereço da memória interno
                    WAIT_RESTART    = 4'd5,     // Espera o restart
                    RX_DEV_ADDR_R   = 4'd6,     // ADDR + R
                    ACK_ADDR_R      = 4'd7,     // enviando ack do endereço da EEPROM
                    TX_DATA         = 4'd8,     // Transmitindo dado ao mestre
                    MASTER_ACK      = 4'd9;     // mestre envia ACK, 0 contiua lendo, 1 quer parar NACK

        parameter SLAVE_ADDR = 7'h50;   // endereço da EEPROM
        parameter TAMANHO_ENDERECO = 16;

        
        // ----- Registradores internos -----


        reg [6:0]   addr_ptr;                   // armazena o endereço que o mestre enviou
        reg [6:0]   index;                      // armazena o indice que o mestre enviou
        reg [7:0]   shift_reg;                   // registrador de deslocamnto para montar o byte recebido
        reg [3:0]   bit_cnt;                    // contador de bits enviados e recebidos
        reg [3:0]   state, next_state;          // estado atual / Proximo Estado
        reg         rw_bit;                     // bit de leitura ou escrita. 0 escrita e 1 leitura
        reg         ack_slave;                  // ack que o escravo manda
        reg         done, send;                 // Indica o fim da contagem / Sck enviado 
        reg [3:0]   nCycle;                     // Conta ciclos de SCL              
        
    //------------------ SDA DO SLAVE e Sinal que habilita o uso da linha SDA pelo SLAVE

        reg         sda_out;                    // SDA enviado pela EEPROM
        reg         sda_en;                     // Habita o envio pela EEPROM
        reg         scl_ff1, scl_ff2;           // Estabilizadores

        // Como o clock do sistema, usado nos always é mais rápido que a comunicação é preciso esse buffers (sda_ff1, sda_ff2;)para garantir que está detectar mesmo a borda do SCL

        reg         sda_ff1, sda_ff2;           
        reg         scl_before,scl_reg;         // Usado para detectar as bordas do scl. Valor atual e antigo
        reg         sda_before,sda_reg;         // Usado para detectar as bordas do sda. Valor atual e antigo. Assim detectar start e stop
        reg         startDone, stopDone;
        reg         nack_rx;

    // ----Sincronização de SCL e SDA---

    // -------------- Aqui é feito toda a lógica usada para decteção do start e stop

        always @(posedge clock or negedge nReset) begin
            if (!nReset) begin
                scl_ff1 <= 1'b1;
                scl_ff2 <= 1'b1;
                sda_ff1 <= 1'b1;
                sda_ff2 <= 1'b1;
                scl_before <= 1'b1;
                sda_before <= 1'b1;

            end else begin
                scl_ff1 <= SCL;
                scl_ff2 <= scl_ff1;
                scl_before <= scl_reg;
                sda_before <= sda_reg;
                sda_ff1 <= SDA;
                sda_ff2 <= sda_ff1;
                scl_reg <= scl_ff2;
                sda_reg <= SDA;
               
            end
        end
        
        wire scl_rise = (!scl_before && scl_reg  );
        wire scl_fall = (scl_before && !scl_reg  );


        wire start_cond = (sda_before == 1'b1 &&        // condição de START, quando ocorre transição de descida de SDA enquanto SCL esta em 1
                            sda_reg    == 1'b0 &&
                            scl_reg    == 1'b1);
                            
        wire stop_cond = (sda_before == 1'b0 &&         // condição STOP, quando ocorre transição de subida de SDA enquanto SCL esta em 1
                            sda_reg    == 1'b1 &&
                            scl_reg    == 1'b1);




    //-----------------------  SLAVE DIRIGE O SDA/ QUANDO NÃO DIRIGE COLOCA Z-------------------------------------

        assign SDA = (sda_en) ? sda_out : 1'bz;      // Se sda_en = 1, escravo dirige a linha. Se 0, linha fica em alta impedância.

    
        //------ Always que atualiza o state

        always @(posedge clock or negedge nReset) begin
            if (!nReset)
                state <= IDLE;
            else
                state <= next_state;
        end
    
        //------------- Always com a lógoca de mudança de estados

        always @(*) begin
            next_state = state;
  

            case(state)
                IDLE:           next_state = startDone  ? RX_DEV_ADDR   : IDLE;                         // Start detectado avança. Se não permanece em Idle
                RX_DEV_ADDR:    next_state = done       ? ACK_DEV       : RX_DEV_ADDR;                  // Recebe os dados bit a bit até a contagem acabar. Mesmo para RX_MEM_ADDR e RX_DEV_ADDR_R

                ACK_DEV: begin
                                if (send) begin
                                    if (!ack_slave) begin                                               // Caso ack = 1 (erro) desvia para Idle. Caso contrário avança. O mesmo para ACK_MEM e ACK_ADDR_R
                                        next_state = RX_MEM_ADDR; 
                                    end
                                    else
                                        next_state =  IDLE; 
                                end
                                else
                                        next_state = ACK_DEV;
                end

                RX_MEM_ADDR:    next_state = done       ? ACK_MEM       : RX_MEM_ADDR;

                ACK_MEM:    begin
                                if (send) begin
                                    if (!ack_slave) begin
                                        next_state = WAIT_RESTART; 
                                    end
                                    else
                                        next_state =  IDLE; 
                                end
                                else
                                        next_state = ACK_MEM;
                            end   
                WAIT_RESTART:
                            if (startDone)                        
                                next_state = RX_DEV_ADDR_R;                         
                            else if (stopDone)
                                next_state = IDLE;
                            else
                                next_state = WAIT_RESTART;

                RX_DEV_ADDR_R:  next_state = done           ? ACK_ADDR_R    : RX_DEV_ADDR_R;

                ACK_ADDR_R:     begin
                                    if (send) begin
                                        if (!ack_slave) begin
                                            next_state = TX_DATA; 
                                        end
                                        else
                                            next_state =  IDLE; 
                                    end
                                    else
                                            next_state = ACK_ADDR_R;
                                end  
                TX_DATA:        next_state = done           ?   MASTER_ACK    : TX_DATA;
                MASTER_ACK:    begin
                    if (nack_rx) begin
                        next_state = (ack_slave)    ?   IDLE :MASTER_ACK; 
                    end
                    else
                         next_state = MASTER_ACK;
                end
                
            default:         next_state = IDLE;
            endcase

        end


        always @(posedge clock or negedge nReset) begin
            if (!nReset) begin
                bit_cnt <= 3'd7;
                done    <= 0;
                shift_reg <= 0;
                addr_ptr  <= 0;
                index     <= 0;
                rw_bit      <= 0;
               

            end else begin
                done <= 0;
                startDone <= start_cond;
                stopDone  <= stop_cond;

//------ If usado para carregar o contador com o valor de 7 e o done com 0 para os estados que vão usa-los. Para que iniciem com o valor correto sempre

                if (state != next_state) begin
                    if (next_state == RX_DEV_ADDR   ||
                        next_state == RX_DEV_ADDR_R ||
                        next_state == RX_MEM_ADDR   ||
                        next_state == TX_DATA) begin
                        bit_cnt <= 3'd7;
                        done    <= 1'b0;
                    end
                end
                case(state)

                    IDLE: begin
                        bit_cnt <= 3'd7;
                    end
//------------------------ Recebe endereço no primeiro envio e no segundo

                    RX_DEV_ADDR ,RX_DEV_ADDR_R: begin
                        if (scl_fall) begin                 
                            shift_reg[bit_cnt] <= SDA;
                            if (bit_cnt == 0) begin
                                bit_cnt <= 3'd7;
                                done   <= 1;
                            end else begin
                                done <= 0;
                                bit_cnt <= bit_cnt - 1;
                            end
                        end
                        if (scl_rise) begin
                            addr_ptr <= shift_reg [7:1];                // Armazena em Rise
                            rw_bit <= (bit_cnt == 0)?SDA: 0;
                        end
                    end

//----------------------- Recebe o indice da memória a ser acessado

                    RX_MEM_ADDR: begin
                        if (scl_fall) begin

                            shift_reg[bit_cnt] <= SDA;
                            if (bit_cnt == 0) begin
                                shift_reg <= shift_reg[7:1];
                                bit_cnt <= 3'd7;
                                done    <= 1'b1;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                                done <= 0;  
                            end
                        end
                        
                        if (scl_rise) begin
                            index <= shift_reg[7:1];        // Armazena em Rise
                            rw_bit <= (bit_cnt == 0)?SDA: 0;
                        end
                        
                    end     

/// ------------------------- Usado para decrementar o contador do dado que será enviado. É decrementado em rise, mas enviado em fall. Pq mudanças no SDA de ocorrer em scl low

                    TX_DATA: begin
                        if (scl_rise) begin
                            if (bit_cnt == 0) begin
                                bit_cnt <= 3'd7;
                                done <= 1;
                            end else
                                bit_cnt <= bit_cnt - 1;
                        end
                    end

                endcase
            end
        end

        
        // ---------- Envio ACK e dos dados da EEPROM via SDA. SDA é altera só em scl Low --------------------------------


        always @(negedge clock) begin
            if (!nReset) begin
                nCycle    <= 0;
                ack_slave <= 0;
                sda_out   <= 0;
                send      <= 0;
                nack_rx   <= 0;

            end else begin

// -------------- Contador usado para contar ciclos e assim fazer a fsm ficar no estados de ack por um ciclo de scl
            if (state ==ACK_DEV || state== ACK_ADDR_R || state == ACK_MEM || state == MASTER_ACK) begin
                if(scl_rise)
                    nCycle <= nCycle + 1'b1;
                end

            case(state)

                ACK_DEV, ACK_ADDR_R: begin
               
                    sda_en  <= 1;
                    send    <= 0;
          
                    if (addr_ptr == SLAVE_ADDR ) begin
                        sda_out     <= 0;      // ACK    
                        ack_slave   <=  1'b0;                
                    end else begin
                        sda_out     <= 1;      // NACK   
                        ack_slave   <=  1'b1;
                    end
                    if (nCycle == 1) begin
                        send <= 1'b1; 
                        nCycle <= 0;
                    end
//------------------  Caso RW seja o errado ------------------

                    if ((addr_ptr == SLAVE_ADDR) && (rw_bit == (state == ACK_ADDR_R))) begin
                        sda_out     <= 1'b0;   // ACK
                        ack_slave   <=  1'b0;
                    end

                    else begin
                        sda_out     <= 1'b1;  
                        ack_slave   <=  1'b1;
                    end

                end

                ACK_MEM: begin
                    sda_en  <= 1;
                    send    <= 0;
                        if (index < TAMANHO_ENDERECO) begin
                            sda_out     <= 0;      // ACK
                            ack_slave   <=  1'b0;
                            
                        end else begin
                            sda_out     <= 1;      // NACK   
                            ack_slave   <=  1'b1;
                    
                    end
                    if (nCycle == 1) begin
                        send <= 1'b1; 
                        nCycle <= 0;
                    end
            
                end  

              // ------------------ Recebe ACk do mestre

                MASTER_ACK: begin

                        ack_slave <= SDA;    

                     if (nCycle == 1) begin
                        nack_rx <= 1'b1; 
                        nCycle <= 0;

                     end
                end      
            
  
         // ------------------- Envio do Dado----------------------

                TX_DATA: begin
                    if (scl_fall) begin
                        sda_en  <= 1;
                        sda_out <= memoria[index][bit_cnt];
                    end
                end
                
                default: begin
                    sda_en <= 0;
                end
            
            
            endcase

            

            end

        end
endmodule
