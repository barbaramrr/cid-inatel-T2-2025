module paridade #(
    parameter WIDTH = 4)
(
    input   [WIDTH-1:0] in,
    output             out
);

    function reg calcula_paridade (
    	input [WIDTH-1:0] dado);
        reg [WIDTH-1:0] result;
        
        begin
                        
            calcula_paridade = ^dado;
        end
    
    endfunction

    assign out = calcula_paridade(in);

endmodule
