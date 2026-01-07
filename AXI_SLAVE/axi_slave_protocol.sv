
`timescale 1ns / 1ps

module axi_slave_protocol #(
    parameter addr_width = 4,
    parameter data_width = 32
)(
    input  logic clk,
    input  logic rst_n,
    // Write Address Channel
    input  logic [addr_width-1:0] awaddr,
    input  logic awvalid,
    output logic awready,
    // Write Data Channel
    input  logic [data_width-1:0] wdata,
    input  logic [(data_width/8)-1:0] wstrb,
    input  logic wvalid,
    output logic wready,
    // Write Response Channel
    output logic bvalid,
    input  logic bready,
    output logic [1:0] bresp,
    // Read Address Channel
    input  logic [addr_width-1:0] araddr,
    input  logic arvalid,
    output logic arready,
    // Read Data Channel
    output logic [data_width-1:0] rdata,
    output logic rvalid,
    input  logic rready,
    output logic [1:0] rresp
);

    logic [data_width-1:0] regfile [0:3];
    logic aw_en;

    // --- Write Logic ---
    assign awready = ~bvalid; // Simple flow control
    assign wready  = awvalid && wvalid && ~bvalid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bvalid <= 0;
            bresp  <= 0;
            for (int i=0; i<4; i++) regfile[i] <= 0;
        end else begin
            if (awvalid && wvalid && !bvalid) begin
                if (awaddr[3:2] < 4) begin
                    for (int i=0; i<data_width/8; i++) begin
                        if (wstrb[i]) regfile[awaddr[3:2]][8*i +: 8] <= wdata[8*i +: 8];
                    end
                    bresp <= 2'b00; // OKAY
                end else begin
                    bresp <= 2'b10; // SLVERR
                end
                bvalid <= 1;
            end else if (bvalid && bready) begin
                bvalid <= 0;
            end
        end
    end

    // --- Read Logic ---
    assign arready = ~rvalid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rvalid <= 0;
            rdata  <= 0;
            rresp  <= 0;
        end else begin
            if (arvalid && !rvalid) begin
                if (araddr[3:2] < 4) begin
                    rdata <= regfile[araddr[3:2]];
                    rresp <= 2'b00;
                end else begin
                    rdata <= 0;
                    rresp <= 2'b10;
                end
                rvalid <= 1;
            end else if (rvalid && rready) begin
                rvalid <= 0;
            end
        end
    end

endmodule
