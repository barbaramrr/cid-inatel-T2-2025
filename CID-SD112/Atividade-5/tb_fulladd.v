`timescale 1ns/1ps

module tb_fulladd;
reg a,b,cin;
wire sum,carry_out;

fulladd U1(.a(a),.b(b),.cin(cin),.sum(sum),.carry_out(carry_out));

initial begin
    $monitor (sum,carry_out);

        a = 0; b = 0; cin = 0; #5;
        a = 0; b = 0; cin = 1; #5;
        a = 0; b = 1; cin = 0; #5;
        a = 0; b = 1; cin = 1; #5;
        a = 1; b = 0; cin = 0; #5;
        a = 1; b = 0; cin = 1; #5;
        a = 1; b = 1; cin = 0; #5;
        a = 1; b = 1; cin = 1; #5;
        

    $finish;

end
endmodule
