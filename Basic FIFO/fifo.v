module fifo #(parameter DEPTH=4, WIDTH=8) (
  input  logic clk, rst_n,
  input  logic wr_en, rd_en,
  input  logic [WIDTH-1:0] din,
  output logic [WIDTH-1:0] dout,
  output logic full, empty
);
  logic [WIDTH-1:0] mem[DEPTH-1:0];
  int wptr, rptr, count;
  assign full  = (count == DEPTH);
  assign empty = (count == 0);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr <= 0; rptr <= 0; count <= 0;
    end else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: begin
          mem[wptr] <= din;
          wptr <= (wptr+1) % DEPTH;
          count <= count + 1;
        end
        2'b01: begin
          dout <= mem[rptr];
          rptr <= (rptr+1) % DEPTH;
          count <= count - 1;
        end
        2'b11: begin
          mem[wptr] <= din;
          dout <= mem[rptr];
          wptr <= (wptr+1) % DEPTH;
          rptr <= (rptr+1) % DEPTH;
        end
      endcase
    end
  end
endmodule
