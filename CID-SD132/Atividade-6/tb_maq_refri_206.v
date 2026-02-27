module tb_maq_refri_206;

	localparam DELAY = 10; 
    reg 		clk, rst;
    reg  [1:0]	coin;
    wire 		D;
    wire [1:0]	T;

    reg [6:0]	total;
    reg 		flag; // ??? 

    maq_refri_206 DUT (
		.clk(clk), .rst(rst), .moeda(coin), 
		.D(D), .T(T)
	);

	initial begin
	
		// Adicionar o dump 
		
		$display ("|Current	|Next	|Coin	|Total	|D	|T	|");
        $monitor("|%03b		|%03b	|%02b	|%2d	|%1b	|%02b	|", 
        		DUT.current_state, DUT.next_state, coin, total, D, T
        );
	end
	
	// Remover as depedências do clock
	
    always #(DELAY/2) clk = ~clk;

    always @(posedge clk or posedge D) begin // zerar total... flag <- new coin;
        if (D || rst) // Síncrono
            total <= 7'd0;
        else begin
            case (coin)
                2'b01	: total <= total + 7'd5;
                2'b10	: total <= total + 7'd10;
                2'b11	: total <= total + 7'd25;
                default	: total <= total;
            endcase 
        // 	if (D) total <= 7'd0; // Assincrono ??? 
        end
    end
	
	// TODO: Analisar entradas e saídas; 
	initial begin         

		{rst, clk} = 2'b11; 
		coin = 2'b00; 
		flag = 0;
		#DELAY;
		
		// Definir sequências de análise
		rst = 0;  // ! 
		#DELAY;
		
		// 5 + 5 + 5
		coin = 2'b01; 
		flag = 0; 
		#(DELAY*3);

		// 5 + 5 + 10
		coin = 2'b00;
		flag = 0;
		#DELAY;

		// 5 + 10 + 5
		coin = 2'b10;
		flag = 0; 
		#DELAY;

		// 10 + 5 + 5
		coin = 2'b00;
		flag = 0;
		#DELAY;

		// 5 + 10 + 10
		coin = 2'b10;
		flag = 1; 
		#DELAY;

		// 10 + 5 + 10
		coin = 2'b00;
		flag = 0;
		#DELAY;

		// 10 + 10 + 5 
		rst = 1; // !
		#DELAY;
		
		// 10 + 10 + 10
		
		rst = 0;
		#DELAY;

		coin = 2'b11;
		flag = 1;
		#DELAY;
		
		// 25
				
		coin = 2'b00;
		flag = 0;
		#DELAY;

		rst = 1;
		#DELAY;

		rst = 0;
		#DELAY;

		coin = 2'b10;
		flag = 0;
		#DELAY;
		
		coin = 2'b00;
		flag = 0;
		#DELAY;

		coin = 2'b10;
		flag = 0;
		#DELAY;
		
		coin = 2'b00;
		flag = 0;
		#DELAY;

		coin = 2'b10;
		flag = 0;
		#DELAY;
		
		coin = 2'b00;
		flag = 0;
		#DELAY;

		#(DELAY*2) 
		$finish;
    end

endmodule
