module baud_generator (
    input wire clk,      
    output reg rx_en,  
    output reg tx_en    
);

integer RX_MAX = 50000000 / (115200 * 16);
integer TX_MAX = 50000000 / 115200;      

reg [4:0] rx_count = 0; 
reg [8:0] tx_count = 0; 

always @(posedge clk) begin
    if (rx_count == RX_MAX - 1) begin
        rx_count <= 0;
        rx_en <= 1; 
    end else begin
        rx_count <= rx_count + 1;
        rx_en <= 0;
    end
end

always @(posedge clk) begin
    if (tx_count == TX_MAX - 1) begin
        tx_count <= 0;
        tx_en <= 1;
    end else begin
        tx_count <= tx_count + 1;
        tx_en <= 0;
    end
end

endmodule
