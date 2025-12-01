`timescale 1ns / 100ps

module testbench_debounce;

    // Entradas
    reg button;
    reg clk;
    reg reset;

    // Saída
    wire result;

    // Instancia o módulo sob teste (UUT)
    debounce uut (
        .clk(clk),
        .rst(reset),
        .noisy_in(button),
        .clean_out(result)
    );

    // Geração do sinal de clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Período do clock T = 20 ns
    end

    // Geração do estímulo (simulação do botão com "bounces")
    initial begin
        button = 0;
        reset = 1;
        #50 reset = 0;

        #6000 button = 0;
        #50  button = 1;  // Glitch / bounce
        #200 button = 0;
        #50  button = 1;  // Glitch / bounce
        #150 button = 0;
        #100 button = 1;  // Botão pressionado (estável)
        #8000 button = 0;
        #50  button = 1;  // Glitch / bounce
        #200 button = 0;
        #50  button = 1;  // Glitch / bounce
        #200 button = 0;  // Botão solto (estável)

        $finish; 
    end

endmodule