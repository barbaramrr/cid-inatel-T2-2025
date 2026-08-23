`include "top.v"

`timescale 1 ns / 1 ps

module CDC_module_packet_loss_tb;

    // Sinais de interface
    reg clk_src;
    reg clk_dest;
    reg rst_n;
    wire [3:0] data_out;

    // Instanciação do circuito sob teste (DUT)
    top dut (
        .clk_dest(clk_dest),
        .clk_src(clk_src),
        .rst_n(rst_n),
        .data_out(data_out)
    );

    // CONFIGURAÇÃO DOS CLOCKS (Cenário de Perda de Amostras)
    // clk_src muito rápido (Período = 10ns -> 100MHz)  
	always #5 clk_src = ~clk_src;

    // clk_dest muito lento (Período = 35ns -> ~28.5MHz)
    	always #17.5 clk_dest = ~clk_dest;

	initial begin
		$dumpfile("dump_fail.vcd");
		$dumpvars(0, CDC_module_packet_loss_tb);
	end
	
    // GERAÇÃO DE ESTÍMULOS
    initial begin
    
        $display("[TB] Iniciando simulacao de CDC_module com perda de pacotes (Verilog)...");
        
        clk_src = 1'b0;
        clk_dest = 1'b0;
        rst_n = 1'b0;
        #40;
        
        rst_n = 1'b1;
        $display("[TB] Reset liberado. Monitorando fluxo de dados...");

        // Simula por tempo suficiente para observar múltiplos ciclos do contador
        #600;

        $display("[TB] Simulacao finalizada.");
        $finish;
    end

    // LÓGICA DE MONITORAMENTO E DETECÇÃO DE PERDA (Scoreboard Estático)
    // Em Verilog 2001, usamos vetores fixos para registrar os estados (0 a 15)
    reg gerado_na_origem [0:15];
    reg [3:0] last_sync_out;
    
    integer total_gerado = 0;
    integer total_capturado = 0;
    integer total_perdido = 0;
    integer i;

    // Inicialização do array de monitoramento
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            gerado_na_origem[i] = 1'b0;
        end
    end

    // Captura o momento exato em que a origem gera um novo dado
    always @(posedge clk_src) begin
        if (rst_n) begin
            // Se o estado atual do contador ainda não foi marcado neste ciclo
            if (gerado_na_origem[dut.COUNTER_SYNC_module.count] == 1'b0) begin
                gerado_na_origem[dut.COUNTER_SYNC_module.count] = 1'b1;
                total_gerado = total_gerado + 1;
            end
        end
    end

    // Captura quando o destino consegue registrar o dado sincronizado
    always @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            last_sync_out <= 4'b0;
        end else begin
            last_sync_out <= dut.CDC_module.sync_out;
            
            // Detecta uma transição válida no registrador sincronizado final
            if (dut.CDC_module.sync_out != last_sync_out) begin
                $display("[CAPTURA] Destino amostrou o valor: %d no tempo %0t", dut.CDC_module.sync_out, $time);
                total_capturado = total_capturado + 1;
                
                // Limpa a marcação, pois o dado foi consumido pelo destino
                gerado_na_origem[dut.CDC_module.sync_out] = 1'b0;
            end
        end
    end

    // Varredura a cada ciclo de overflow do contador para computar perdas reais
    always @(posedge clk_src) begin
        if (rst_n && (dut.COUNTER_SYNC_module.count == 4'b1111)) begin
            #1; // Pequeno delay necessário para estabilização das amostras no TB
            
            // Varre o vetor: o que sobrou marcado como 1'b1 nunca foi lido pelo destino
            for (i = 0; i < 16; i = i + 1) begin
                if (gerado_na_origem[i] == 1'b1) begin
                    $display("[AVISO - PERDA] Valor %d gerado na origem NUNCA foi visto pelo destino.", i);
                    total_perdido = total_perdido + 1;
                    gerado_na_origem[i] = 1'b0; // Reseta para a próxima rodada
                end
            end
        end
    end

endmodule
