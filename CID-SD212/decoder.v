// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
               // Decoder
//////////////////////////////////////////////////////////////////

module decoder (
    input   [31:0]  inst,             // Instrução de 32 bits
    output  [6:0]   opcode,            // 7 bits de opcode
    output  [2:0]   funct3,             // 3 bits de funct3
    output  [6:0]   funct7,             // 7 bits de funct
    output  [4:0]   rd,                // 5 bits de registrador de destino
    output  [4:0]   rs1,               // 5 bits de registrador fonte 1
    output  [4:0]   rs2               // 5 bits de registrador fonte 2

);
    
    assign opcode = inst[6:0];          // Bits [6:0] para opcode
    assign rd     = inst[11:7];         // Bits [11:7] para rd
    assign funct3 = inst[14:12];        // Bits [14:12] para funct3
    assign rs1    = inst[19:15];        // Bits [19:15] para rs1
    assign rs2    = inst[24:20];        // Bits [24:20] para rs2
    assign funct7 = inst[31:25];        // Bits [31:25] para funct7

endmodule