module traffic_light (
    input clk,
    input sensorA,
    input sensorB,
    output reg redLightA,
    output reg redLightB,
    output reg greenLightA,
    output reg greenLightB,
    output reg yellowLightA,
    output reg yellowLightB
);

reg [3:0] currentState;
reg [3:0] nextState;

initial begin
    currentState = 0;
end

always @(currentState or sensorA or sensorB) begin
    redLightA = 0;
    redLightB = 0;
    greenLightA = 0;
    greenLightB = 0;
    yellowLightA = 0;
    yellowLightB = 0;
    nextState = 0;

    case (currentState)
        0, 1, 2, 3, 4: begin
            greenLightA = 1;
            redLightB = 1;
            nextState = currentState + 1;
        end
        5: begin
            greenLightA = 1;
            redLightB = 1;
            if (sensorB == 1) begin
                nextState = 6;
            end else begin
                nextState = 5;
            end 
        end
        6: begin
            yellowLightA = 1;
            redLightB = 1;
            nextState = 7;
        end
        7, 8, 9, 10: begin
            redLightA = 1;
            greenLightB = 1;
            nextState = currentState + 1;
        end
        11: begin
            redLightA = 1;
            greenLightB = 1;
            if (sensorA == 1 || sensorB == 0) begin
                nextState = 12;
            end else begin
                nextState = 11;
            end 
        end
        12: begin
            redLightA = 1;
            yellowLightB = 1;
            nextState = 0;
        end
    endcase
end

always @(posedge clk) begin
    currentState <= nextState;
end

endmodule
