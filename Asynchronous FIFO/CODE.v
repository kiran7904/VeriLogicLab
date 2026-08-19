module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 2
)(
    // Write clock domain
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,

    // Read clock domain
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    // ------------------------------------------------
    // FIFO memory
    // 4 locations × 8 bits
    // ------------------------------------------------

    reg [DATA_WIDTH-1:0] mem [0:3];


    // ------------------------------------------------
    // Write pointer
    // ------------------------------------------------

    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] wr_ptr_gray;


    // ------------------------------------------------
    // Read pointer
    // ------------------------------------------------

    reg [ADDR_WIDTH:0] rd_ptr_bin;
    reg [ADDR_WIDTH:0] rd_ptr_gray;


    // ------------------------------------------------
    // Synchronizers
    // Read pointer → Write clock domain
    // ------------------------------------------------

    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync2;


    // Write pointer → Read clock domain
    // ------------------------------------------------

    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync2;


    // =================================================
    // WRITE SIDE
    // =================================================

    always @(posedge wr_clk or negedge wr_rst_n) begin

        if (!wr_rst_n) begin

            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;

        end
        else if (wr_en && !full) begin

            // Write data into memory
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

            // Increment binary pointer
            wr_ptr_bin <= wr_ptr_bin + 1'b1;

            // Convert new binary pointer to Gray code
            wr_ptr_gray <=
                (wr_ptr_bin + 1'b1) ^
                ((wr_ptr_bin + 1'b1) >> 1);

        end

    end


    // =================================================
    // READ SIDE
    // =================================================

    always @(posedge rd_clk or negedge rd_rst_n) begin

        if (!rd_rst_n) begin

            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            rd_data     <= 0;

        end
        else if (rd_en && !empty) begin

            // Read data from memory
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

            // Increment binary pointer
            rd_ptr_bin <= rd_ptr_bin + 1'b1;

            // Convert new binary pointer to Gray code
            rd_ptr_gray <=
                (rd_ptr_bin + 1'b1) ^
                ((rd_ptr_bin + 1'b1) >> 1);

        end

    end


    // =================================================
    // Synchronize READ pointer into WRITE domain
    // =================================================

    always @(posedge wr_clk or negedge wr_rst_n) begin

        if (!wr_rst_n) begin

            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;

        end
        else begin

            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;

        end

    end


    // =================================================
    // Synchronize WRITE pointer into READ domain
    // =================================================

    always @(posedge rd_clk or negedge rd_rst_n) begin

        if (!rd_rst_n) begin

            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;

        end
        else begin

            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;

        end

    end


    // =================================================
    // EMPTY
    // =================================================

    assign empty =
        (rd_ptr_gray == wr_ptr_gray_sync2);


    // =================================================
    // FULL
    // =================================================

    assign full =
        (wr_ptr_gray ==
        {
            ~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
             rd_ptr_gray_sync2[ADDR_WIDTH-2:0]
        });

endmodule
