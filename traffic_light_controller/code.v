module traffic_light(output reg [1:0] roadA, roadB, input clk, rst);

  reg [6:0] count; 

  typedef enum logic [1:0] {
    RED    = 2'b00,
    GREEN  = 2'b11,
    YELLOW = 2'b10
  } light;

  localparam GT = 45;
  localparam YT = 15;
  localparam CYCLE = 2 * GT + 2 * YT; 
  always @(posedge clk) begin
    if (rst) begin
      roadA <= GREEN;
      roadB <= RED;
      count <= 0;
    end else begin
      count <= (count == CYCLE - 1) ? 0 : count + 1;

      roadA <= (count < GT)           ? GREEN :
               (count < GT + YT)      ? YELLOW :
                                       RED;

      roadB <= (count < GT + YT)              ? RED :
               (count < GT + YT + GT)         ? GREEN :
               (count < GT + YT + GT + YT)    ? YELLOW :
                                               RED;
    end
  end

endmodule
`timescale 1ns/1ps
module tb;

  reg clk, rst;
  wire [1:0]roadA,roadB;
  traffic_light c1(roadA,roadB, clk, rst);

  initial clk = 0;
  always #5 clk = ~clk;
  initial begin
    #5 $monitor("Time = %0t | clk = %b | roadA = %b | roadB = %b", $time, clk, roadA,roadB);
  end

  initial begin
    rst = 1;
    #12 rst = 0;
    #100; 
    $finish;
  end

endmodule
