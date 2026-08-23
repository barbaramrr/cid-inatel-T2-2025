module Complex_CDC(
    // Source domain
    input           src_clk,
    input           src_arstn,
    input  [3:0]    src_data,
    input           src_valid,      // indica dado válido

    // Destination domain
    input           dest_clk,
    input           dest_arstn,

    output reg [3:0] dest_data
);

    // lógica do source domain  

    reg [3:0] ff_src;               

    reg handshake_src;              // sinaliza que o dado foi capturado e está aguardando ACK
    reg handshake_dest;             

    // Sincronização do ACK no domínio de origem
    reg src_sync1, src_sync2, src_sync3;

    // Sincronização do REQUEST no domínio de destino
    reg dest_sync1, dest_sync2, dest_sync3;

    // Indica que o handshake ainda está em andamento
    wire busy_src;

    assign busy_src = handshake_src | src_sync3;

    // Sincronização 

    always @(posedge src_clk or negedge src_arstn) begin
        if (!src_arstn) begin
            src_sync1 <= 1'b0;
            src_sync2 <= 1'b0;
            src_sync3 <= 1'b0;
        end
        else begin
            src_sync1 <= handshake_dest;
            src_sync2 <= src_sync1;
            src_sync3 <= src_sync2;
        end
    end


    always @(posedge src_clk or negedge src_arstn) begin
        if (!src_arstn) begin
            ff_src        <= 4'b0000;
            handshake_src <= 1'b0;
        end
        else begin

            // Inicia uma nova transferência
            if (src_valid && !busy_src) begin
                ff_src        <= src_data;
                handshake_src <= 1'b1;
            end

            if (src_sync3)
                handshake_src <= 1'b0;
        end
    end

    // lógica do destination domain

    always @(posedge dest_clk or negedge dest_arstn) begin
        if (!dest_arstn) begin
            dest_sync1 <= 1'b0;
            dest_sync2 <= 1'b0;
            dest_sync3 <= 1'b0;
        end
        else begin
            dest_sync1 <= handshake_src;
            dest_sync2 <= dest_sync1;
            dest_sync3 <= dest_sync2;
        end
    end


    wire en_dest;

    assign en_dest = dest_sync2 & ~dest_sync3;

    

    always @(posedge dest_clk or negedge dest_arstn) begin
        if (!dest_arstn) begin
            dest_data      <= 4'b0000;
            handshake_dest <= 1'b0;
        end
        else begin

            // Novo dado chegou
            if (en_dest) begin
                dest_data      <= ff_src;
                handshake_dest <= 1'b1;
            end

        
            if (!dest_sync2)
                handshake_dest <= 1'b0;
        end
    end

endmodule