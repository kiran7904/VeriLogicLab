module baud_generator (
    input wire clk,      
    output wire rx_en,  
    output wire tx_en    
);

parameter RX_MAX = 50000000 / (115200 * 16); // Oversampling 16x
parameter TX_MAX = 50000000 / 115200;

reg [15:0] rx_count = 0;
reg [15:0] tx_count = 0;
reg rx_en_reg = 0;
reg tx_en_reg = 0;

assign rx_en = rx_en_reg;
assign tx_en = tx_en_reg;

always @(posedge clk) begin
    if (rx_count == RX_MAX - 1) begin
        rx_count <= 0;
        rx_en_reg <= 1;
    end else begin
        rx_count <= rx_count + 1;
        rx_en_reg <= 0;
    end

    if (tx_count == TX_MAX - 1) begin
        tx_count <= 0;
        tx_en_reg <= 1;
    end else begin
        tx_count <= tx_count + 1;
        tx_en_reg <= 0;
    end
end

endmodule
