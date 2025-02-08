module basic_elevator_control (
    input clk,
    input reset,
    input [1:0] floor_request,   
    input [1:0] current_floor,   
    output reg motor_up,         
    output reg motor_down,       
    output reg door_open        
);
    parameter IDLE = 2'b00;
    parameter MOVING_UP = 2'b01;
    parameter MOVING_DOWN = 2'b10;
    parameter DOOR_OPEN = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            motor_up <= 0;
            motor_down <= 0;
            door_open <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                motor_up = 0;
                motor_down = 0;
                door_open = 0;

                // Check for floor requests
                if (floor_request > current_floor) begin
                    next_state = MOVING_UP;
                end else if (floor_request < current_floor) begin
                    next_state = MOVING_DOWN;
                end else begin
                    next_state = DOOR_OPEN;  
                end
            end

            MOVING_UP: begin
                motor_up = 1;
                motor_down = 0;
                door_open = 0;

                if (current_floor == floor_request) begin
                    next_state = DOOR_OPEN;
                end else begin
                    next_state = MOVING_UP;
                end
            end

            MOVING_DOWN: begin
                motor_up = 0;
                motor_down = 1;
                door_open = 0;

                if (current_floor == floor_request) begin
                    next_state = DOOR_OPEN;
                end else begin
                    next_state = MOVING_DOWN;
                end
            end

            DOOR_OPEN: begin
                motor_up = 0;
                motor_down = 0;
                door_open = 1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
