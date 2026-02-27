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
////         Testbench MESTRE I2C              //////////////
////////////////////////////////////////////////////////

module testbench_i2c_fsm_v3 (
    input wire clk,
    input wire scl,
    inout wire sda
);

   
    // ----- Estados da FSM -----
    
    localparam IDLE        = 3'd0,  // estado parado
               RX_DEV_ADDR = 3'd1,  // recebe endereço do dispositivo
               ACK_DEV     = 3'd2,  // enviando ack do endereço
               RX_MEM_ADDR = 3'd3,  // recebendo endereço interno da memoria
               ACK_MEM     = 3'd4,  // enviando ack do endereço da memória interno
               TX_DATA     = 3'd5,  // Transmitindo dado ao mestre
               MASTER_ACK  = 3'd6;  // mestre envia ACK, 0 contiua lendo, 1 quer parar NACK

    parameter SLAVE_ADDR = 7'h50;   // endereço do escravo

    
    // ----- Registradores internos -----

    reg [7:0] addr_ptr;   // armazena o indereço interno da memória
    reg [7:0] shift_reg;  // registrador de deslocamnto para montar o byte recebido
    reg [3:0] bit_cnt;    // contador de bits enviados e recebidos
    reg [2:0] state;     // estado atual
    reg rw_bit;          // bit de leitura ou escrita. 0 escrita e 1 leitura
    reg sda_prev;        // valor anterior de SDA
    


    reg sda_out;         // valor enviado
    reg sda_en;          // valor recebido

    wire [7:0] mem_data;  // dado recebido da memória
 
 // ----Sincronização de SCL e SDA---
 
    reg scl_sync0, scl_sync1;   // reg para salvar estados do SCL
    reg sda_sync0, sda_sync1;   // reg para salvar estado do SDA
    reg sda_prev_sync;          // estado anterior SDA

    always @(posedge clk) begin
        scl_sync0 <= scl;        // salva estado do scl
        scl_sync1 <= scl_sync0;  // salva estado anterior atraso de um pulso

        sda_sync0 <= sda;        // salva estado do SDA
        sda_sync1 <= sda_sync0;  // salva estado anterior atraso de um pulso

        sda_prev_sync <= sda_sync1;   // salva estado anterior atraso de dois pulso de sda
    end

    wire scl_rising  = (scl_sync0 & ~scl_sync1);     // detecta pulso de subida de SCL
    wire scl_falling = (~scl_sync0 & scl_sync1);     // detecta puslo de descida de SCL

   wire start_cond = (sda_prev_sync == 1'b1) &&     // condição de START, quando ocorre transição de descida de SDA enquanto SCL esta em 1
                  (sda_sync1     == 1'b0) &&        
                  (scl_sync1     == 1'b1);

   wire stop_cond  = (sda_prev_sync == 1'b0) &&    // condição STOP, quando ocorre transição de subida de SDA enquanto SCL esta em 1
                  (sda_sync1     == 1'b1) &&       
                  (scl_sync1     == 1'b1);



    
    // ----- Instância da memória -----

    eeprom #(
        .TAMANHO_DADOS(8),
        .TAMANHO_ENDERECO(4)
    ) memoria_inst (
        .endereco(addr_ptr[3:0]), // usa apenas 4 bits
        .clk(clk),
        .dados_saida(mem_data)
    );

    
    // ----- Controle Tri-State do SDA -----

    assign sda = (sda_en) ? sda_out : 1'bz;      // Se sda_en = 1, escravo dirige a linha. Se 0, linha fica em alta impedância.

   
    // ----- Inicialização -----

    initial begin        // definição de valores iniciais
        state   = IDLE;
        sda_en  = 0;
        sda_out = 1'b1;
        bit_cnt = 0;
        shift_reg = 8'd0;
    end

    // ----- FSM I2C -----

    always @(posedge clk) begin  
                                 // por enquanto utilizando a borda de subida, mas tem que ser quando esta estável em 1

    if (start_cond) begin
    state   <= RX_DEV_ADDR;
    bit_cnt <= 0;
    sda_en  <= 0;
    end

    else if (stop_cond) begin
    state  <= IDLE;
    sda_en <= 0;
    end

    // ----- FSM roda sincronizada com CLK ----- 
    
    case(state)
    
            // ----------------------
            IDLE: begin               // estado 000
            sda_en  <= 0;             // desabilita que o escravo use a linha
            bit_cnt <= 0;             // zera contador

            end


            // ----------------------
            RX_DEV_ADDR: begin                    // estado 001
                if (scl_rising) begin        
                if (bit_cnt < 7) begin             // recebe 7 bits de endereço
                    shift_reg[6-bit_cnt] <= sda_sync1;   // armazena bit recebido 
                    bit_cnt <= bit_cnt + 1;        // incremento, até chegar os  bits 
                end else begin                   // no 8° bit
                    rw_bit <= sda_sync1;        // salva bit em rw_bit
                    bit_cnt <= 0;               //zera contador
                    state <= ACK_DEV;          // próximo estado
                end
            end
        end

            // ----------------------
            ACK_DEV: begin                   // estado 010
                if (scl_falling) begin
                if (shift_reg == SLAVE_ADDR) begin    // verifica se o endereço enviado pelo mestre é o dele
                    sda_en  <= 1;                          // habilita o escravo utilizar a linha
                    sda_out <= 1'b0;  // ACK               // envia ACK baixo, dizendo que recebeu corretamente
                end else begin
                    state <= IDLE;
                end
            end
                   if (scl_rising) begin
                    sda_en <= 0;   // libera linha após ACK
                   if (rw_bit == 1'b0)
                    state <= RX_MEM_ADDR;
                else
                    state <= TX_DATA;
                end
            end
    
     

            // ----------------------  
            RX_MEM_ADDR: begin                          // estado 011 recebe endereço interno da memoria 
                sda_en <= 0;                           // desabilita que o escravo use a 
                if (scl_rising)begin
                shift_reg[7-bit_cnt] <= sda_sync0;            // armazena o byte recebido bit a bit

                if (bit_cnt == 7)                      // se já recebeu os 8 bits
                    state <= ACK_MEM;                  // vai para o próximo estado
                else
                    bit_cnt <= bit_cnt + 1;           // se não, continua recebendo
            end
        end

            // ----------------------
            ACK_MEM: begin                     // estado 100
                if (scl_falling) begin                    
                addr_ptr <= shift_reg;         // copia o byte do shift_reg para addr_ptr, sera usado para acessar a memória
                sda_en   <= 1;                 // habilita o uso da linha pelo o escravo
                sda_out  <= 1'b0;              // envia ACK, dizendo que recebeu o endereço corretamente
                end 
                if (scl_rising) begin
                    sda_en   <= 0;
                    bit_cnt  <= 0;
                    state  <= IDLE;
                end
            end

            // ----------------------
            TX_DATA: begin                         // estado 101 aqui o escravo envia o dado da memória para o mestre
                sda_en  <= 1;                      // habilita o uso da linha pelo escravo
                if(scl_falling) begin
                sda_out <= mem_data[7-bit_cnt];    // envia o s 8 bits sendo o primeiro mais siguinificativo MSB
                end
                
                if(scl_rising) begin
                if (bit_cnt == 7) begin            // se já enviou os 8 bits
                    bit_cnt <= 0 ;
                    state <= MASTER_ACK;                // estado do envio do ACK DO MESTRE
                end else begin
                    bit_cnt <= bit_cnt + 1;      // se não, continua enviando
                end
            end
        end
        

            MASTER_ACK: begin                   // estado 110 , aqui escravo aguarda o ACK ou NACK do mestre
                sda_en <= 1'b0; 
                if (scl_falling) begin   // 9º clock - mestre controla SDA
                sda_en <= 1'b0;   // libera linha para o mestre
                end

                if (scl_rising) begin
                if (sda_sync0 == 1'b0) begin // Mestre enviou ACK igual a 0 → continua enviando próximo byte
                    state <= TX_DATA;
                    addr_ptr <= addr_ptr + 1;       // se estiver usando endereço sequencial:
                    //mem_data <= memoria[addr_ptr + 1];
                end else begin  // Mestre enviou NACK → encerra transmissão
                    state <= IDLE;
                    end
                end

            end

            // ----------------------
            default: state <= IDLE;          // volta ao estado inicial

        endcase
    end
    

endmodule
