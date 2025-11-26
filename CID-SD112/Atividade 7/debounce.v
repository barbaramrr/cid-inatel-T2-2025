module debounce 
#(
    parameter COUNTER_MAX = 64
)
(
    input clk,
    input rst,
    input noisy_in,   
    output clean_out  
);

    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX);

    reg iDFF1, iDFF2, oDFF3;
    reg [COUNTER_WIDTH-1:0] counter;
    wire s_clear;

    
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            iDFF1 <= 1'b0;
            iDFF2 <= 1'b0;
        end else begin
            iDFF1 <= noisy_in;
            iDFF2 <= iDFF1;
        end
    end

    
    assign s_clear = iDFF1 ^ iDFF2;

    
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            counter <= {COUNTER_WIDTH{1'b0}};
        end else begin
            if (s_clear == 1'b1)
                counter <= {COUNTER_WIDTH{1'b0}};
            else if (counter[COUNTER_WIDTH-1] == 1'b0)
                counter <= counter + 1;
        end
    end

    
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            oDFF3 <= 1'b0;
        end else begin
            if (counter[COUNTER_WIDTH-1] == 1'b1)
                oDFF3 <= iDFF2;
        end
    end

    assign clean_out = oDFF3;

endmodule
