module spi_master #(parameter DATA_WIDTH = 8)(
    input  logic clk,
    input  logic rst_n,
    input  logic [DATA_WIDTH-1:0] mosi_data,
    input  logic start,
    output logic busy,
    output logic sclk,
    output logic mosi,
    input  logic miso,
    output logic cs_n,
    output logic [DATA_WIDTH-1:0] miso_data
);

    typedef enum logic [1:0] {IDLE, TRANSFER, DONE} state_t;
    state_t state, next_state;

    logic [$clog2(DATA_WIDTH):0] bit_cnt;
    logic [DATA_WIDTH-1:0] tx_reg, rx_reg;
    logic sclk_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) sclk_reg <= 0;
        else if(state == TRANSFER) sclk_reg <= ~sclk_reg;
        else sclk_reg <= 0;
    end
    assign sclk = sclk_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) state <= IDLE;
        else state <= next_state;
    end

    always_comb begin
        next_state = state;
        case(state)
            IDLE:     if(start) next_state = TRANSFER;
            TRANSFER: if(bit_cnt == DATA_WIDTH && sclk_reg==1) next_state = DONE;
            DONE:     next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) bit_cnt <= 0;
        else if(state == TRANSFER && sclk_reg==1) bit_cnt <= bit_cnt + 1;
        else if(state != TRANSFER) bit_cnt <= 0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_reg <= 0; rx_reg <= 0;
        end else if(state == TRANSFER) begin
            if(sclk_reg==0) rx_reg <= {rx_reg[DATA_WIDTH-2:0], miso};
            if(sclk_reg==1) tx_reg <= {tx_reg[DATA_WIDTH-2:0], 1'b0};
        end else if(state == IDLE) begin
            tx_reg <= mosi_data;
        end
    end

    assign mosi      = tx_reg[DATA_WIDTH-1];
    assign miso_data = rx_reg;
    assign cs_n      = (state==IDLE) ? 1 : 0;
    assign busy      = (state==TRANSFER);

endmodule
module spi_slave #(parameter DATA_WIDTH = 8)(
    input  logic sclk,
    input  logic cs_n,
    input  logic mosi,
    output logic miso,
    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data
);

    logic [DATA_WIDTH-1:0] shift_reg_tx, shift_reg_rx;
    integer bit_cnt;

    always_ff @(posedge sclk or negedge cs_n) begin
        if(!cs_n) begin
            shift_reg_tx <= tx_data;
            shift_reg_rx <= '0;
            bit_cnt <= 0;
        end else begin
            shift_reg_rx <= {shift_reg_rx[DATA_WIDTH-2:0], mosi};
            shift_reg_tx <= {shift_reg_tx[DATA_WIDTH-2:0], 1'b0};
            bit_cnt <= bit_cnt + 1;
        end
    end
    assign miso    = !cs_n ? shift_reg_tx[DATA_WIDTH-1] : 1'b0;
    assign rx_data = shift_reg_rx;

endmodule

