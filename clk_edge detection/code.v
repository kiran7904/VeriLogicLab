module clk_edge(output q,input clk,rst);
  reg clk1;
  always@(posedge clk)begin
    if(rst)
      clk1<=0;
     else
       clk1<=clk;
  end
  assign q=clk^clk1;
endmodule
  
`timescale 1ns/1ps
module tb;

  reg clk, rst;
  wire q;
  clk_edge c1(q, clk, rst);

  initial clk = 0;
  always #5 clk = ~clk;
  initial begin
    $monitor("Time = %0t | clk = %b | q = %b", $time, clk, q);
  end

  initial begin
    rst = 1;
    #12 rst = 0;
    repeat (10) @(posedge clk);

    #10; 
    $finish;
  end

endmodule
