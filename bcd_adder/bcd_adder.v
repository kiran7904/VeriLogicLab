module bcd_adder(sum, carry, a, b, cin);
input [3:0] a, b;
input cin;
output [3:0] sum;
output carry;
reg [4:0] t;
reg [3:0] sum;
reg carry;

always @(a, b, cin) begin
    t = a + b + cin;
    if (t > 9) begin
        t = t + 6;
        carry = 1;
        sum = t[3:0];
    end else begin
        carry = 0;
        sum = t[3:0];
    end
end

endmodule
