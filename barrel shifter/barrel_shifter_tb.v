module barrel_shifter_tb;

    reg [3:0] data_in;    // 4-bit input data
    reg [1:0] shift;      // Shift amount (00, 01, 10, 11)
    reg dir;              // Direction control (0 = Left, 1 = Right)
    wire [3:0] data_out;  // Shifted output

    // Instantiate the barrel shifter
    barrel_shifter uut (
        .data_in(data_in),
        .shift(shift),
        .dir(dir),
        .data_out(data_out)
    );

    // Test sequence
    initial begin
        // Initialize inputs
        data_in = 4'b1011;  // Input value: 1011
        shift = 2'b00;      // No shift
        dir = 1'b0;         // Left shift
        #10;
        
        // Left shifts
        dir = 1'b0;         // Left shift
        shift = 2'b01;      // Shift by 1
        #10;
        
        shift = 2'b10;      // Shift by 2
        #10;
        
        shift = 2'b11;      // Shift by 3
        #10;

        // Right shifts
        dir = 1'b1;         // Right shift
        shift = 2'b01;      // Shift by 1
        #10;
        
        shift = 2'b10;      // Shift by 2
        #10;
        
        shift = 2'b11;      // Shift by 3
        #10;

        // Reset test
        data_in = 4'b1100;  // New input value: 1100
        shift = 2'b00;      // No shift
        dir = 1'b0;         // Left shift
        #10;

        // Left shifts again
        dir = 1'b0;         // Left shift
        shift = 2'b01;      // Shift by 1
        #10;

        shift = 2'b10;      // Shift by 2
        #10;

        shift = 2'b11;      // Shift by 3
        #10;

        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, data_in = %b, shift = %b, dir = %b -> data_out = %b", $time, data_in, shift, dir, data_out);
    end

endmodule
