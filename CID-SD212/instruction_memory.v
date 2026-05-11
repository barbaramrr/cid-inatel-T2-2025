// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Instruction Memory
//////////////////////////////////////////////////////////////////
module instruction_memory (
    input  wire [31:0] addr,      // Endereço de 32 bits (vindo do PC)
    output wire [31:0] inst       // Instrução de 32 bits (vai para o Decoder)
);

    reg [31:0] mem [0:255];  // Memória de instruções com 256 palavras de 32 bits

    initial begin
    //mem[0] = 32'b00000000100100010000000010010011;
    
        $readmemb("instructions.mem", mem); 
    end

    // Acessar a instrução dividindo o endereço por 4 (>> 2)
    assign inst = mem[addr >> 2]; 

endmodule