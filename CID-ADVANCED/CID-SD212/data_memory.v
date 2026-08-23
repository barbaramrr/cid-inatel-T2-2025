// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Data Memory
//////////////////////////////////////////////////////////////////

module data_memory (
    input   clk,
    input   mem_write,
    input   mem_read,
    input   [31:0] addr,
    input   [31:0] data_w,
    output  [31:0] data_r
);
    reg [31:0] mem [0:255];


    always @(posedge clk) begin
        if (mem_write)
            mem[addr >> 2] <= data_w;
    end

    assign data_r = (mem_read) ? mem[addr >> 2] : 32'b0;
endmodule