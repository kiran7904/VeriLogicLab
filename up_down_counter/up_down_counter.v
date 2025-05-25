module up_down_counter #(
    parameter N = 8
)(
    input clk,
    input reset,
    input load,
    input up_down,              // 1 = up, 0 = down
    input [N-1:0] load_data,
    output reg [N-1:0] count
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 0;
    else if (load)
        count <= load_data;
    else if (up_down)
        count <= count + 1;
    else
        count <= count - 1;
end

endmodule
