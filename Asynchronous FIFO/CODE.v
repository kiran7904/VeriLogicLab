module async_fifo #(parameter WIDTH=8, DEPTH=8)(
    input wr_clk, rd_clk, rst,
    input wr_en, rd_en,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg full, empty,
    output reg [$clog2(DEPTH):0] count
);
  localparam ADDR_WIDTH = $clog2(DEPTH);

  reg [ADDR_WIDTH:0] rd_ptr, wr_ptr;
  reg [ADDR_WIDTH:0] rd_ptr_gray, wr_ptr_gray;
  reg [WIDTH-1:0] mem [0:DEPTH-1];
  reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
  reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

  function [ADDR_WIDTH:0] bin2gray;
    input [ADDR_WIDTH:0] bin;
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function [ADDR_WIDTH:0] gray2bin;
    input [ADDR_WIDTH:0] gray;
    integer i;
    begin
      gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
      for (i = ADDR_WIDTH-1; i >= 0; i = i - 1)
        gray2bin[i] = gray2bin[i+1] ^ gray[i];
    end
  endfunction

  always @(posedge wr_clk or posedge rst) begin
    if (rst) begin
      wr_ptr <= 0;
      wr_ptr_gray <= 0;
    end else if (wr_en && !full) begin
      mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
      wr_ptr <= wr_ptr + 1;
      wr_ptr_gray <= bin2gray(wr_ptr + 1);
    end
  end

  always @(posedge rd_clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= 0;
      rd_ptr_gray <= 0;
      dout <= 0;
    end else if (rd_en && !empty) begin
      dout <= mem[rd_ptr[ADDR_WIDTH-1:0]];
      rd_ptr <= rd_ptr + 1;
      rd_ptr_gray <= bin2gray(rd_ptr + 1);
    end
  end

  always @(posedge wr_clk or posedge rst) begin
    if (rst) begin
      rd_ptr_gray_sync1 <= 0;
      rd_ptr_gray_sync2 <= 0;
    end else begin
      rd_ptr_gray_sync1 <= rd_ptr_gray;
      rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
  end

  always @(posedge rd_clk or posedge rst) begin
    if (rst) begin
      wr_ptr_gray_sync1 <= 0;
      wr_ptr_gray_sync2 <= 0;
    end else begin
      wr_ptr_gray_sync1 <= wr_ptr_gray;
      wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
  end

  wire [ADDR_WIDTH:0] rd_ptr_gray_wr = rd_ptr_gray_sync2;
  wire [ADDR_WIDTH:0] wr_ptr_gray_rd = wr_ptr_gray_sync2;

  always @(*) begin
    full = (wr_ptr_gray == {~rd_ptr_gray_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                            rd_ptr_gray_wr[ADDR_WIDTH-2:0]});
  end

  always @(*) begin
    empty = (wr_ptr_gray_rd == rd_ptr_gray);
  end

  wire [ADDR_WIDTH:0] rd_ptr_bin_wr = gray2bin(rd_ptr_gray_wr);
  always @(posedge wr_clk or posedge rst) begin
    if (rst)
      count <= 0;
    else
      count <= wr_ptr - rd_ptr_bin_wr;
  end
endmodule

`timescale 1ns/1ps

module async_fifo_tb;
  parameter WIDTH = 8;
  parameter DEPTH = 8;
  reg wr_clk, rd_clk, rst;
  reg wr_en, rd_en;
  reg [WIDTH-1:0] din;
  wire [WIDTH-1:0] dout;
  wire full, empty;
  wire [$clog2(DEPTH):0] count;

  async_fifo #(WIDTH, DEPTH) dut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .count(count)
  );

  initial begin
    wr_clk = 0;
    forever #5 wr_clk = ~wr_clk;
  end

  initial begin
    rd_clk = 0;
    forever #7 rd_clk = ~rd_clk;
  end

  initial begin
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    din = 0;
    #20;
    rst = 0;
    repeat (50) begin
      @(posedge wr_clk);
      if (!full) begin
        wr_en = $random % 2;
        din = $random;
      end else
        wr_en = 0;
    end
  end

  initial begin
    repeat (100) begin
      @(posedge rd_clk);
      if (!empty)
        rd_en = $random % 2;
      else
        rd_en = 0;
    end
    #200 $finish;
  end

  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, async_fifo_tb);
  end
endmodule
