
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

    reg [7:0] regShift;
    reg [2:0] bitCount;
    reg [2:0] rxBitCount;

    
    
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
            bitCount <= 3'd7;
            regShift <= 8'd0;
            sdaReg   <= 1'b1;
            txDone   <= 1'b0;
           
        end else begin
            txDone <= 1'b0; // Zera o done de TX por padrão

            case (mode)
                MODE_IDLE: begin
                    bitCount <= 3'd7;
                    sdaReg   <= 1'b1;
                end

                 MODE_TX: begin
                    if (sclFall) begin
                         if (bitCount == 3'd7) begin
                            regShift <= txByte; 
                            sdaReg   <= txByte[7]; 
                            
                        end                    
                        if (bitCount == 0) begin
                            bitCount <= 3'd7;
                            //sdaReg   <= 0;   
                            txDone   <= 1'b1; 
                        end else begin
                            bitCount <= bitCount - 1'b1;                
                        end
                        
                    end

                    if (sclRise) begin
                        sdaReg <= regShift[bitCount];
                    end
                end
                
            endcase
        end
    end


    // RECEPÇÃO + DONE (amostra em RISE)
    // ---------------------------------------------------------
   always @(posedge systemClk or negedge nReset) begin
    if (!nReset) begin
        bitCount    <= 3'd7;   // contador principal
        rxBitCount  <= 3'd7;   // índice de escrita
        rxDone      <= 1'b0;
        ack         <= 1'b0;
        sendACK     <= 1'b0;
        rx_cycle    <= 4'd0;
      
    end else begin

            rxDone  <= 1'b0;
            sendACK <= 1'b0;

            if (mode == MODE_RX) begin
                if (sclFall) begin
                    rxBitCount <= bitCount; // Usado para sincronizar novamente com a EEPROM. 
                    if (bitCount == 0) begin
                        bitCount <= 3'd7;
                        rxDone   <= 1'b1;
                    end else begin
                        bitCount <= bitCount - 1'b1;
                    end
                end

                if (sclRise) begin
                    regShift[rxBitCount] <= sda_in;
                end

            end      
            
            if (mode == MODE_RX_ACK) begin   
                if (sclRise) begin
                    rx_cycle <= rx_cycle + 1'b1;
                end
                
                ack <= sda_in;
                
                if (rx_cycle == 1) begin
                    sendACK  <= 1'b1; 
                    rx_cycle <= 4'd0;
                end    
                end else begin
                rx_cycle <= 4'd0;
            end
        end
    end

    // Como tem um done para enviar e um para receber dados. É preciso fazer um OU entre eles. 
    // Assim manda um sempre que termina o envio OU a recepção.

    assign done         = txDone | rxDone;  
    assign ack_shift    = ack;
    assign send         = sendACK;
    assign sdaOut       = (mode == MODE_TX && enableSdaDrive) ? sdaReg : 1'bz;
    assign rxByte       = regShift;

endmodule
