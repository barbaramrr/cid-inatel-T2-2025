module tb_maq_refri_206;

    reg clk, rst;
    reg [1:0] moeda;
    wire D1;
    wire [1:0] T;

    reg [6:0] total;
    reg flag;

    maq_refri_206 DUT (.clk(clk), .rst(rst), .moeda(moeda), .D1(D1), .T(T));

    always #5 clk = ~clk;

    always @(moeda) begin
        if (rst)
            total <= 0;
        else begin
            case (moeda)
                2'b01: total <= total + 5;
                2'b10: total <= total + 10;
                2'b11: total <= total + 25;
                default: total <= total;
            endcase

            if (D1)
                total <= 0;
        end
    end

    initial begin
          $display ("------------------------------------------------------------------");
        $monitor("Estado Atual: %3b | Prox Estado: %3b | moeda=%2b | total=%2d | D1=%1b | T=%2b",
                 DUT.current_state, DUT.next_state, moeda, total, D1, T);
        $display ("------------------------------------------------------------------");
        clk = 0; moeda = 2'b00; flag = 0;

        rst = 1; #10;
        rst = 0; #10;

        moeda = 2'b01;  #5;
        moeda = 2'b00; #5;

        moeda = 2'b10; #5;
        moeda = 2'b00; #5;

        moeda = 2'b10; #5;
        moeda = 2'b00; #5;

        rst = 1; #10; rst = 0; #10;

        moeda = 2'b11; #5;
        moeda = 2'b00; #5;

        rst = 1; #10; rst = 0; #10;

        moeda = 2'b10; #5;
        moeda = 2'b00; #5;

        moeda = 2'b10; #5;
        moeda = 2'b00; #5;

        moeda = 2'b10; #5;
        moeda = 2'b00; #5;

        #20 $stop;
    end

 

endmodule
