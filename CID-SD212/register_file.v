// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Register File
//////////////////////////////////////////////////////////////////

module reg_file (
    input   clk,                        
    input   rst, 
    input   reg_write,                   // Sinal de controle para escrita em registrador
    input   [4:0] rs1, rs2, rd,         // Registradores fonte e destino 
    input   [31:0] data_w,              // Dados a serem escritos no registrador 
    output  [31:0] data1_r, data2_r     // Dados lidos dos registradores 
);

    reg [31:0] regi [0:31];             //32 registradores de 32 bits

    // Leitura dos registradores 
    assign data1_r = regi[rs1];
    assign data2_r = regi[rs2]; 
    integer i;

    // Escrita no registrador 
    always @(posedge clk or posedge rst) begin
         // Inicializar o registrador x0 em  zero sempre
        regi[0] <= 32'b0;

        if (rst) begin
            // Resetar todos os registradores para zero
  
            for (i = 0; i < 32; i = i + 1) begin
                regi[i] <= 32'b0;
            end
        end else if (reg_write && rd != 0) begin
            regi[rd] <= data_w; 
        end
    end 
endmodule
