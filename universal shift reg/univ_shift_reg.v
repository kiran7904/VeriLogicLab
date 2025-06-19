module universal_shift_register_5bit (
  input clk,
  input reset,
  input [1:0] mode,
  input [4:0] parallel_in,
  input serial_left,
  input serial_right,
  output reg [4:0] q
);
  always @(posedge clk or posedge reset) begin
    if (reset)
      q <= 5'b00000;
    else begin
      case (mode)
        2'b00: q <= q;
        2'b01: q <= {q[3:0], serial_right};
        2'b10: q <= {serial_left, q[4:1]};
        2'b11: q <= parallel_in;
      endcase
    end
  end
endmodule
