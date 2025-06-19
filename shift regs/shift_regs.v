module shift_register_siso (
  input clk,
  input reset,
  input serial_in,
  output serial_out
);
  reg [3:0] shift_reg;
  always @(posedge clk or posedge reset) begin
    if (reset)
      shift_reg <= 4'b0000;
    else
      shift_reg <= {shift_reg[2:0], serial_in};
  end
  assign serial_out = shift_reg[3];
endmodule

module shift_register_sipo (
  input clk,
  input reset,
  input serial_in,
  output [3:0] parallel_out
);
  reg [3:0] shift_reg;
  always @(posedge clk or posedge reset) begin
    if (reset)
      shift_reg <= 4'b0000;
    else
      shift_reg <= {shift_reg[2:0], serial_in};
  end
  assign parallel_out = shift_reg;
endmodule

module shift_register_piso (
  input clk,
  input reset,
  input load,
  input [3:0] parallel_in,
  output serial_out
);
  reg [3:0] shift_reg;
  always @(posedge clk or posedge reset) begin
    if (reset)
      shift_reg <= 4'b0000;
    else if (load)
      shift_reg <= parallel_in;
    else
      shift_reg <= {1'b0, shift_reg[3:1]};
  end
  assign serial_out = shift_reg[0];
endmodule

module shift_register_pipo (
  input clk,
  input reset,
  input load,
  input [3:0] parallel_in,
  output reg [3:0] parallel_out
);
  always @(posedge clk or posedge reset) begin
    if (reset)
      parallel_out <= 4'b0000;
    else if (load)
      parallel_out <= parallel_in;
  end
endmodule
