`timescale 1ns/1ps

module tb_and;

reg A,B;
wire F;

and_gate a_inst1(.b(B),.a(A),.y(F));

initial begin
    $monitor (F);
        A=1'b0; B=1'b0;
    #5  A=1'b0; B=1'b1;
    #5  A=1'b1; B=1'b0;
    #5  A=1'b1; B=1'b1; 
    #5 

    $finish;

end
    
endmodule