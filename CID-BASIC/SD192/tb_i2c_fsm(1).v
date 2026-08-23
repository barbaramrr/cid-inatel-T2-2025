    `timescale 1ns/1ps

    module tb_i2c; 
        reg clock;
        reg nReset;
        reg [6:0] endereco;
        reg [6:0] posicao_reg;
        reg start;

        wire [7:0] display;   
        wire Led;
        wire SCL;
        wire SDA;


        i2c_master_top uut (
            .clock(clock),
            .nReset(nReset),
            .endereco(endereco), 
            .posicao_reg(posicao_reg),
            .start(start),
            .display(display),
            .Led(Led),
            .SDA(SDA),
            .SCL(SCL)
        );

        eeprom uut2 (
        .clock      (clock),
        .nReset     (nReset),
        .SDA        (SDA),
        .SCL        (SCL)
    );




    always #10 clock = ~clock;
    ///----------------------------Estimulos-----------------////
        integer file_in;
        integer file_out;

        initial begin
            file_in  = $fopen("addr_idxMem.txt", "r");
            file_out = $fopen("Saida.txt", "w");

            clock = 0;
            nReset = 0; 
            #20_000
            endereco = 0;
            posicao_reg = 0;
            start = 0;

            #50 nReset = 1;

            while (!$feof(file_in)) begin
                $fscanf(file_in, "%h %d\n", endereco, posicao_reg);

                #10_000 start = 1;
                #10_000 start = 0;

                #800_000;   

                $fwrite(file_out, "%8b\n", display);
            end

            $fclose(file_in);
            $fclose(file_out);
            $finish;
        end

        initial begin
            $monitor("T=%0t | FSMState=%0d |  EEPROM state=%0d | SDA=%b | SCL = %b | Addr=%7b | Idx=%7b  | Led =%b | Dado = %8b",
                $time, uut.fsm_inst.current_state, uut2.state, SDA, SCL, uut2.addr_ptr, uut2.index,uut.fsm_inst.Led, uut.dis.seg );

        end


    endmodule
