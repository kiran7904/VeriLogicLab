`timescale 1ns/1ps

module tb;

  logic clk, rst;
  logic [2:0] light;

  traffic_light dut (
    .clk(clk),
    .rst(rst),
    .light(light)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1;
    #12;
    rst = 0;
    #150;
    $finish;
  end

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0,tb);
    $display("Time | Light");
    $monitor("%0t | %b", $time, light);
  end

endmodule
