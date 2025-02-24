module uart_tx (
    input wire clk,
    input wire tx_en,
    input wire [7:0] data_in,
    input wire start,
    output reg tx,       
    output wire busy
);

reg [3:0] bit_index = 0;
reg [9:0] shift_reg = 10'b1111111111; 
reg sending = 0;

assign busy = sending;

always @(posedge clk) begin
    if (start && !sending) begin
        shift_reg <= {1'b1, data_in, 1'b0}; 
        sending <= 1;
        bit_index <= 0;
    end
    if (tx_en && sending) begin
        tx <= shift_reg[0];
        shift_reg <= shift_reg >> 1;
        bit_index <= bit_index + 1;
        if (bit_index == 9)
            sending <= 0;
    end
end

endmodule
