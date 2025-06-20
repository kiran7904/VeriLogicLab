module clock (
    input clk,
    input rst,
    output reg [5:0] min,
    output reg [5:0] sec,
    output reg [4:0] hrs
);
    always @(posedge clk) begin
        if (rst) begin
            min <= 0;
            sec <= 0;
            hrs <= 0;
        end else begin
            sec <= sec + 1;

            if (sec == 6'd60) begin
                sec <= 0;
                min <= min + 1;

                if (min == 6'd60) begin
                    min <= 0;
                    hrs <= hrs + 1;

                    if (hrs == 5'd24)
                        hrs <= 0;
                end
            end
        end
    end
endmodule
