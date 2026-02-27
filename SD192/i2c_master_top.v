module i2c_master_top (
    input  clock, // Clock do sistema
    input  nReset, // Reset ativo em nível baixo
    input  start, // Início da leitura I2C
    input  [6:0] endereco, // Endereço do dispositivo I2C
    input  [6:0] posicao_reg, // Endereço da memória interna (EEPROM)

    output  [7:0] display, // Saída para display de 7 segmentos
    output  Led, // LED de erro
    output   clk100,

    inout  SDA, // Linha de dados I2C
    output  SCL  // Linha de clock I2C
);

  // SDA CONEXÕES
    wire sdaDriveFSM;      // SDA controlado pela FSM (START, STOP, NACK)
    wire sdaOutBitShift;   // SDA controlado pelo BitShift
    wire sdaMux;

    assign sda_sample = SDA;

    // SclGen
    wire sclHigh;
    wire sclLow;
    wire sclRise;
    wire sclFall;
    wire nclk100;


    // BitShift
    wire [1:0] shiftMode;
    wire [7:0] txByte;
    wire [7:0] rxByte;
    wire shiftDone;
    wire ack_shift;
    wire scl_en;
    
     assign clk100 = nclk100;

    assign sdaMux = (shiftMode == 2'b10) ? sdaOutBitShift : sdaDriveFSM;  


    // Seleção da origem do SDA
    // Durante transmissão de bits, quem define o valor é o BitShift
    // Nos demais casos (START, STOP, NACK), o valor vem da FSM

    // Instância do gerador de clock I2C
    SclGen scl_gen_inst (
        .systemClk (clock),
        .enable (scl_en),
        .nReset (nReset),
        .scl (SCL),
        .sclHigh (sclHigh),
        .sclLow (sclLow),
        .sclRise (sclRise),
        .clk100 (nclk100),
        .sclFall (sclFall)
    );

    // Instância do módulo de envio/recepção de bits
    BitShift bit_shift_inst (
        .systemClk (nclk100),
        .scl(scl),
        .nReset (nReset),
        .mode (shiftMode),
        .enableSdaDrive (enableSdaDrive),
        .txByte (txByte),
        .sclLow(sclLow),
        .sclRise(sclRise),
        .done (shiftDone),
        .sclFall(sclFall),
        .sdaOut (sdaOutBitShift),
        .ack_shift (ack_shift),
        .rxByte (rxByte),
        .sda_in (sda_sample)
    );

    // Instância da FSM do mestre I2C
    i2c_fsm_v2 fsm_inst (
        .clock (nclk100),
        .scl_en (scl_en),
        .nReset (nReset),
        .endereco (endereco),
        .posicao_reg (posicao_reg),
        .start (start),
        .SCL (SCL),
        .ack (ack_shift),
        .sclRise (sclRise),
        .sclHigh (sclHigh),
        .shiftDone (shiftDone),
        .rxByte (rxByte),

        .shiftMode (shiftMode),
        .txByte (txByte),
        .sdaDrive (sdaDriveFSM),
        .enableSdaDrive (enableSdaDrive),

        .display (display),
        .Led (Led)
    );

    assign SDA = enableSdaDrive ? sdaMux : 1'bz;
    
   // assign sda_sample = (!enableSdaDrive)? SDA:1'bz;

endmodule