module barrel_shifter (
    input  wire [3:0] data_in,   // 4-bit input data
    input  wire [1:0] shift,     // Shift amount (00, 01, 10, 11)
    input  wire dir,             // Direction (0 = Left, 1 = Right)
    output wire [3:0] data_out   // Shifted output
);

    assign data_out = (dir == 1'b0) ? // Left Shift
                      ((shift == 2'b00) ? data_in           : 
                       (shift == 2'b01) ? {data_in[2:0], 1'b0} : 
                       (shift == 2'b10) ? {data_in[1:0], 2'b00} : 
                                         {data_in[0], 3'b000}) 
                    : // Right Shift
                      ((shift == 2'b00) ? data_in           : 
                       (shift == 2'b01) ? {1'b0, data_in[3:1]} : 
                       (shift == 2'b10) ? {2'b00, data_in[3:2]} : 
                                         {3'b000, data_in[3]}); 

endmodule
