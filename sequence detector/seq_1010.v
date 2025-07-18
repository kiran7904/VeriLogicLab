module seq_1010 (
    input  logic clk,
    input  logic reset,
    input  logic din,
    output logic dout
);

    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    logic [2:0] state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            dout  <= 1'b0;
            state <= S0;
        end else begin
            case (state)
                S0: begin
                    dout  <= 1'b0;
                    state <= din ? S1 : S0;
                end
                S1: begin
                    dout  <= 1'b0;
                    state <= ~din ? S2 : S1;
                end
                S2: begin
                    dout  <= 1'b0;
                    state <= din ? S3 : S0;
                end
                S3: begin
                    dout  <= 1'b0;
                    state <= din ? S1 : S4;
                end
                S4: begin
                    dout  <= 1'b1;
                    state <= din ? S3 : S0;
                end
            endcase
        end
    end

endmodule
