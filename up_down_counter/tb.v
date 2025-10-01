module tb;
  wire [3:0]q;
  reg clk,rst;
  reg updown;
  up_down m1(q,clk,rst,updown);
  initial clk=0;
  always #5 clk=~clk;
  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0,tb);
    $monitor("at %0t for updown=%b then q=",$time,updown,q);
  end
  initial begin
    rst=1;updown=0;
    #10 rst=0;
    repeat(6) begin
     #10 updown = $urandom_range(0,1);
    end
    #50 $finish;
  end
endmodule
    
    
