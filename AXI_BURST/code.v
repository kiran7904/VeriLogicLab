module axi_master_with_source (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start_write,
    
    // AXI Write Address Channel (AW)
    output reg  [31:0] awaddr,
    output reg  [7:0]  awlen,
    output reg  [2:0]  awsize,
    output reg  [1:0]  awburst,
    output reg         awvalid,
    input  wire        awready,
    
    // AXI Write Data Channel (W)
    output reg  [31:0] wdata,
    output reg  [3:0]  wstrb,
    output reg         wlast,
    output reg         wvalid,
    input  wire        wready
);

    // =========================================================================
    // THE INTERNAL SOURCE (Where the master fetches data from)
    // =========================================================================
    // In a real chip, this would be a RAM or a FIFO. 
    // Here, we hardcode an internal "source configuration" for illustration.
    reg [31:0] internal_target_address;
    reg [31:0] internal_data_buffer [0:3]; // A small array holding 4 pieces of data

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            internal_target_address <= 32'h0000_1000; // Destination in system memory
            internal_data_buffer[0] <= 32'hAA_BB_CC_DD; // Data we want to send
            internal_data_buffer[1] <= 32'h11_22_33_44;
            internal_data_buffer[2] <= 32'h55_66_77_88;
            internal_data_buffer[3] <= 32'h99_00_11_22;
        end
    end
    // =========================================================================

    // State Machine
    localparam reg [1:0] 
        IDLE  = 2'b00,
        ADDR  = 2'b01,
        DATA  = 2'b10;
        
    reg [1:0] state;
    reg [1:0] beat_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            awaddr   <= 32'h0;
            awlen    <= 8'h0;
            awsize   <= 3'b000;
            awburst  <= 2'b00;
            awvalid  <= 1'b0;
            wdata    <= 32'h0;
            wstrb    <= 4'b0000;
            wlast    <= 1'b0;
            wvalid   <= 1'b0;
            beat_cnt <= 2'b00;
        end else begin
            case (state)
                
                IDLE: begin
                    if (start_write) begin
                        // FETCH: Grabbing the destination address from our internal register
                        awaddr  <= internal_target_address; 
                        
                        awlen   <= 8'd3;       // 4 beats number of beats=awlen+1 to sove 1 extra bit 
                        awsize  <= 3'b010;     // 4 bytes per beat 2^2=4
                        awburst <= 2'b01;      // INCR burst
                        awvalid <= 1'b1;
                        state   <= ADDR;
                    end
                end

                ADDR: begin
                    if (awvalid && awready) begin
                        awvalid <= 1'b0;       
                        wvalid  <= 1'b1;       
                        state   <= DATA;
                        beat_cnt<= 2'b00;
                        
                        // FETCH FIRST BEAT: Read from internal buffer index 0
                        wdata   <= internal_data_buffer[0];
                        wstrb   <= 4'b1111;    
                        wlast   <= 1'b0;
                    end
                end

                DATA: begin
                    if (wvalid && wready) begin
                        case (beat_cnt)
                            2'b00: begin
                                // FETCH SECOND BEAT: Read from internal buffer index 1
                                wdata    <= internal_data_buffer[1];
                                wstrb    <= 4'b0001; 
                                wlast    <= 1'b0;
                                beat_cnt <= 2'b01;
                            end
                            
                            2'b01: begin
                                // FETCH THIRD BEAT: Read from internal buffer index 2
                                wdata    <= internal_data_buffer[2];
                                wstrb    <= 4'b1100; 
                                wlast    <= 1'b0;
                                beat_cnt <= 2'b10;
                            end
                            
                            2'b10: begin
                                // FETCH FOURTH BEAT: Read from internal buffer index 3
                                wdata    <= internal_data_buffer[3];
                                wstrb    <= 4'b0010; 
                                wlast    <= 1'b1;    // Last data item
                                beat_cnt <= 2'b11;
                            end
                            
                            2'b11: begin
                                wvalid   <= 1'b0;
                                wlast    <= 1'b0;
                                state    <= IDLE;
                            end
                        endcase
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
