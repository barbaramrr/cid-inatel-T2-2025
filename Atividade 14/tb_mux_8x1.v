`timescale 1ns / 1ps

module tb_mux_8x1;

    reg  [7:0] in; 
    reg  [2:0] sel;  
    wire       out;

    mux_8x1 U1 (
        .in(in),
        .sel(sel),
        .out(out)
    );

    task mux;
        integer i;
        
     begin

        for (i = 0; i < 8; i = i + 1) begin
            in  = 8'b00000000;  
            in[i] = 1'b1;        
            sel = i;             
            #10;  
            
        end

 
     end

    endtask


   	initial begin

        sel = 3'b0;
        in = 8'b0;
        #5;

        mux;

        #10;
       $finish; 
    end

endmodule
