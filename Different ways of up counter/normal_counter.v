module up_counter(output reg [3:0]q,input clk,rst);
  initial q=4'h0;
  always@(posedge clk)begin
    if(rst)
      q<=4'h0;
    else
      q<=q+1;
  end
endmodule
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

  // Clock generation using initial + forever method
  // Alternative: you can also use initial clk = 0; always #5 clk = ~clk;
  initial begin
    clk = 0; #2
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    #10;
    rst = 0;

    #50;
    rst = 1;
    #10;
    rst = 0;

    #50;
    $finish;
  end

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0, tb);
    #10 $monitor("Time=%0t | rst=%b | q=%b", $time, rst, q);
  end

endmodule
