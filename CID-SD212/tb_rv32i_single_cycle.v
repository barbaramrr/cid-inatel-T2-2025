// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Testbench RISC-V top
//////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module tb_rv32i_single_cycle;

    reg clk;
    reg rst;

  
    rv32i_single_cycle_top top (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1'b1; 
        #20;     
        rst = 0; 
        #200;    
        $finish; 
    end
endmodule
