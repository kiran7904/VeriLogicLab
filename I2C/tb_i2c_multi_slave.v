`timescale 1ns / 1ps

module tb_i2c_multi_slave();

    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg rw = 0;
    reg [7:0] din = 8'h55;
    wire scl;
    wire sda;
    wire done;
    wire [7:0] rx_data;

    i2c_master_rw master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .rw(rw),
        .din(din),
        .scl(scl),
        .sda(sda),
        .done(done),
        .rx_data(rx_data)
    );

    wire [7:0] recv1;
    i2c_slave #(.SLAVE_ADDR(7'b1010000)) slave1 (
        .clk(clk),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .received_data(recv1),
        .send_data(8'hA5),
        .id(1)
    );

    wire [7:0] recv2;
    i2c_slave #(.SLAVE_ADDR(7'b1010010)) slave2 (
        .clk(clk),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .received_data(recv2),
        .send_data(8'h5A),
        .id(2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("i2c.vcd");
        $dumpvars(0, tb_i2c_multi_slave);
        rst = 1;
        #20 rst = 0;

        rw = 0;
        din = 8'hBE;
        start = 1;
        #10 start = 0;

        wait(done);
        #100;

        rw = 1;
        start = 1;
        #10 start = 0;

        wait(done);
        #100;

        $display("Slave1 received: %h", recv1);
        $display("Master read: %h", rx_data);

        $finish;
    end
endmodule
