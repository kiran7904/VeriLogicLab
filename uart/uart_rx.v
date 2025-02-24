module uart_rx (
    input wire clk,
    input wire rx_en,
    input wire rx,       // UART receive line
    output reg [7:0] data_out,
    output reg ready
);

reg [3:0] bit_index = 0;
reg [7:0] shift_reg = 0;
reg receiving = 0;

always @(posedge clk) begin
    if (!receiving && !rx) begin  // Start bit detected
        receiving <= 1;
        bit_index <= 0;
    end
    if (rx_en && receiving) begin
        shift_reg <= {rx, shift_reg[7:1]};
        bit_index <= bit_index + 1;
        if (bit_index == 7) begin
            receiving <= 0;
            data_out <= shift_reg;
            ready <= 1;
        end
    end
end

always @(posedge clk) begin
    if (ready)
        ready <= 0;
end

endmodule
