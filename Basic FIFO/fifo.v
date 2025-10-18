module sync_fifo #(
    parameter DATA_WIDTH = 8,    // width of each data word
    parameter DEPTH = 16         // number of entries
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output reg                   full,
    output reg                   empty
);

    // Calculate address width (log2 of DEPTH)
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    // Write Operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            dout   <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Status Flags
    always @(*) begin
        empty = (wr_ptr == rd_ptr);
        full  = ((wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                 (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]));
    end

endmodule
