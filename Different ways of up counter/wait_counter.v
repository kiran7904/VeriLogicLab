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
    #10;
    rst = 0;

    // Wait until q reaches 4'b1111 (15)
    wait (q == 4'b1111);
    #10;  // Wait one more cycle to observe 1111
    $finish;
  end

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0, tb);
    $monitor("Time=%0t | rst=%b | q=%b", $time, rst, q);
  end

endmodule
