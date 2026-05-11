// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // RISC-V top module
//////////////////////////////////////////////////////////////////

module rv32i_single_cycle_top (
    input  clk,                         // clock ( um ciclo de clock por instrução )
    input  rst                          // reset assíncrono
);

    wire [31:0] pc;                     // valor atual de PC
    wire [31:0] inst;                   // instrução lida da memória
    wire [6:0] opcode;                  // opcode da instrução
    wire [2:0] funct3;                  // funct3 da instrução
    wire [6:0] funct7;                  // funct7 da instrução
    wire [4:0] rd, rs1, rs2;           // campos de registradores da instrução
    wire reg_write;                    // sinal de controle para escrita em registrador
    wire mem_to_reg;                   // sinal de controle para escreve dados no registrador a partir da memória
    wire mem_read;                     // sinal de controle para leitura de memória 
    wire mem_write;                    // sinal de controle para escrita em memória
    wire alu_src;                      // sinal de controle para seleção de fonte do segundo operando da ALU
    wire [1:0] alu_op;                 // sinal de controle para operação da ALU
    wire branch;                       // sinal de controle para instruções de desvio 
    wire [31:0] alu_result, data_w, data_r,add_result, immgen_out, data1_from_reg, data2_from_reg;        
    wire zero_flag;                    // flag que indica se o resultado da ALU é zero
    wire pc_src;                      // resultado do somador para cálculo do próximo PC
    wire data_src;                    // sinal para selecionar entre o resultado da ALU ou os dados da memória

    assign pc_src = (branch && zero_flag) ? add_result : pc + 4; // Seleciona o próximo PC com base no resultado do branch   
    assign data_src = mem_to_reg ? data_r : alu_result; // Seleciona os dados a serem escritos no registrador de destino
    assign data_alu_src = alu_src ? immgen_out : data2_from_reg; // Seleciona entre o segundo operando da ALU ou o valor estendido do imediato

    PC PC1 (
        .clk(clk),
        .rst(rst),
        .next_pc(pc_src), 
        .pc(pc)
    );
    instruction_memory IM (
        .addr(pc),
        .inst(inst)
    );
    control_unit CTR_U (
        .inst(inst),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch)
    );

    decoder DEC (
        .inst(inst),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2)
    );
    
    reg_file RF (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .data_w(data_src), 
        .data1_r(data1_from_reg),
        .data2_r(data2_from_reg)
    );
    alu_control ALU_CTR (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_control(alu_control)
    );
    alu ALU (
        .A(data1_from_reg),
        .B(data_alu_src), 
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero_flag)
    );
    data_memory data_mem (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .addr(alu_result),
        .data_w(data_w),
        .data_r(data_r) 
    );
    imm_gen immgen (
        .inst(inst),
        .imm_out(immgen_out)
    );
endmodule