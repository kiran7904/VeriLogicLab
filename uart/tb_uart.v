module tb_uart;
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

always #10 clk = ~clk;  // 50 MHz Clock

initial begin
    #100;
    data_in = 8'hA5;  
    send = 1;
    #20 send = 0;
    #100000;
    $stop;
end

endmodule
