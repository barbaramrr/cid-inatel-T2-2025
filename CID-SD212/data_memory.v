// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Data Memory
//////////////////////////////////////////////////////////////////

module data_memory (
    input   clk,                         // clock ( um ciclo de clock por instrução )
    input   mem_write,                   // Sinal de controle para escrita em memória
    input   mem_read,                    // Sinal de controle para leitura de memória 
    input   [31:0] addr,                // Endereço de 32 bits
    input   [31:0] data_w,          // Dados a serem escritos na memória
    output  [31:0] data_r         // Dados lidos da memória
);

    reg [31:0] data_rr; // registrador para ser usado no always
    reg [31:0] mem [0:255];  32 bits

    always @(posedge clk) begin
        if (mem_write) begin
            mem[addr>>2] <= data_w; // Escrever dados na memória usando endereçamento por byte por isso é preciso dividir por 4
        end
        if (mem_read) begin
            data_rr <= mem[addr>>2]; // Ler dados da memória usando endereçamento por byte por isso é preciso dividir por 4
        end
    end

    assign data_r = data_rr;
    
    endmodule