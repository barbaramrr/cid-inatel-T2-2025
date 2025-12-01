module demux_3x8 (
    input  [2:0] in,
    output reg [7:0] out
 );

    task demux(
        input  [2:0] in_data,
        output [7:0] out_data
     );
        begin
            out_data = 8'b0;         
            out_data[in_data] = 1'b1; 
        end
    endtask

    always @(*) begin
        demux(in, out);
    end

endmodule
