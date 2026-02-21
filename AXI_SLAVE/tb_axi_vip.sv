`timescale 1ns / 1ps

module tb_axi_vip;

    logic clk, rst_n;

    logic [3:0] awaddr, araddr;
    logic awvalid, awready;
    logic wvalid, wready;
    logic [31:0] wdata, rdata;
    logic [3:0] wstrb;
    logic bvalid, bready;
    logic rvalid, rready;
    logic [1:0] bresp, rresp;

    axi_slave_protocol dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    task axi_write(input [3:0] addr, input [31:0] data);
        awaddr  <= addr;
        awvalid <= 1;
        wait (awready);
        @(posedge clk);
        awvalid <= 0;

        wdata   <= data;
        wstrb   <= 4'hF;
        wvalid  <= 1;
        wait (wready);
        @(posedge clk);
        wvalid <= 0;

        bready <= 1;
        wait (bvalid);
        @(posedge clk);
        bready <= 0;
    endtask

    task axi_read(input [3:0] addr);
        araddr  <= addr;
        arvalid <= 1;
        wait (arready);
        @(posedge clk);
        arvalid <= 0;

        rready <= 1;
        wait (rvalid);
        @(posedge clk);
        rready <= 0;
    endtask

    initial begin
        rst_n = 0;
        awvalid = 0;
        wvalid  = 0;
        arvalid = 0;
        bready  = 0;
        rready  = 0;
        wstrb   = 0;
        #20 rst_n = 1;

        axi_write(4'h0, 32'hDEADBEEF);
        axi_read(4'h0);

        axi_write(4'hC, 32'hCAFEBABE);

        #100 $finish;
    end

endmodule
