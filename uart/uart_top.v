module uart_top (
    input wire clk,
    input wire rx,
    input wire [7:0] data_in,
    input wire send,
    output wire tx,
    output wire busy,
    output wire [7:0] data_out,
    output wire data_ready
);

wire rx_en, tx_en;

baud_generator baud_gen (
    .clk(clk),
    .rx_en(rx_en),
    .tx_en(tx_en)
);

uart_tx transmitter (
    .clk(clk),
    .tx_en(tx_en),
    .data_in(data_in),
    .send(send),
    .tx(tx),
    .busy(busy)
);

uart_rx receiver (
    .clk(clk),
    .rx(rx),
    .rx_en(rx_en),
    .clr_ready(send),
    .data_out(data_out),
    .data_ready(data_ready)
);

endmodule
