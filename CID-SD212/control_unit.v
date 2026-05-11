// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Control Unit
//////////////////////////////////////////////////////////////////

module control_unit (
    input       [31:0]  inst,              // Instrução de 32 bits
    output reg          branch,              // Sinal de controle para instruções de desvio 
    output reg          mem_read,          // Sinal de controle para leitura de memória 
    output reg          mem_to_reg,        // Sinal de controle para escreve dados no registrador a partir da memória
    output reg  [1:0]   alu_op ,            // Sinal de controle para operação da ALU
    output reg          mem_write,         // Sinal de controle para escrita em memória
    output reg          alu_src,           // Sinal de controle para seleção de fonte do segundo operando da ALU
    output reg          reg_write         // Sinal de controle para escrita em registrador
);
    wire  [6:0] opcode;                  // opcode da instrução
    assign opcode = inst[6:0];          // Bits [6:0] para opcode

    always @(*) begin
        case (opcode)
              7'b0110011: begin  // Operações do tipo R
                reg_write = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b0;
                alu_op = 2'b10;
                branch = 1'b0;
            end
            7'b0010011: begin // Operações do tipo I aritmetica
                reg_write = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b1;
                alu_op = 2'b10; 
                branch = 1'b0;
            end
            7'b0000011: begin // Operações do tipo I 
                reg_write = 1'b1;
                mem_to_reg = 1'b1;
                mem_read = 1'b1;
                mem_write = 1'b0;
                alu_src = 1'b1;
                alu_op = 2'b00;
                branch = 1'b0;
            end
            7'b0100011: begin // Operações do tipo S
                reg_write = 1'b0;
                mem_to_reg = 1'b0; 
                mem_read = 1'b0;
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 2'b00; 
                branch = 1'b0;
            end
            7'b1100011: begin // Operações do tipo B
                reg_write = 1'b0;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b0;
                alu_op = 2'b01; 
                branch = 1'b1; // Ativa o sinal de controle para instruções de desvio
            end
            7'b1101111: begin // Operações do tipo J
                reg_write = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b0;
                alu_op = 2'b00;
                branch = 1'b1; 
            end
            7'b0110111: begin // Operações do tipo U
                reg_write = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b1; // Imediato é a fonte do segundo operando da ALU
                alu_op = 2'b00; 
                branch = 1'b0;
            end
            7'b0010111: begin // Operações do tipo U
                reg_write = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b1; // Imediato é a fonte do segundo operando da ALU
                alu_op = 2'b00; 
                branch = 1'b0;
            end


            default: begin // Default case for unsupported opcodes
                reg_write = 1'b0;
                mem_to_reg = 1'b0; 
                mem_read = 1'b0;
                mem_write = 1'b0;
                alu_src = 1'b0; 
                alu_op = 2'b00; 
                branch = 1'b0;
            end
        endcase
    end
    endmodule