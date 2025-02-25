module uart_rx (
    input wire clk,
    input wire rx,
    input wire rx_en,
    input wire clr_ready,
    output reg [7:0] data_out = 8'b0,
    output reg data_ready = 0
);

parameter START = 2'b00;
parameter DATA  = 2'b01;
parameter STOP  = 2'b10;

reg [1:0] state = START;
reg [3:0] sample_count = 0;
reg [2:0] bit_index = 0;
reg [7:0] shift_reg = 0;

always @(posedge clk) begin
    if (clr_ready)
        data_ready <= 0;

    if (rx_en) begin
        case (state)
            START: begin
                if (!rx) begin
                    sample_count <= 0;
                    state <= DATA;
                    bit_index <= 0;
                    shift_reg <= 0;
                end
            end
            DATA: begin
                sample_count <= sample_count + 1;
                if (sample_count == 8) begin
                    shift_reg[bit_index] <= rx;
                    bit_index <= bit_index + 1;
                end
                if (bit_index == 8 && sample_count == 15)
                    state <= STOP;
            end
            STOP: begin
                if (sample_count == 15) begin
                    data_out <= shift_reg;
                    data_ready <= 1;
                    state <= START;
                end
            end
        endcase
    end
end

endmodule
