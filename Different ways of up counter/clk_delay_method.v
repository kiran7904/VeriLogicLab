// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb;

  reg clk;
  reg rst;
  wire [3:0] q;

  up_counter uut (
    .clk(clk),
    .rst(rst),
    .q(q)
  );
  initial begin
    clk = 0; #2
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    @(posedge clk)
    rst=0;
    repeat(10) @(posedge clk)
    rst = 0;
    $finish;
  end

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0, tb);
    $monitor("Time=%0t | rst=%b | q=%b", $time, rst, q);
  end

endmodule
