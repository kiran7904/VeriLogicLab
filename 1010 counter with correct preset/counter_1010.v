module counter_1010(output q,input clk,rst,in);
  reg [1:0]ps=0,ns;
  parameter s0=2'h0,s1=2'h1,s2=2'h2,s3=2'h3;
  always@(posedge clk)begin
    if(rst)
      ps<=s0;
    else
      ps<=ns;
  end
  always@(*)begin
    case(ps)
      s0: ns=in?s1:s0;
      s1: ns=in?s1:s2;
      s2: ns=in?s3:s0;
      s3: ns=in?s2:s0;
      default: ns=s0;
    endcase
  end
  assign q=(ps==s3)&&(in==0)?1:0;
endmodule
module tb;

  wire q;
  reg clk, rst, in;

  counter_1010 c1(q, clk, rst, in);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1; in = 0;
    #10;
    rst = 0;

    repeat (10) begin
      @(posedge clk);
      in = $random % 2;
    end

   #10 $finish;
  end

  initial begin
    $dumpfile("counter_1010.vcd");
    $dumpvars(0, tb);
    $monitor("Time=%0t | rst=%b | in=%b | q=%b", $time, rst, in, q);
  end

endmodule
