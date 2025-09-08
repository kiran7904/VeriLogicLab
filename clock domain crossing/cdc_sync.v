module cdc_sync (
    input  wire clk,
    input  wire rst,
    input  wire in_sig,
    output reg  out_sig
);

    reg d1, d2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1      <= 1'b0;
            d2      <= 1'b0;
            out_sig <= 1'b0;
        end else begin
            d1      <= in_sig;
            d2      <= d1;
            out_sig <= d2;
        end
    end

endmodule
