`timescale 1ns/1ps

module tb_pipeline;

  reg clk;
  reg reset;
  reg [31:0] pc_start;

  // Instantiate the DUT
  Pipeline5Stage dut (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_start)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("pipeline.vcd");
    $dumpvars(0, tb_pipeline);

    clk = 0;
    reset = 1;
    pc_start = 0;

    #10;
    reset = 0;

    #100;

    $finish;
  end

endmodule
