module tb_seq_1010;

    logic clk;
    logic reset;
    logic din;
    logic dout;

    seq_1010 s1 (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(dout)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        din = 0;
        #10;

        reset = 0;

        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 0; #10;

        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 1; #10;

        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 0; #10;

        din = 0; #10;
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | din=%b | dout=%b", $time, din, dout);
    end

endmodule
