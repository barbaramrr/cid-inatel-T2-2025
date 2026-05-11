// CID-SD212 -  Arquitetura de sistemas digitais
// Aluno: Bárbara Rocha
// Professor: Elivander, Felipe e Leticia
//Projeto - RISC-V Single Cycle
//Data: 07/05/2026
///////////////////////////////////////////////////////////////////
                // RISC-V top module
//////////////////////////////////////////////////////////////////

module rv32i_single_cycle_top (
    input  clk,
    input  rst
);


    wire [31:0] pc;
    wire [31:0] inst;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  rd, rs1, rs2;
    
    wire reg_write, mem_to_reg, mem_read, mem_write, alu_src, branch, jump;
    wire [1:0]  alu_op;
    wire [3:0]  alu_control; 
    
    wire [31:0] alu_result, data_r, add_result, immgen_out, data1_from_reg, data2_from_reg;
    wire [31:0] next_pc;    
    wire [31:0] data_src;   
    wire [31:0] data_alu_src; 
    
    wire zero_flag;

    assign next_pc = (jump ||(branch && zero_flag ))? add_result : (pc + 4);

    PC PC1 (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .nextPc(next_pc)
    );

    instruction_memory IM (
        .addr(pc),
        .inst(inst)
    );

    PC_Adders AddPC (
        .pc(pc),
        .immgen_out(immgen_out),
        .adder_out(add_result)
    );

    control_unit CTR_U (
        .inst(inst),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump)
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
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );


    assign data_alu_src = alu_src ? immgen_out : data2_from_reg;

    alu ALU_unit (
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
        .data_w(data2_from_reg),
        .data_r(data_r) 
    );

    
    assign data_src =  jump ? (pc + 4) : (mem_to_reg ? data_r : alu_result);

    immgen IMM (
        .inst(inst),
        .imm_out(immgen_out)
    );

endmodule