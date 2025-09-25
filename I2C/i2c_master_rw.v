module i2c_master_rw(     
    input clk,
    input rst,
    input start,
    input rw,              
    input [7:0] din,       
    output reg scl,
    inout sda,
    output reg done,
    output reg [7:0] rx_data 
);

    parameter [6:0] ADDR = 7'b1010000;

    reg [7:0] div;
    reg [3:0] cnt;
    reg [3:0] state;

    reg sda_Out;
    reg sda_en;

    assign sda = sda_en ? sda_Out : 1'bz;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div <= 0;
            scl <= 1;
        end else begin
            div <= div + 1;
            if (div == 8'd249) begin
                scl <= ~scl;
                div <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            done <= 0;
            sda_Out <= 
            sda_en <= 1;
            cnt <= 0;
            rx_data <= 0;
        end else begin
            case (state)
                0: begin  
                    done <= 0;
                    if (start) begin
                        cnt <= 6;
                        state <= 1;
                    end
                end

                1: begin 
                    if (scl == 1) begin
                        sda_en <= 1;
                        sda_Out <= 0;
                        state <= 2;
                    end
                end

                2: begin
                  if (scl == 0) begin  
                    sda_Out <= ADDR[cnt];  
                        if (cnt == 0)
                            state <= 3;
                        else
                            cnt <= cnt - 1;
                    end
                end

                3: begin
                    if (scl == 0) begin
                        sda_Out <= rw;
                        cnt <= 7;
                        if (rw)
                            state <= 4;
                        else
                            state <= 5;
                    end
                end

                4: begin
                    if (scl == 0) begin
                        sda_en <= 0;
                        state <= 6;
                    end
                end

                5: begin
                    if (scl == 0) begin
                        sda_en <= 1;
                      sda_Out <= din[cnt];
                        if (cnt == 0)
                            state <= 6;
                        else
                            cnt <= cnt - 1;
                    end
                end

                6: begin
                    if (rw) begin
                        if (scl == 1) begin
                          rx_data[cnt] <= sda; 
                            if (cnt == 0)
                                state <= 7;
                            else
                                cnt <= cnt - 1;
                        end
                    end else begin
                        if (scl == 1)
                            state <= 7;
                    end
                end

                7: begin
                    if (scl == 1) begin
                        sda_en <= 1;
                        sda_Out <= 0;
                        state <= 8;
                    end
                end

                8: begin
                    if (scl == 1) begin
                        sda_Out <= 1;
                        done <= 1;
                        state <= 0;
                    end
                end

                default: state <= 0;
            endcase
        end
    end

endmodule
