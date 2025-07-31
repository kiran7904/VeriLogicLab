module apb3_slave #(
    parameter DATA_WIDTH = 32,
    parameter REG_NUM = 4
)(
    input wire PCLK,
    input wire PRESETn,
    input wire [7:0] PADDR,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [DATA_WIDTH-1:0] PWDATA,
    output reg [DATA_WIDTH-1:0] PRDATA,
    output reg PREADY,
    output reg PSLVERR
);

    reg [DATA_WIDTH-1:0] regs [0:REG_NUM-1];
    wire [$clog2(REG_NUM)-1:0] addr_index;
    assign addr_index = PADDR[($clog2(REG_NUM)+1):2];

    integer i;
    reg busy;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < REG_NUM; i = i + 1)
                regs[i] <= {DATA_WIDTH{1'b0}};
            PRDATA <= {DATA_WIDTH{1'b0}};
            PREADY <= 1'b1;
            PSLVERR <= 1'b0;
            busy <= 1'b0;
        end else begin
            PSLVERR <= 1'b0;
            if (!busy) begin
                PREADY <= 1'b1;
                if (PSEL && PENABLE) begin
                    if (addr_index < REG_NUM) begin
                        if (PWRITE) begin
                            regs[addr_index] <= PWDATA;
                            PREADY <= 1'b0;
                            busy <= 1'b1;
                        end else begin
                            PRDATA <= regs[addr_index];
                            PREADY <= 1'b1;
                        end
                    end else begin
                        PSLVERR <= 1'b1;
                        PRDATA <= {DATA_WIDTH{1'b0}};
                    end
                end
            end else begin
                PREADY <= 1'b1;
                busy <= 1'b0;
            end
        end
    end

endmodule
