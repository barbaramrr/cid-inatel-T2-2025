module PC_Adders (
    input   [31:0]  pc,                 // valor atual de PC
    input   [31:0]  immgen_out,         // valor estendido do imediato usado em caso de desvio
    output  [31:0]  adder_out           // resultado da soma de PC e imediato

);  

    assign adder_out = pc + immgen_out; // Calcula o próximo valor de PC para instruções de desvio

endmodule