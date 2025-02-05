module advanced_traffic_light (
    input clk,
    input reset,
    input Sa, Sb,
    output reg Ra, Rb, Ga, Gb, Ya, Yb,
    input emergency_A, emergency_B,
    input pedestrian_A, pedestrian_B,
    input accident,
    input public_transport_A, public_transport_B
);
    reg [3:0] state, nextstate;
    reg [7:0] counter;
    reg flash_clk;
    reg [25:0] flash_counter;
    wire flash_clk_out = flash_counter[25];

    parameter [3:0] 
        GREEN_A     = 4'd1,
        YELLOW_A    = 4'd2,
        GREEN_B     = 4'd3,
        YELLOW_B    = 4'd4,
        ALL_RED     = 4'd5,
        EMERGENCY_A = 4'd6,
        EMERGENCY_B = 4'd7,
        PEDESTRIAN  = 4'd8;

    reg [7:0] green_a_time = 8'd50;
    reg [7:0] green_b_time = 8'd50;
    reg [7:0] ped_time = 8'd20;
    reg ped_request;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flash_counter <= 26'd0;
            flash_clk <= 1'b0;
        end else begin
            flash_counter <= flash_counter + 1;
            flash_clk <= flash_clk_out;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            green_a_time <= 8'd50;
            green_b_time <= 8'd50;
        end else begin
            if (Sa) green_a_time <= 8'd75;
            else green_a_time <= 8'd50;

            if (Sb) green_b_time <= 8'd75;
            else green_b_time <= 8'd50;

            if (public_transport_A) green_a_time <= green_a_time + 8'd25;
            if (public_transport_B) green_b_time <= green_b_time + 8'd25;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ped_request <= 1'b0;
        end else begin
            if (state != PEDESTRIAN)
                ped_request <= pedestrian_A | pedestrian_B;
            else
                ped_request <= 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= GREEN_A;
            counter <= 8'd0;
            {Ga, Ya, Ra, Gb, Yb, Rb} <= 6'b000000;
        end else begin
            counter <= counter + 1;
            state <= nextstate;

            case (state)
                GREEN_A: begin
                    {Ga, Ya, Ra} <= 3'b100;
                    {Gb, Yb, Rb} <= 3'b001;
                    if (counter > green_a_time || ped_request)
                        nextstate <= YELLOW_A;
                end

                YELLOW_A: begin
                    {Ga, Ya, Ra} <= 3'b010;
                    {Gb, Yb, Rb} <= 3'b001;
                    if (counter > 8'd10) begin
                        nextstate <= ped_request ? PEDESTRIAN : GREEN_B;
                        counter <= 8'd0;
                    end
                end

                GREEN_B: begin
                    {Gb, Yb, Rb} <= 3'b100;
                    {Ga, Ya, Ra} <= 3'b001;
                    if (counter > green_b_time || ped_request)
                        nextstate <= YELLOW_B;
                end

                YELLOW_B: begin
                    {Gb, Yb, Rb} <= 3'b010;
                    {Ga, Ya, Ra} <= 3'b001;
                    if (counter > 8'd10) begin
                        nextstate <= ped_request ? PEDESTRIAN : GREEN_A;
                        counter <= 8'd0;
                    end
                end

                PEDESTRIAN: begin
                    {Ga, Ya, Gb, Yb} <= 4'b0000;
                    {Ra, Rb} <= 2'b11;
                    if (counter > ped_time) begin
                        nextstate <= GREEN_A;
                        counter <= 8'd0;
                    end
                end

                ALL_RED: begin
                    {Ga, Ya, Ra, Gb, Yb, Rb} <= 6'b001001;
                    if (counter > 8'd10) begin
                        nextstate <= GREEN_A;
                        counter <= 8'd0;
                    end
                end

                EMERGENCY_A: begin
                    {Ga, Ya, Ra} <= 3'b100;
                    {Gb, Yb, Rb} <= 3'b001;
                    if (!emergency_A) nextstate <= GREEN_A;
                end

                EMERGENCY_B: begin
                    {Gb, Yb, Rb} <= 3'b100;
                    {Ga, Ya, Ra} <= 3'b001;
                    if (!emergency_B) nextstate <= GREEN_A;
                end

                default: nextstate <= GREEN_A;
            endcase
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {Ga, Ya, Ra, Gb, Yb, Rb} <= 6'b000000;
        end else begin
            if (accident) begin
                Ra <= flash_clk;
                Rb <= flash_clk;
                {Ga, Ya, Gb, Yb} <= 4'b0000;
                state <= ALL_RED;
                counter <= 8'd0;
            end else if (emergency_A) begin
                state <= EMERGENCY_A;
            end else if (emergency_B) begin
                state <= EMERGENCY_B;
            end
        end
    end
endmodule
