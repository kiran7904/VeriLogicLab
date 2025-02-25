module uart_tx (
    input wire clk,
    input wire tx_en,
    input wire [7:0] data_in,
    input wire send,
    output reg tx = 1,
    output wire busy
);

parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

reg [1:0] state = IDLE;
reg [2:0] bit_index = 0;
reg [7:0] shift_reg = 0;

always @(posedge clk) begin
    case (state)
        IDLE: begin
            if (send) begin
                state <= START;
                shift_reg <= data_in;
            end
        end
        START: begin
            if (tx_en) begin
                tx <= 0; // Start bit
                state <= DATA;
                bit_index <= 0;
            end
        end
        DATA: begin
            if (tx_en) begin
                tx <= shift_reg[bit_index];
                bit_index <= bit_index + 1;
                if (bit_index == 7) 
                    state <= STOP;
            end
        end
        STOP: begin
            if (tx_en) begin
                tx <= 1; // Stop bit
                state <= IDLE;
            end
        end
    endcase
end

assign busy = (state != IDLE);

endmodule
