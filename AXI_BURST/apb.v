module apb_slave (
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,

    input  wire [7:0]  PADDR,
    input  wire [31:0] PWDATA,

    output reg  [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR
);

    reg [31:0] registers [0:3];

    // This simple slave is always ready
    assign PREADY = 1'b1;

    // No errors in this simple example
    assign PSLVERR = 1'b0;

    always @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            registers[0] <= 32'b0;
            registers[1] <= 32'b0;
            registers[2] <= 32'b0;
            registers[3] <= 32'b0;

        end

        else begin

            // WRITE
            if (PSEL && PENABLE && PWRITE) begin

                case (PADDR)

                    8'h00:
                        registers[0] <= PWDATA;

                    8'h04:
                        registers[1] <= PWDATA;

                    8'h08:
                        registers[2] <= PWDATA;

                    8'h0C:
                        registers[3] <= PWDATA;

                endcase

            end

        end

    end


    // READ
    always @(*) begin

        PRDATA = 32'b0;

        if (PSEL && PENABLE && !PWRITE) begin

            case (PADDR)

                8'h00:
                    PRDATA = registers[0];

                8'h04:
                    PRDATA = registers[1];

                8'h08:
                    PRDATA = registers[2];

                8'h0C:
                    PRDATA = registers[3];

                default:
                    PRDATA = 32'b0;

            endcase

        end

    end

endmodule
