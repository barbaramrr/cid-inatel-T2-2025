/*Programa: CI Digital/INATEL  - Turma: 2 
Trabalho Orientado I  - MESTRE I2C PARA LEITURA DE MEMÓRIA
Orientador: Felipe Rocha 
Grupo: 4
Integrantes: 
Alessandra C. D.  
Bruno A. C. C.  
Bárbara M. R. R.  
Emmanuel P. T. 
Fábio H. M.  
Gabriel K. A.  
Julia de F. C.  
Lucas L. F.  
Luis H. A. dos S.
Mateus N. G. P.  
Samuel J. R.

Data: Março/2026
*/

module i2c_master_top (
    input           clock, // Clock do sistema
    input           nReset, // Reset ativo em nível baixo
    input           start, // Início da leitura I2C
    input  [6:0]    endereco, // Endereço do dispositivo I2C
    input  [6:0]    posicao_reg, // Endereço da memória interna (EEPROM)
    output  [7:0]   display, // Saída para display de 7 segmentos
    output          Led, // LED de erro
    inout           SDA, // Linha de dados I2C
    output          SCL  // Linha de clock I2C
);

  // SDA CONEXÕES
    wire        sdaDriveFSM;      // SDA controlado pela FSM (START, STOP, NACK)
    wire        sdaOutBitShift;   // SDA controlado pelo BitShift
    wire        sdaMux;
    wire [7:0]  data;


    // SclGen
    wire sclHigh;
    wire sclLow;
    wire sclRise;
    wire sclFall;
    wire nclk100;
    wire senACK;


    // BitShift
    wire [1:0]  shiftMode;
    wire [7:0]  txByte;
    wire [7:0]  rxByte;
    wire        shiftDone;
    wire        ack_shift;
    wire        scl_en;
    wire [3:0]  data_lo = data [3:0];
   

    assign sdaMux = (shiftMode == 2'b01) ? sdaOutBitShift : sdaDriveFSM;  

    // Seleção da origem do SDA
    // Durante transmissão de bits, quem define o valor é o BitShift
    // Nos demais casos (START, STOP, NACK), o valor vem da FSM

    // Instância do gerador de clock I2C
    SclGen scl_gen_inst (
        .systemClk  (clock),
        .clock100   (nclk100),
        .enable     (scl_en),
        .nReset     (nReset),
        .scl        (SCL),
        .sclHigh    (sclHigh),
        .sclLow     (sclLow),
        .sclRise    (sclRise),
        .sclFall    (sclFall)
    );

    // Instância do módulo de envio/recepção de bits
    BitShift bit_shift_inst (
        .systemClk          (clock),
        .scl        (SCL),
        .send       (senACK),
        .nReset     (nReset),
        .mode       (shiftMode),
        .enableSdaDrive (enableSdaDrive),
        .txByte     (txByte),
        .sclLow     (sclLow),
        .sclRise    (sclRise),
        .done       (shiftDone),
        .sclFall    (sclFall),
        .sdaOut     (sdaOutBitShift),
        .ack_shift  (ack_shift),
        .rxByte     (rxByte),
        .sda_in     (SDA)
    );

    // Instância da FSM do mestre I2C
    i2c_fsm_v2 fsm_inst (
        .clock      (clock),
        .send       (senACK),
        .clock100   (nclk100),
        .scl_en     (scl_en),
        .nReset     (nReset),
        .endereco   (endereco),
        .posicao_reg (posicao_reg),
        .start      (start),
        .SCL        (SCL),
        .ack        (ack_shift),
        .sclRise    (sclRise),
        .sclHigh    (sclHigh),
        .sclFall    (sclFall),
        .shiftDone  (shiftDone),
        .rxByte     (rxByte),
        .shiftMode  (shiftMode),
        .txByte     (txByte),
        .sdaDrive   (sdaDriveFSM),
        .enableSdaDrive (enableSdaDrive),
        .data       (data),
        .Led        (Led)
    );

    display7seg dis (
        .data       (data_lo),
        .error      (Led),
        .seg        (display)
    );

    eeprom Mem (
        .clock      (clock),
        .nReset     (nReset),
        .SDA        (SDA),
        .SCL        (SCL)
    );

    assign SDA = enableSdaDrive ? sdaMux : 1'bz;
    

endmodule
