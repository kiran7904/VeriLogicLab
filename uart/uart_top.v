module uart_top (
    input wire clk,
    input wire rx,
    output wire tx,
    input wire [7:0] data_in,
    input wire send,
    output wire busy,
    output wire [7:0] data_out,
    output wire data_ready
);

wire rx_enable, tx_enable;

baud_generator baudgen (
    .clk(clk),
    .rx_en(rx_enable),
    .tx_en(tx_enable)
);

uart_tx transmitter (
    .clk(clk),
    .tx_en(tx_enable),
    .data_in(data_in),
    .start(send),
    .tx(tx),
    .busy(busy)
);

uart_rx receiver (
    .clk(clk),
    .rx_en(rx_enable),
    .rx(rx),
    .data_out(data_out),
    .ready(data_ready)
);

endmodule
