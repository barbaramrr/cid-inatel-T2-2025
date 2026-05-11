// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Instruction Memory
//////////////////////////////////////////////////////////////////

module instruction_memory (
    input   [31:0] addr,      // Endereço de 32 bits
    output  [31:0] inst   // Instrução de 32 bits
);

    reg [31:0] mem [0:255];  // Memória de instruções com 256 palavras de 32 bits

    initial begin
     $readmemh("instructions.mem", mem); // Carregar as instruções a partir de um arquivo .mem
    end

    assign inst = mem[addr>>2]; // Acessar a instrução usando endereçamento por byte por isso é preciso dividir por 4

endmodule