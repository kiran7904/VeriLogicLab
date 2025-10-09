module tb;
  reg [3:0]a, b;
  reg cin;
  wire [3:0]s;
  wire cy;
  cla f1(s, cy, a, b, cin);

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0,tb);
    a = 4'h0; b = 4'h0; cin = 1'h0;
    $monitor("a=%b, b=%b, cin=%b => s=%b, cy=%b", a, b, cin, s, cy);
    repeat (10) begin
      #5 a = $random % 16;
         b = $random % 16;
         cin = $random % 2;
    end
  end
endmodule
