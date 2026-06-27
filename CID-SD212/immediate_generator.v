// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // Immediate Generator
//////////////////////////////////////////////////////////////////

module immgen (
    input   [31:0]  inst,                 // Instrução de 32 bits
    output  [31:0]  imm_out              // Imediato estendido para 32 bits
);

    reg [31:0] imm_out_reg; // registrador para ser usado no always

    always @(*) begin
        case (inst[6:0]) 
            7'b0010011: imm_out_reg = {{20{inst[31]}}, inst[31:20]}; // Imediato para instruções do tipo I aritméticos [Imm 11:0] + extensão de sinal  
            7'b0000011: imm_out_reg = {{20{inst[31]}}, inst[31:20]}; // Imediato para instruções do tipo I de load [Imm 11:0] + extensão de sinal
            7'b0100011: imm_out_reg = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // Imediato para instruções do tipo S
            7'b1100011: imm_out_reg = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // Imediato para instruções do tipo B
            7'b1101111: imm_out_reg  = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // Imediato para instruções do tipo J
            7'b0110111: imm_out_reg = {inst[31:12], 12'b0}; // Imediato para instruções do tipo U - unsigned sinal é zero
            default: imm_out_reg = 32'b0; 
        endcase
    end

    assign imm_out = imm_out_reg;
    
    
endmodule