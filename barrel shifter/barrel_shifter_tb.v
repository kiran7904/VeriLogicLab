module tb_barrelshift;
  reg [7:0] In;
  reg [2:0] n;
  reg lr;
  wire [7:0] out;

  barrelshift dut (
    .out(out),
    .In(In),
    .n(n),
    .lr(lr)
  );

  initial begin
    $monitor("Time=%0d | In=%b | n=%d | lr=%b | out=%b", $time, In, n, lr, out);

    In = 8'b10110011; n = 3; lr = 0;
    #10;

    In = 8'b10110011; n = 2; lr = 1;
    #10;

    In = 8'b11110000; n = 0; lr = 0;
    #10;

    In = 8'b11110000; n = 0; lr = 1;
    #10;

    In = 8'b00001111; n = 1; lr = 0;
    #10;

    In = 8'b00001111; n = 1; lr = 1;
    #10;

    $finish;
  end
endmodule