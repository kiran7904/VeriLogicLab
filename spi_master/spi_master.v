module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CPOL = 0,
    parameter CPHA = 0,
    parameter CLK_DIV = 4
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire miso,
    output reg mosi,
    output reg sclk,
    output reg cs_n,
    output reg done,
    output reg [DATA_WIDTH-1:0] data_out
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        TRANSFER = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t state, next_state;

    localparam BIT_CNT_WIDTH = $clog2(DATA_WIDTH + 1);
    reg [BIT_CNT_WIDTH-1:0] bit_cnt;
    reg [DATA_WIDTH-1:0] shift_reg;
    reg [DATA_WIDTH-1:0] recv_reg;

    localparam CLK_DIV_WIDTH = $clog2(CLK_DIV);
    reg [CLK_DIV_WIDTH-1:0] clk_div_cnt;
    reg spi_clk_en;

    reg sclk_internal;
    wire leading_edge = (CPHA == 0) ? (sclk_internal == ~CPOL) : (sclk_internal == CPOL);
    wire trailing_edge = ~leading_edge;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_cnt <= 0;
            spi_clk_en <= 0;
        end else if (state == TRANSFER) begin
            if (clk_div_cnt == CLK_DIV - 1) begin
                clk_div_cnt <= 0;
                spi_clk_en <= 1;
            end else begin
                clk_div_cnt <= clk_div_cnt + 1;
                spi_clk_en <= 0;
            end
        end else begin
            clk_div_cnt <= 0;
            spi_clk_en <= 0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = TRANSFER;
            end
            TRANSFER: begin
                if (bit_cnt == DATA_WIDTH && trailing_edge && spi_clk_en)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            recv_reg <= 0;
            data_out <= 0;
            sclk_internal <= CPOL;
            mosi <= 0;
            cs_n <= 1;
            sclk <= CPOL;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    cs_n <= 1;
                    sclk <= CPOL;
                    sclk_internal <= CPOL;
                    done <= 0;
                    bit_cnt <= 0;
                    mosi <= 0;
                    if (start) begin
                        shift_reg <= data_in;
                        recv_reg <= 0;
                        cs_n <= 0;
                    end
                end

                TRANSFER: begin
                    if (spi_clk_en) begin
                        sclk_internal <= ~sclk_internal;
                        sclk <= sclk_internal;

                        if (leading_edge) begin
                            mosi <= shift_reg[DATA_WIDTH-1];
                            shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                        end

                        if (trailing_edge) begin
                            recv_reg <= {recv_reg[DATA_WIDTH-2:0], miso};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                DONE: begin
                    cs_n <= 1;
                    sclk <= CPOL;
                    sclk_internal <= CPOL;
                    done <= 1;
                    mosi <= 0;
                    data_out <= recv_reg;
                end
            endcase
        end
    end

endmodule
