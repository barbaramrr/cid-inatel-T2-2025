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
`timescale 1ns/1ps
module testbench_i2c_fsm_v2;

    parameter TAMANHO_ENDERECO = 9;
    parameter [6:0] addr_slave = 7'h10;
    reg clock;
    reg nReset;
    reg [6:0] endereco;
    reg [6:0] posicao_reg;
    reg start;

    wire [7:0] display;   
    wire Led;
    wire SDA;
    wire SCL;

    i2c_master_top uut (
        .clock(clock),
        .nReset(nReset),
        .endereco(endereco), 
        .posicao_reg(posicao_reg),
        .start(start),
        .display(display),
        .Led(Led),
        .SDA(SDA),
        .SCL(SCL)
    );

    always #10 clock = ~clock;

//---------------- Trecho da memória --------------------------//////
    reg [7:0] memoria [0:15];

    initial begin
        memoria[0] = 8'b01111110;
        memoria[1] = 8'b00110000;
        memoria[2] = 8'b01101101;
        memoria[3] = 8'b01111001;
        memoria[4] = 8'b00110011; 
        memoria[5] = 8'b01011011;
        memoria[6] = 8'b01011111;
        memoria[7] = 8'b01110000;
        memoria[8] = 8'b01111111;
        memoria[9] = 8'b01111011;
    end              

//-------------- Variavéis internas auxiliares-------------//////////
    reg         sda_slave;
    reg         sda_slave_en;
    reg [6:0]   addr_recebido;
    reg [6:0]   indice_recebido;
    reg [7:0]   rTst;
    integer     bit_cnt;
    reg         ack_slave;
    reg         rw;

//------------ Controle de ciclos ------////
    integer     i_addr;
    integer     i_idx;

    assign SDA = sda_slave_en ? sda_slave : 1'bz;

//------------ Controle do sda_slave_en ------------////
always @(*) begin
    case (uut.fsm_inst.current_state)

        uut.fsm_inst.S3, uut.fsm_inst.S5, uut.fsm_inst.S8, uut.fsm_inst.S9: 
            sda_slave_en = 1;
        default: 
            sda_slave_en = 0;
        uut.fsm_inst.S10: begin
            sda_slave_en = 0;
            sda_slave = 0;
        end
    endcase
end

//------------ Escravo LÊ comandos na BORDA DE SUBIDA do SCL ------------////
always @(posedge uut.clk100 ) begin 
    case (uut.fsm_inst.current_state)
        uut.fsm_inst.S2: begin
            if (i_addr == 7) begin
                rw = SDA; 
                ack_slave = (!rw)?0:1;  
                i_addr = 0;
            end 
            else begin
                addr_recebido [6 - i_addr] = SDA;
                i_addr = i_addr + 1;    
            end
        end

        uut.fsm_inst.S4: begin
            if (i_idx == 7) begin
                rw = SDA; 
                i_idx = 0;
            end
            else begin
                indice_recebido[6 - i_idx] = SDA;
                i_idx = i_idx + 1;
            end
        end

        uut.fsm_inst.S7: begin
            if (i_addr == 7) begin
                rw = SDA; 
                ack_slave = (rw)?0:1;  
                i_addr = 0;
            end
            else begin
                addr_recebido [6 - i_addr] = SDA;
                i_addr = i_addr + 1;
            end
        end

        uut.fsm_inst.S9: begin

            sda_slave <= memoria[indice_recebido][bit_cnt-1];

            bit_cnt <= bit_cnt - 1;
        end

    endcase
end

//------------ Escravo ESCREVE dados/ACK na BORDA DE DESCIDA do clock que o SCL segue ------------////
always @(negedge SCL) begin
    case (uut.fsm_inst.current_state)
        uut.fsm_inst.S3, uut.fsm_inst.S5, uut.fsm_inst.S8: begin
            if ((uut.fsm_inst.current_state == uut.fsm_inst.S3 && addr_recebido == addr_slave) ||
                (uut.fsm_inst.current_state == uut.fsm_inst.S5 && indice_recebido < TAMANHO_ENDERECO) ||
                (uut.fsm_inst.current_state == uut.fsm_inst.S8 && addr_recebido == addr_slave && rw == 1))
                sda_slave = 1'b0;  // ACK
            else
                sda_slave = 1'b1;  // NACK
        end
    endcase
end

//------------ Resets------------////
always @(posedge uut.clk100 or negedge nReset) begin
    if (!nReset) begin
        bit_cnt     <= 8;
        sda_slave   <= 0;
        ack_slave    <= 0;
        rw           <= 0;
        addr_recebido   <= 0;
        indice_recebido <= 0;
        i_addr <= 0;
        i_idx <= 0;
        rTst    <=0;
    end
    else begin
        if (uut.fsm_inst.current_state != uut.fsm_inst.S2 && 
            uut.fsm_inst.current_state != uut.fsm_inst.S4 &&
            uut.fsm_inst.current_state != uut.fsm_inst.S7) begin
            i_addr <= 0;
            i_idx <= 0;
        end
        
        if (uut.fsm_inst.current_state != uut.fsm_inst.S9) begin
            bit_cnt <= 8;
        end
    end
end

///----------------------------Estimulos-----------------////
    initial begin
        clock = 0;
        nReset = 0; #20_000
        endereco = 0;
        posicao_reg = 0;
        start = 0;

        #50 nReset = 1;

        // ---------- TESTE OK ----------
        endereco = 7'h10;        // -----------end correto
        posicao_reg = 7'd4;     //------------ posição correta

        #10_000 start = 1;
        #10_000 start = 0;

        #800_000; 

        // ---------- TESTE ERRO ----------
        endereco = 7'h05;       // -----------end incorreto
        posicao_reg = 7'd2;

        #10_000 start = 1;
        #10_000 start = 0;

        #800_000; 
        nReset =0;#10_000;
        nReset =1;
        endereco = 7'h10;
        posicao_reg = 7'd10;     // -----------posição incorreto

        #10_000 start = 1;
        #10_000 start = 0;

        #800_000; 
        $finish;
    end

    initial begin
        $monitor("T=%0t | State=%0d | BitCnt=%0d | SDA=%b | Addr=%h | Idx=%h",
            $time, uut.fsm_inst.current_state, uut.bit_shift_inst.bitCount, 
            SDA, addr_recebido, indice_recebido);
    end

endmodule