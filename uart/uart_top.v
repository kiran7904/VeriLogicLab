module uart_loopback_top (
    input wire clk,
    input wire send,
    input wire [7:0] data_in,
    input wire clr_ready,
    output wire [7:0] data_out,
    output wire data_ready
);

wire tx;        
wire tx_en, rx_en;
wire busy;

// Instantiate baud generator
baud_generator baud_gen (
    .clk(clk),
    .rx_en(rx_en),
    .tx_en(tx_en)
);
uart_tx tx_inst (
    .clk(clk),
    .tx_en(tx_en),
    .data_in(data_in),
    .send(send),
    .tx(tx),
    .busy(busy)
);

// Receiver
uart_rx rx_inst (
    .clk(clk),
    .rx(tx),          
    .rx_en(rx_en),
    .clr_ready(clr_ready),
    .data_out(data_out),
    .data_ready(data_ready)
);

endmodule