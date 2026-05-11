// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Register File
//////////////////////////////////////////////////////////////////

module reg_file (
    input   clk,                         // clock ( um ciclo de clock por instrução )
    input   rst, 
    input   reg_write,                   // Sinal de controle para escrita em registrador
    input   [4:0] rs1, rs2, rd,         // Registradores fonte e destino 
    input   [31:0] data_w,              // Dados a serem escritos no registrador 
    output  [31:0] data1_r, data2_r     // Dados lidos dos registradores 
);

    reg [31:0] registers [0:31]; // Array de 32 registradores de 32 bits

    // Leitura dos registradores fonte
    assign data1_r = registers[rs1];
    assign data2_r = registers[rs2];

    // Escrita no registrador de destino
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Resetar todos os registradores para zero
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (reg_write && rd != 0) begin
            registers[rd] <= data_w; // Escrever dados no registrador de destino
        end
    end 
endmodule
