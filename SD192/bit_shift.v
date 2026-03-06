module BitShift (
    input       systemClk,  
    input       scl,
    input       nReset,
    input [1:0] mode,
    input [7:0] txByte,
    input       enableSdaDrive,
    input       sclLow,
    input       sclRise,
    input       sclFall,
    output      done,
    inout       sdaOut,
    input       sda_in,
    output [7:0]rxByte, 
    output      send,   
    output      ack_shift
);

    reg [7:0] regShiftTX;
    reg [7:0] regShiftRX;

    reg [2:0] bitCountTX;
    reg [2:0] bitCountRX;

    reg [3:0]   rx_cycle;  
    reg         txDone;
    reg         rxDone;
    reg         sdaReg;
    reg         ack;
    reg         sendACK;

    localparam MODE_IDLE   = 2'b00;
    localparam MODE_TX     = 2'b01;
    localparam MODE_RX     = 2'b10;
    localparam MODE_RX_ACK = 2'b11;

    // ----------------------------------------------------
    // TRANSMISSÃO (SDA muda em FALL)
    // ----------------------------------------------------
    always @(negedge systemClk or negedge nReset) begin
        if (!nReset) begin
            bitCountTX <= 3'd7;
            regShiftTX <= 8'd0;
            sdaReg     <= 1'b1;
            txDone     <= 1'b0;

        end else begin

            txDone <= 1'b0; // Zera o done de TX por padrão

            case (mode)

                MODE_IDLE: begin
                    bitCountTX <= 3'd7;
                    sdaReg     <= 1'b1;
                end

                MODE_TX: begin

                    if (sclFall) begin

                        if (bitCountTX == 3'd7) begin
                            regShiftTX <= txByte; 
                            sdaReg     <= txByte[7]; 
                        end

                        if (bitCountTX == 0) begin
                            bitCountTX <= 3'd7;
                            txDone     <= 1'b1;
                        end 
                        else begin
                            bitCountTX <= bitCountTX - 1'b1;                
                        end

                    end

                    if (sclRise) begin
                        sdaReg <= regShiftTX[bitCountTX];
                    end

                end

            endcase
        end
    end


    // ----------------------------------------------------
    // RECEPÇÃO + DONE (amostra em RISE)
    // ----------------------------------------------------
    always @(posedge systemClk or negedge nReset) begin

        if (!nReset) begin

            bitCountRX  <= 3'd7;
            regShiftRX  <= 8'd0;
            rxDone      <= 1'b0;
            ack         <= 1'b0;
            sendACK     <= 1'b0;
            rx_cycle    <= 4'd0;

        end else begin

            rxDone  <= 1'b0;
            sendACK <= 1'b0;

            // ---------------- RECEPÇÃO ----------------
            if (mode == MODE_RX) begin

                if (sclRise) begin
                    regShiftRX[bitCountRX] <= sda_in;

                    if (bitCountRX == 0) begin
                        bitCountRX <= 3'd7;
                        rxDone     <= 1'b1;
                    end 
                    else begin
                        bitCountRX <= bitCountRX - 1'b1;
                    end

                end

            end

            // ---------------- RECEBE ACK ----------------
            if (mode == MODE_RX_ACK) begin   

                if (sclRise)
                    rx_cycle <= rx_cycle + 1'b1;

                ack <= sda_in;

                if (rx_cycle == 1) begin
                    sendACK  <= 1'b1; 
                    rx_cycle <= 4'd0;
                end    

            end 
            else begin
                rx_cycle <= 4'd0;
            end

        end
    end


    // ----------------------------------------------------
    // SAÍDAS
    // ----------------------------------------------------

    // Como tem um done para enviar e um para receber dados.
    // É preciso fazer um OU entre eles.
    // Assim manda um sempre que termina o envio OU a recepção.

    assign done      = txDone | rxDone;  
    assign ack_shift = ack;
    assign send      = sendACK;

    assign sdaOut = (mode == MODE_TX && enableSdaDrive) ? sdaReg : 1'bz;

    assign rxByte = regShiftRX;

endmodule
