
module tb_spi;
    logic clk, rst_n, start;
    logic [7:0] master_tx, master_rx;
    logic [7:0] slave_tx, slave_rx;
    logic busy, sclk, mosi, miso, cs_n;

    spi_master master_inst (
        .clk(clk), .rst_n(rst_n), .mosi_data(master_tx),
        .start(start), .busy(busy), .sclk(sclk), .mosi(mosi),
      .miso(miso), .cs_n(cb_s_n), .miso_data(master_rx)
    );

    spi_slave slave_inst (
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso),
        .tx_data(slave_tx), .rx_data(slave_rx)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
      $dumpfile("a.vcd");
      $dumpvars(0,tb_spi);
        rst_n = 0; start = 0;
        master_tx = 8'h3C;
        slave_tx  = 8'hA5;

        #20 rst_n = 1;
        #20 start = 1;
        #10 start = 0;

        wait(!busy);

        #20;
        $display("Master sent: %h, received: %h", master_tx, master_rx);
        $display("Slave  sent: %h, received: %h", slave_tx, slave_rx);

        #50 $finish;
    end
endmodule
