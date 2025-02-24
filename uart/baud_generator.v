module baud_generator (
    input wire clk,      
    output wire rx_en,  
    output wire tx_en    
);

parameter RX_MAX = 50000000 / (115200 * 16);
parameter TX_MAX = 50000000 / 115200;
reg [15:0] rx_count = 0;
reg [15:0] tx_count = 0;

assign rx_en = (rx_count == 0);
assign tx_en = (tx_count == 0);

always @(posedge clk) begin
    rx_count <= (rx_count == RX_MAX - 1) ? 0 : rx_count + 1;
    tx_count <= (tx_count == TX_MAX - 1) ? 0 : tx_count + 1;
end

endmodule
