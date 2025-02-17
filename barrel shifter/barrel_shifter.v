module barrel_shifter (
    input  wire [3:0] data_in,   // 4-bit input data
    input  wire [1:0] shift,     // Shift amount (00, 01, 10, 11)
    input  wire dir,             // Direction (0 = Left, 1 = Right)
    output reg [3:0] data_out    // Shifted output
);

    always @(*) begin
        if (dir == 1'b0) begin
            // Left Shift
            case (shift)
                2'b00: data_out = data_in;            // No shift
                2'b01: data_out = {data_in[2:0], 1'b0}; // Shift by 1
                2'b10: data_out = {data_in[1:0], 2'b00}; // Shift by 2
                2'b11: data_out = {data_in[0], 3'b000};  // Shift by 3
                default: data_out = 4'b0000;
            endcase
        end else begin
            // Right Shift
            case (shift)
                2'b00: data_out = data_in;            // No shift
                2'b01: data_out = {1'b0, data_in[3:1]}; // Shift by 1
                2'b10: data_out = {2'b00, data_in[3:2]}; // Shift by 2
                2'b11: data_out = {3'b000, data_in[3]};  // Shift by 3
                default: data_out = 4'b0000;
            endcase
        end
    end

endmodule
