`timescale 1ns / 1ps

module tb;


    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;


    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );


    always #5 clk = ~clk;  

    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20;
        rst = 0;


        $display("=== Writing Data ===");
        repeat (8) begin
            @(negedge clk);
            if (!full) begin
                wr_en = 1;
                din = din + 8'h11;
            end
        end
        @(negedge clk);
        wr_en = 0;

        #20;


        $display("=== Reading Data ===");
        repeat (8) begin
            @(negedge clk);
            if (!empty) begin
                rd_en = 1;
            end
        end
        @(negedge clk);
        rd_en = 0;


        $display("=== Simultaneous Read/Write ===");
        din = 8'hAA;
        repeat (4) begin
            @(negedge clk);
            wr_en = 1;
            rd_en = 1;
            din = din + 8'h01;
        end
        wr_en = 0;
        rd_en = 0;

        // Finish simulation
        #50;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("T=%0t | wr_en=%b rd_en=%b din=%h dout=%h full=%b empty=%b",
                 $time, wr_en, rd_en, din, dout, full, empty);
    end

endmodule
