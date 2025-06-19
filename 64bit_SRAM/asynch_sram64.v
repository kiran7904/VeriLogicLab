module sram_64x1 (
  input [5:0] addr,
  input data_in,
  input write,
  input read,
  output reg data_out
);
  reg [0:63] mem;

  always @(*) begin
    if (write)
      mem[addr] = data_in;
  end

  always @(*) begin
    if (read)
      data_out = mem[addr];
    else
      data_out = 1'bz;
  end
endmodule
