module traffic_light_tb;

    reg clk;
    reg sensorA;
    reg sensorB;
    wire redLightA;
    wire redLightB;
    wire greenLightA;
    wire greenLightB;
    wire yellowLightA;
    wire yellowLightB;

    traffic_light uut (
        .clk(clk),
        .sensorA(sensorA),
        .sensorB(sensorB),
        .redLightA(redLightA),
        .redLightB(redLightB),
        .greenLightA(greenLightA),
        .greenLightB(greenLightB),
        .yellowLightA(yellowLightA),
        .yellowLightB(yellowLightB)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        sensorA = 0;
        sensorB = 0;

        #10 sensorA = 1;
        #50 sensorA = 0;

        #10 sensorB = 1;
        #50 sensorB = 0;

        #100 $finish;
    end

    initial begin
        $monitor("At time %t, redLightA = %d, greenLightA = %d, yellowLightA = %d, redLightB = %d, greenLightB = %d, yellowLightB = %d",
                 $time, redLightA, greenLightA, yellowLightA, redLightB, greenLightB, yellowLightB);
    end

endmodule
