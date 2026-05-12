// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // ALU Control
//////////////////////////////////////////////////////////////////
module alu_control (
    input   [1:0]   alu_op,             // Sinal de controle gerado na unidade de controle
    input   [2:0]   funct3,             // 3 bits de funct3
    input   [6:0]   funct7,             // 7 bits de funct7
    output  [3:0]   alu_control        // Sinal de controle para a ALU que define a operação a ser realizada
);
    reg  [3:0] alu_control_reg ;

    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_control_reg = 4'b0010; // lw e sw - usa adicão para calcular o endereço - Tipo I e S
            end

            2'b01: alu_control_reg = 4'b0110; // beq - usa subtração para comparação

            // Decodificação para operações do tipo R 
            2'b10: begin 
                case (funct3)
                    3'b000: alu_control_reg = (funct7 == 7'b0000000) ? 4'b0010 : 4'b0110; // add ou sub
                    3'b111: alu_control_reg = 4'b0000; // and
                    3'b110: alu_control_reg = 4'b0001; // or    
                    3'b100: alu_control_reg = 4'b0011; // xor
                    3'b001: alu_control_reg = 4'b0100; // sll
                    3'b101: alu_control_reg = (funct7 == 7'b0000000) ? 4'b0101 : 4'b0111; // srl ou sra
                    3'b010: alu_control_reg = 4'b1000; // slt
                    3'b011: alu_control_reg = 4'b1001; // sltu
                    default: alu_control_reg = 4'b0; 
                endcase
            end
             2'b11: begin
                case (funct3)
                    3'b000: alu_control_reg = 4'b0010; // addi
                    3'b111: alu_control_reg = 4'b0000; // andi
                    3'b110: alu_control_reg = 4'b0001; // ori
                    3'b100: alu_control_reg = 4'b0011; // xori
                    3'b010: alu_control_reg = 4'b1000; // slti
                    default: alu_control_reg = 4'b0010;
                endcase
            end
            default: alu_control_reg = 4'b0010;
        endcase
    end

    assign alu_control = alu_control_reg;
endmodule 