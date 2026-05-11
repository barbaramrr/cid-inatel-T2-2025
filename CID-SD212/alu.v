// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // ALU
//////////////////////////////////////////////////////////////////
module alu (
    input   [31:0]  A, B,                   // Entradas dos operandos
    input   [3:0]   alu_control,          // Sinal de controle para selecionar a operação
    output  [31:0]  result,             // Resultado da operação da ALU
    output          zero                // Flag que indica se o resultado é zero
);
    reg [31:0] result_reg;

    always @(*) begin
        case (alu_control)
            4'b0000: result_reg = A & B;                // and
            4'b0001: result_reg = A | B;                // or
            4'b0010: result_reg = A + B;                // add
            4'b0110: result_reg = A - B;                // sub
            4'b0011: result_reg = A ^ B;                // xor
            4'b0100: result_reg = A << B[4:0];       // sll
            4'b0101: result_reg = A >> B[4:0];       // srl
            4'b0111: result_reg = $signed(A) >>> B[4:0]; // sra
            4'b1000: result_reg = ($signed(A) < $signed(B)) ? 1 : 0; // slt
            4'b1001: result_reg = (A < B) ? 1 : 0; // sltu
            default: result_reg = 0;                    
        endcase
    end
    
       assign  zero = (result_reg == 0) ? 1 : 0;
       assign  result = result_reg;
endmodule