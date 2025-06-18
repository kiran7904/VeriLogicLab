module barrelshift(out, In, n, lr);
  output reg [7:0] out;
  input [7:0] In;
  input [2:0] n;
  input lr;

  always @*
  begin
    if (lr)
      out = In >> n;
    else
      out = In << n;
  end

endmodule