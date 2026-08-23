`timescale 1ns/1ps

module tb_inv;

reg a;
wire y1;

inv gate_inst1(.b(y1),.a(a));

initial begin
    $monitor (y1);
    a=1'b0;

    #5 a=1'b1;
    #5 a=1'b0;
    #5 a=1'b1;
    #5 a=1'b0;

    $finish;

end
    
endmodule