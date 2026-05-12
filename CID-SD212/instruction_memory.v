// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Instruction Memory
//////////////////////////////////////////////////////////////////
module instruction_memory (
    input  wire [31:0] addr,      // Endereço de 32 bits  (PC)
    output wire [31:0] inst       // Armazena as instruções de 32 bits 
);

    reg [31:0] mem [0:255];  // Memória de instruções de 32 bits, com 256 posições 

    initial begin    
        $readmemb("instructions.mem", mem); 
    end

    // Acessar a instrução dividindo o endereço por 4, por ser endereçada em 4 bytes (32 bits)
    assign inst = mem[addr >> 2]; 

endmodule