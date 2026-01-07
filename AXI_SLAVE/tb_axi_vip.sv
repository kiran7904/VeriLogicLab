// Code your testbench here
// or browse Examples
module tb_axi_vip;
    logic clk, rst_n;
    logic [3:0] awaddr, araddr;
    logic awvalid, awready, wvalid, wready, arvalid, arready;
    logic [31:0] wdata, rdata;
    logic [3:0] wstrb;
    logic bvalid, bready, rvalid, rready;
    logic [1:0] bresp, rresp;

    // Instantiate Slave
    axi_slave_protocol dut (.*);

    // Clock Gen
    initial clk = 0;
    always #5 clk = ~clk;

    // --- MASTER VIP TASKS ---
    task axi_write(input [3:0] addr, input [31:0] data);
        awaddr  <= addr;
        awvalid <= 1;
        wdata   <= data;
        wvalid  <= 1;
        wstrb   <= 4'hf;
        wait (awready && wready);
        @(posedge clk);
        awvalid <= 0;
        wvalid  <= 0;
        bready  <= 1;
        wait (bvalid);
        @(posedge clk);
        bready  <= 0;
        $display("[VIP WRITE] Addr: %h, Data: %h, Resp: %b", addr, data, bresp);
    endtask

    task axi_read(input [3:0] addr);
        araddr  <= addr;
        arvalid <= 1;
        wait (arready);
        @(posedge clk);
        arvalid <= 0;
        rready  <= 1;
        wait (rvalid);
        @(posedge clk);
        rready  <= 0;
        $display("[VIP READ] Addr: %h, Data: %h, Resp: %b", addr, rdata, rresp);
    endtask

    // --- PROTOCOL ASSERTIONS (The "Checker" part of VIP) ---
    property p_valid_until_ready(vld, rdy);
        @(posedge clk) vld && !rdy |=> vld;
    endproperty

    assert property (p_valid_until_ready(awvalid, awready)) else $error("AWVALID dropped before AWREADY!");
    assert property (p_valid_until_ready(wvalid, wready)) else $error("WVALID dropped before WREADY!");

    // --- Main Test ---
    initial begin
        rst_n = 0; bready = 0; rready = 0;
        #20 rst_n = 1;
        
        // Test 1: Standard Write/Read
        axi_write(4'h0, 32'hDEADBEEF);
        axi_read(4'h0);

        // Test 2: Error Response (Out of range address)
        axi_write(4'hC, 32'hCAFEBABE); // Index 3 is max, 4'hC is Index 4
        
        #100 $finish;
    end
endmodule
