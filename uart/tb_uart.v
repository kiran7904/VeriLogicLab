module uart_tb;
reg clk = 0;
reg rx = 1;
reg [7:0] data_in;
reg send;
wire tx, busy, data_ready;
wire [7:0] data_out;

uart_top uut (
    .clk(clk),
    .rx(rx),
    .tx(tx),
    .data_in(data_in),
    .send(send),
    .busy(busy),
    .data_out(data_out),
    .data_ready(data_ready)
);

always #10 clk = ~clk; // 50 MHz clock

initial begin
    $monitor("Time=%0t | rx=%b | tx=%b | busy=%b | data_ready=%b | data_out=%h", 
             $time, rx, tx, busy, data_ready, data_out);

    #100;
    data_in = 8'hA5;  
    send = 1;
    #20 send = 0;

    //  'A5' = 10100101
    #8680 rx = 0; // Start bit
    #8680 rx = 1; // Bit 0
    #8680 rx = 0; // Bit 1
    #8680 rx = 1; // Bit 2
    #8680 rx = 0; // Bit 3
    #8680 rx = 0; // Bit 4
    #8680 rx = 1; // Bit 5
    #8680 rx = 0; // Bit 6
    #8680 rx = 1; // Bit 7
    #8680 rx = 1; // Stop bit

    #100000;
    $stop;
end

endmodule
