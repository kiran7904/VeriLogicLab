module ahb_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS   = 4
)(
    input wire HCLK,
    input wire HRESETn,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire [2:0] HSIZE,
    input wire [2:0] HBURST,
    input wire HSEL,
    input wire HREADY,
    input wire [DATA_WIDTH-1:0] HWDATA,
    output reg [DATA_WIDTH-1:0] HRDATA,
    output reg HREADYOUT,
    output reg [1:0] HRESP
);

    reg [DATA_WIDTH-1:0] regs [0:NUM_REGS-1];

    wire [$clog2(NUM_REGS)-1:0] addr_index;
    assign addr_index = HADDR[($clog2(NUM_REGS)+1):2];

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        BUSY    = 2'b01,
        NONSEQ  = 2'b10,
        SEQ     = 2'b11
    } ahb_trans_t;

    typedef enum logic [1:0] {
        OKAY  = 2'b00,
        ERROR = 2'b01
    } ahb_resp_t;

    reg wait_state;
    reg [ADDR_WIDTH-1:0] addr_reg;
    reg write_reg;
    reg sel_reg;

    integer i;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            for (i = 0; i < NUM_REGS; i = i + 1)
                regs[i] <= 0;

            addr_reg   <= 0;
            write_reg  <= 0;
            sel_reg    <= 0;
            HRDATA     <= 0;
            HREADYOUT  <= 1;
            HRESP      <= OKAY;
            wait_state <= 0;

        end else begin
            HREADYOUT <= 1;
            HRESP     <= OKAY;
            HRDATA    <= 0;

            if (HREADY) begin
                if (HSEL && (HTRANS == NONSEQ || HTRANS == SEQ)) begin
                    addr_reg   <= HADDR;
                    write_reg  <= HWRITE;
                    sel_reg    <= 1;
                    wait_state <= 0;
                end else begin
                    sel_reg <= 0;
                end
            end

            if (sel_reg) begin
                if (addr_index < NUM_REGS) begin
                    if (write_reg) begin
                        regs[addr_index] <= HWDATA;
                    end else begin
                        HRDATA <= regs[addr_index];
                    end
                end else begin
                    HRESP  <= ERROR;
                    HRDATA <= 32'b0;
                end
            end
        end
    end
endmodule
