/*                    INTERNAL REQUEST SIDE
                  (your interconnect / logic)
                            |
        +-------------------+-------------------+
        |                   |                   |
        v                   v                   v
   +-----------+       +-----------+       +-----------+
   | AXI AW    |       | AXI W     |       | AXI AR    |
   | CHANNEL   |       | CHANNEL   |       | CHANNEL   |
   +-----------+       +-----------+       +-----------+
        |                   |                   |
        | AW                | W                 | AR
        v                   v                   v
   +---------------------------------------------------+
   |                   AXI SLAVE                       |
   +---------------------------------------------------+
        |                                           |
        | B response                                | R data
        v                                           v
   +-----------+                               +-----------+
   | AXI B     |                               | AXI R     |
   | CHANNEL   |                               | CHANNEL   |
   +-----------+                               +-----------+
        |                                           |
        v                                           v
   Internal response                          Internal response*/


module axi_aw_channel (
    input  wire        clk,
    input  wire        rst_n,

    output wire [31:0] awaddr,
    output wire [7:0]  awlen,
    output wire [2:0]  awsize,
    output wire [1:0]  awburst,
    output wire        awvalid,

    input  wire        awready,

    input  wire [31:0] req_addr,
    input  wire [7:0]  req_len,
    input  wire [2:0]  req_size,
    input  wire [1:0]  req_burst,
    input  wire        req_valid,
    output wire        req_ready
);

    reg valid;

    // Pass request information to AXI
    assign awaddr  = req_addr;
    assign awlen   = req_len;
    assign awsize  = req_size;
    assign awburst = req_burst;

    // AXI valid signal
    assign awvalid = valid;

    // Can accept a new request when not busy
    assign req_ready = ~valid;

    // VALID stays high until READY
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid <= 1'b0;
        else if (valid && awready)
            valid <= 1'b0;
        else if (!valid && req_valid)
            valid <= 1'b1;
    end

endmodule

module axi_w_channel (
    input  wire        clk,
    input  wire        rst_n,

    // AXI W channel
    output wire [31:0] wdata,
    output wire [3:0]  wstrb,
    output wire        wlast,
    output wire        wvalid,
    input  wire        wready,

    // Internal request
    input  wire [31:0] req_data,
    input  wire [3:0]  req_strb,
    input  wire        req_last,
    input  wire        req_valid,
    output wire        req_ready
);

    reg valid;

    // Pass data to AXI
    assign wdata = req_data;
    assign wstrb = req_strb;
    assign wlast = req_last;

    // AXI VALID
    assign wvalid = valid;

    // Ready for a new request
    assign req_ready = ~valid;

    // W channel handshake
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid <= 1'b0;
        else if (valid && wready)
            valid <= 1'b0;
        else if (!valid && req_valid)
            valid <= 1'b1;
    end

endmodule
/*                           WRITE TRANSACTION

   AXI MASTER                                      AXI SLAVE
      |                                                |
      |                                                |
      |---- AWADDR, AWVALID -------------------------->|
      |                                                |
      |<---------------------------- AWREADY ----------|
      |                                                |
      |                                                |
      |---- WDATA, WVALID ---------------------------->|
      |                                                |
      |<----------------------------- WREADY ----------|
      |                                                |
      |                                                |
      |                    Slave processes the write   |
      |                                                |
      |                                                |
      |<------------------- BRESP [1:0] ---------------|
      |<------------------- BVALID --------------------|
      |                                                |
      |-------------------- BREADY ------------------->|
      |                                                |
      v                                                |
   AXI MASTER */
module axi_b_channel (
    input  wire        clk,
    input  wire        rst_n,

    // AXI B channel
    input  wire [1:0]  bresp,
    input  wire        bvalid,
    output wire        bready,

    // Internal response
    output reg  [1:0]  resp,
    output reg         resp_valid
);

    // Always ready to receive response
    assign bready = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            resp       <= 2'b00;
            resp_valid <= 1'b0;
        end
        else begin
            resp_valid <= 1'b0;

            if (bvalid && bready) begin
                resp       <= bresp;
                resp_valid <= 1'b1;
            end
        end
    end

endmodule
module axi_ar_channel (
    input  wire        clk,
    input  wire        rst_n,

    // AXI AR channel
    output wire [31:0] araddr,
    output wire [7:0]  arlen,
    output wire [2:0]  arsize,
    output wire [1:0]  arburst,
    output wire        arvalid,
    input  wire        arready,

    // Internal request
    input  wire [31:0] req_addr,
    input  wire [7:0]  req_len,
    input  wire [2:0]  req_size,
    input  wire [1:0]  req_burst,
    input  wire        req_valid,
    output wire        req_ready
);

    reg valid;

    assign araddr  = req_addr;
    assign arlen   = req_len;
    assign arsize  = req_size;
    assign arburst = req_burst;

    assign arvalid = valid;

    assign req_ready = ~valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid <= 1'b0;
        else if (valid && arready)
            valid <= 1'b0;
        else if (!valid && req_valid)
            valid <= 1'b1;
    end

endmodule
module axi_r_channel (
    input  wire        clk,
    input  wire        rst_n,

    // AXI R channel
    input  wire [31:0] rdata,
    input  wire [1:0]  rresp,
    input  wire        rlast,
    input  wire        rvalid,
    output wire        rready,

    // Internal response
    output reg  [31:0] resp_data,
    output reg  [1:0]  resp_status,
    output reg         resp_last,
    output reg         resp_valid
);

    // Always ready to receive read data
    assign rready = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            resp_data   <= 32'b0;
            resp_status <= 2'b00;
            resp_last   <= 1'b0;
            resp_valid  <= 1'b0;
        end
        else begin
            resp_valid <= 1'b0;

            if (rvalid && rready) begin
                resp_data   <= rdata;
                resp_status <= rresp;
                resp_last   <= rlast;
                resp_valid  <= 1'b1;
            end
        end
    end

endmodule


