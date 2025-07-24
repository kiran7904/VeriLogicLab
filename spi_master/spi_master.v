/**
 * Mode-configurable SPI Master (Supports CPOL/CPHA)
 * - Full duplex, 8-bit data transfer
 * - SPI clock (sclk) generated internally
 * - Active-low chip select (cs_n)
 * - 'start' triggers single transfer
 * - 'done' flags completion (1 clk pulse)
 */

module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CPOL = 0, // Clock Polarity (0: idle low, 1: idle high)
    parameter CPHA = 0  // Clock Phase (0: sample second edge, 1: sample first edge)
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    input  wire [DATA_WIDTH-1:0]   data_in,
    output reg                     mosi,
    input  wire                    miso,
    output reg                     sclk,
    output reg                     cs_n,
    output reg                     done,
    output reg [DATA_WIDTH-1:0]    data_out
);

    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        TRANSFER = 2'b01,
        DONE     = 2'b10
    } spi_state_t;

    spi_state_t state, next_state;

    reg [2:0] bit_cnt;
    reg [DATA_WIDTH-1:0] shift_reg, recv_shift;
    reg clk_div;

    // Clock divider (÷2) to generate SPI clock
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_div <= 1'b0;
        else
            clk_div <= ~clk_div;
    end

    // Main FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            cs_n       <= 1'b1;
            sclk       <= CPOL;
            done       <= 1'b0;
            mosi       <= 1'b0;
            bit_cnt    <= 3'd0;
            shift_reg  <= 0;
            recv_shift <= 0;
            data_out   <= 0;
            next_state <= IDLE;
        end else begin
            state <= next_state;

            case (state)

                IDLE: begin
                    cs_n       <= 1'b1;
                    sclk       <= CPOL;
                    done       <= 1'b0;
                    mosi       <= 1'b0;
                    bit_cnt    <= 0;

                    if (start) begin
                        shift_reg  <= data_in;
                        recv_shift <= 0;
                        cs_n       <= 1'b0;
                        next_state <= TRANSFER;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                TRANSFER: begin
                    done <= 1'b0;

                    if (clk_div) begin
                        sclk <= ~sclk;

                        // Phase-dependent edge control
                        if ((CPHA == 0 && sclk == ~CPOL) || (CPHA == 1 && sclk == CPOL)) begin
                            // Shift out on shift edge
                            mosi <= shift_reg[DATA_WIDTH-1];
                            shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                        end

                        if ((CPHA == 0 && sclk == CPOL) || (CPHA == 1 && sclk == ~CPOL)) begin
                            // Sample in on sample edge
                            recv_shift <= {recv_shift[DATA_WIDTH-2:0], miso};
                            bit_cnt <= bit_cnt + 1;

                            if (bit_cnt == (DATA_WIDTH - 1)) begin
                                data_out   <= {recv_shift[DATA_WIDTH-2:0], miso};
                                next_state <= DONE;
                            end else begin
                                next_state <= TRANSFER;
                            end
                        end
                    end else begin
                        next_state <= TRANSFER;
                    end
                end

                DONE: begin
                    cs_n       <= 1'b1;
                    sclk       <= CPOL;
                    done       <= 1'b1;
                    next_state <= IDLE;
                end

                default: next_state <= IDLE;
            endcase
        end
    end
endmodule
