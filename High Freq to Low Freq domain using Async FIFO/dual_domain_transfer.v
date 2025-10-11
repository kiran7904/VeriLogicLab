`timescale 1ns/1ps

module dual_domain_transfer (
    input  wire clk_fast1,    // High freq clock domain 1
    input  wire clk_fast2,    // High freq clock domain 2
    input  wire clk_slow,     // Low freq clock domain
    input  wire rst,

    input  wire [7:0] data_in1,
    input  wire [7:0] data_in2,
    input  wire       valid1,
    input  wire       valid2,

    output wire [7:0] data_out1,
    output wire [7:0] data_out2,
    output wire       valid_out1,
    output wire       valid_out2
);

    // FIFO instance for domain 1
    async_fifo #(.WIDTH(8), .DEPTH(8)) fifo1 (
        .wr_clk(clk_fast1),
        .rd_clk(clk_slow),
        .rst(rst),
        .wr_en(valid1),
        .rd_en(valid_out1),
        .din(data_in1),
        .dout(data_out1),
        .empty(),
        .full()
    );

    // FIFO instance for domain 2
    async_fifo #(.WIDTH(8), .DEPTH(8)) fifo2 (
        .wr_clk(clk_fast2),
        .rd_clk(clk_slow),
        .rst(rst),
        .wr_en(valid2),
        .rd_en(valid_out2),
        .din(data_in2),
        .dout(data_out2),
        .empty(),
        .full()
    );

endmodule
