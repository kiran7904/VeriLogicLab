module i2c_slave #(
    parameter [6:0] SLAVE_ADDR = 7'b1010000
)(
    input clk,
    input rst,
    inout sda,
    input scl,
    output reg [7:0] received_data,
    input [7:0] send_data
);

    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sda_out, sda_en;

    assign sda = sda_en ? sda_out : 1'bz;

    always @(negedge scl or posedge rst) begin
        if (rst) begin
            state <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            received_data <= 0;
            sda_en <= 0;
            sda_out <= 1;
        end else begin
            case (state)

                0: begin
                    shift_reg[7 - bit_cnt] <= sda;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        state <= (shift_reg[7:1] == SLAVE_ADDR) ? (sda ? 3 : 2) : 7;
                        bit_cnt <= 0;
                    end
                end


                2: begin
                    shift_reg[7 - bit_cnt] <= sda;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        received_data <= shift_reg;
                        state <= 4;
                        bit_cnt <= 0;
                    end
                end


                3: begin
                    sda_en <= 1;
                    sda_out <= send_data[7 - bit_cnt];
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        state <= 6;
                        bit_cnt <= 0;
                    end
                end


                4: begin
                    sda_en <= 1;
                    sda_out <= 0;
                    state <= 7;
                end


                6: begin
                    sda_en <= 0;
                    state <= 7;
                end


                7: begin
                    sda_en <= 0;
                end
            endcase
        end
    end
endmodule
