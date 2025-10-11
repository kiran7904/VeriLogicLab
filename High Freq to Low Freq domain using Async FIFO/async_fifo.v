module async_fifo #(parameter WIDTH=8, DEPTH=8)(
    input  wire wr_clk, rd_clk, rst,
    input  wire wr_en, rd_en,
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout,
    output wire empty, full
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wr_ptr = 0, rd_ptr = 0;

    // Write domain
    always @(posedge wr_clk or posedge rst) begin
        if (rst)
            wr_ptr <= 0;
        else if (wr_en && !full)
            mem[wr_ptr[$clog2(DEPTH)-1:0]] <= din,
            wr_ptr <= wr_ptr + 1;
    end

    // Read domain
    always @(posedge rd_clk or posedge rst) begin
        if (rst)
            rd_ptr <= 0;
        else if (rd_en && !empty)
            dout <= mem[rd_ptr[$clog2(DEPTH)-1:0]],
            rd_ptr <= rd_ptr + 1;
    end

    assign full  = ((wr_ptr - rd_ptr) == DEPTH);
    assign empty = (wr_ptr == rd_ptr);

endmodule
