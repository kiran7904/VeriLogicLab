module booth_multiplier (
    input clk,
    input reset,           
    input start,
    input signed [3:0] multiplicand,
    input signed [3:0] multiplier,
    output reg signed [7:0] product,
    output reg done
);

    reg signed [7:0] A, S, P;
    reg [2:0] count;
    reg busy;

    always @(posedge clk) begin
        if (reset) begin
            A <= 0;
            S <= 0;
            P <= 0;
            count <= 0;
            product <= 0;
            done <= 0;
            busy <= 0;
        end else if (start && !busy) begin
            // Initialize registers at start
            A <= {multiplicand, 4'b0000};
            S <= {-multiplicand, 4'b0000};
            P <= {4'b0000, multiplier, 1'b0};
            count <= 4;
            done <= 0;
            busy <= 1;
        end else if (busy) begin
            if (count > 0) begin
             
                case (P[1:0])
                    2'b01: P <= (P + A) >>> 1;
                    2'b10: P <= (P + S) >>> 1;
                    default: P <= P >>> 1;  
                endcase
                count <= count - 1;
            end else begin
                product <= P[7:0];
                done <= 1;
                busy <= 0;
            end
        end else begin
            done <= 0;  
        end
    end

endmodule
