// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // PC (Program Counter)
//////////////////////////////////////////////////////////////////

module PC (
    input  clk,                         // clock ( um ciclo de clock por instrução )
    input  rst,                       // sinal de controle para indicar se é um branch        
    input   [31:0]  next_pc,            // próximo valor de PC
    output  [31:0] pc                   // valor atual de PC
);

    reg [31:0] pc_reg; // registrador para ser usado no always
    assign pc = pc_reg; // atribuição do valor do registrador para a saída

    
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'b0; 
        end else 
            pc_reg <= next_pc; // Atualiza o valor de PC para o próximo valor calculado
    end
            

endmodule