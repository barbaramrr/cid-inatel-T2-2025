//Modulo criado para transmissao e recepcao do byte bit a bit
module BitShift (
    input systemClk,
    input scl,
    input nReset,
    input [1:0] mode,   //para indicar se está carregando byte, transmitindo bit ou recebendo bit
    input [7:0] txByte,
    input enableSdaDrive,
    input sclLow,
    input sclRise,
    input sclFall,
    output done,     //byte completo
    inout sdaOut,   //modulo sdoio
    input sda_in,  //modulo sdaio. Manda valor para o slave
    output [7:0] rxByte,
    output ack_shift
);

    reg [7:0] regShift;
    reg [2:0] bitCount;
    reg regDone;
    reg sdaReg;
    reg load;
    reg ack;
    reg [3:0] rxBitCount;
    integer k;

    localparam MODE_IDLE = 2'b00;
    localparam MODE_LOAD = 2'b01;
    localparam MODE_TX = 2'b10;
    localparam MODE_RX = 2'b11;

    always @(negedge systemClk or negedge nReset) begin
        if (!nReset) begin
            regShift <= 8'd0;
            bitCount <= 3'd7;
            regDone <= 1'b0;
            sdaReg <= 1'b1;
            load <= 0;
            ack <= 0;
            rxBitCount <= 0;
            k <= 0;
        end else begin
            regDone <= 1'b0;
            case(mode)
                MODE_IDLE: begin
                    bitCount <= 3'd7;
                    rxBitCount <= 0;
                    sdaReg <= 1'b1;
                end

                MODE_TX: begin
                    if (bitCount == 3'd7) begin
                        regShift <= txByte;

                    end
                    
                    if (sclLow) begin
                        load <= 0;
                        sdaReg <= regShift[bitCount];
                    end
                   // if (sclFall) begin
                        if (bitCount == 0) begin
                            bitCount <= 3'd7;
                            regDone <= 1'b1;
                            ack = sda_in;

                        end else
                            bitCount <= bitCount - 1'b1;
    
                    //end

                end             

                MODE_RX: begin                  
                        if (rxBitCount == 7) begin
                            regDone <= 1'b1;
                            rxBitCount <= 0;
                        end else begin
                            rxBitCount <= rxBitCount + 1;
                        end
                end

                default: ;
            endcase
        end
    end

    always @(posedge systemClk ) begin
        regShift[rxBitCount] <= sda_in;
            if ( bitCount == 3'd7) begin
                ack      <= sda_in;
                end
        
    end

    assign ack_shift = ack;
    assign sdaOut = (mode == MODE_TX && enableSdaDrive) ? sdaReg : 1'bz;
    assign rxByte = regShift;
    assign done = regDone;

endmodule