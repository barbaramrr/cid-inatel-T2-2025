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
    input  rst, 
    input   [31:0]  nextPc,             // proximo valor de PC calculado
    output  [31:0] pc                   // valor atual de PC
);

    reg [31:0] pc_reg; // registrador para ser usado no always
    assign pc = pc_reg; 

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'b0; 
        end else begin
            pc_reg <= nextPc; 
        end
    end

endmodule