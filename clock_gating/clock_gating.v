module clock_gating (
    input clk,
    input enable,
    output gated_clk
);

reg gated_clk_reg;

always @(posedge clk) begin
    gated_clk_reg <= enable;
end

assign gated_clk = clk & gated_clk_reg;

endmodule
