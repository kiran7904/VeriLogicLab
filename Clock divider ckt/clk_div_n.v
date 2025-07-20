module clk_div2 (
    input wire clk_in,
    input wire rst_n,
    output reg clk_out
);

always @(posedge clk_in or negedge rst_n) begin
    if (!rst_n)
        clk_out <= 0;
    else
        clk_out <= ~clk_out; 
end

endmodule
module clk_div_n #(
    parameter N = 4 
)(
    input wire clk_in,
    input wire rst_n,
    output reg clk_out
);

reg [$clog2(N)-1:0] count;

always @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
        clk_out <= 0;
    end else begin
        if (count == (N/2 - 1)) begin
            clk_out <= ~clk_out;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
end

endmodule
