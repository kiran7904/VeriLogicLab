module GIFT64 (
    input wire clk, 
    input wire rst, 
    input wire [63:0] plaintext,
    input wire [127:0] key,
    input wire encrypt,
    output reg [63:0] ciphertext
);
    parameter ROUNDS = 40;
    reg [63:0] state;
    reg [127:0] round_keys [0:ROUNDS-1];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < ROUNDS; i = i + 1) begin
                round_keys[i] <= 128'h0;
            end
        end else begin
            round_keys[0] <= key;
            for (i = 1; i < ROUNDS; i = i + 1) begin
                round_keys[i] <= {round_keys[i-1][63:0], round_keys[i-1][127:64]} ^ (i * 32'h1B);
            end
        end
        ![Image](https://github.com/user-attachments/assets/b7d1f7a4-8c1c-452e-8a83-ffa914340bec)
    end

    reg [3:0] lfsr;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 4'hF;
        end else begin
            lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]}; 
        end
    end

    function [3:0] SBox(input [3:0] x);
        begin
            SBox = lfsr ^ x; 
        end
    endfunction

    function [63:0] ApplySBox(input [63:0] x);
        integer j;
        reg [63:0] result;
        begin
            for (j = 0; j < 16; j = j + 1) begin
                result[j*4 +: 4] = SBox(x[j*4 +: 4]);
            end
            ApplySBox = result;
        end
    endfunction

    function [63:0] PBox(input [63:0] x);
        reg [63:0] result;
        integer j;
        begin
            for (j = 0; j < 64; j = j + 1) begin
                result[j] = x[(j * 17) % 64];
            end
            PBox = result;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ciphertext <= 64'h0;
        end else if (encrypt) begin
            state = plaintext;
            for (i = 0; i < ROUNDS; i = i + 1) begin
                state = ApplySBox(state);
                state = state ^ round_keys[i];
                state = PBox(state);
            end
            ciphertext <= state;
        end
    end
endmodule
