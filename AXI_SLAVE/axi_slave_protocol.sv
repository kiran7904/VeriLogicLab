`timescale 1ns / 1ps

module axi_slave_protocol #(
    parameter addr_width = 4,
    parameter data_width = 32
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [addr_width-1:0] awaddr,
    input  logic awvalid,
    output logic awready,

    input  logic [data_width-1:0] wdata,
    input  logic [(data_width/8)-1:0] wstrb,
    input  logic wvalid,
    output logic wready,

    output logic bvalid,
    input  logic bready,
    output logic [1:0] bresp,

    input  logic [addr_width-1:0] araddr,
    input  logic arvalid,
    output logic arready,

    output logic [data_width-1:0] rdata,
    output logic rvalid,
    input  logic rready,
    output logic [1:0] rresp
);

    logic [data_width-1:0] regfile [0:3];

    logic aw_hs, w_hs, ar_hs;
    logic aw_pending, w_pending;
    logic [addr_width-1:0] awaddr_q;

    assign awready = !aw_pending;
    assign wready  = !w_pending;
    assign arready = !rvalid;

    assign aw_hs = awvalid && awready;
    assign w_hs  = wvalid  && wready;
    assign ar_hs = arvalid && arready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_pending <= 0;
            w_pending  <= 0;
            bvalid     <= 0;
            bresp      <= 0;
            rvalid     <= 0;
            rresp      <= 0;
            rdata      <= 0;
            awaddr_q   <= 0;
            for (int i = 0; i < 4; i++) regfile[i] <= 0;
        end else begin
            if (aw_hs) begin
                awaddr_q   <= awaddr;
                aw_pending <= 1;
            end

            if (w_hs) begin
                w_pending <= 1;
            end

            if (aw_pending && w_pending && !bvalid) begin
                if (awaddr_q[3:2] < 4) begin
                    for (int i = 0; i < data_width/8; i++)
                        if (wstrb[i])
                            regfile[awaddr_q[3:2]][8*i +: 8] <= wdata[8*i +: 8];
                    bresp <= 2'b00;
                end else begin
                    bresp <= 2'b10;
                end
                bvalid     <= 1;
                aw_pending <= 0;
                w_pending  <= 0;
            end

            if (bvalid && bready)
                bvalid <= 0;

            if (ar_hs) begin
                if (araddr[3:2] < 4) begin
                    rdata <= regfile[araddr[3:2]];
                    rresp <= 2'b00;
                end else begin
                    rdata <= 0;
                    rresp <= 2'b10;
                end
                rvalid <= 1;
            end

            if (rvalid && rready)
                rvalid <= 0;
        end
    end

endmodule
