// ============================================================================
// BASIC APB SLAVE - Single Read/Write Register
// ============================================================================
// Q: What is APB?
// A: APB is a low-power, non-pipelined bus for low-bandwidth peripherals.
//    It always takes at least 2 cycles per transfer (Setup + Access).
//
// Q: How many phases in an APB transfer?
// A: 3 phases - IDLE, SETUP, ACCESS. SETUP=1 cycle, ACCESS=1 cycle.
//    This gives minimum 2-cycle latency for any transfer.
//
// Q: Is pipelining supported in APB?
// A: No. The next transfer starts only after the current one completes.
//
// Q: What’s the minimum number of cycles for an APB read/write?
// A: 2 cycles with zero wait states (no PREADY handshake in APB3).
//    If using APB4 with PREADY, it can be more.
// ============================================================================

module apb_slave_basic (
    // APB Interface Signals
    // Q: What are the mandatory APB signals?
    // A: PCLK, PRESETn, PADDR, PSEL, PENABLE, PWDATA, PWRITE, PRDATA.
    //    For APB4: PREADY, PSLVERR are added.
    input   wire        PCLK,       // Q: Who generates PCLK? A: Bridge/Clock module
    input   wire        PRESETn,    // Q: Active level? A: Active LOW
    input   wire        PSEL,       // Q: What does PSEL do? A: Selects a specific slave
    input   wire        PENABLE,    // Q: When is PENABLE high? A: 2nd cycle (ACCESS phase)
    input   wire        PWRITE,     // Q: HIGH=Write, LOW=Read
    input   wire [7:0]  PADDR,      // Q: Address width? A: Can be up to 32 bits
    input   wire [31:0] PWDATA,     // Q: Write data - when is it valid? A: During ACCESS phase with PWRITE=1
    output  reg  [31:0] PRDATA,     // Q: Read data - when must it be valid? A: During ACCESS phase with PWRITE=0
    output  reg         PREADY,     // APB4: Q: Purpose of PREADY? A: Slave can extend ACCESS phase (wait states)
    output  reg         PSLVERR     // APB4: Q: Purpose of PSLVERR? A: Indicate transfer failure
);

    // Internal Register
    reg [31:0] apb_reg;

    // ============================================================================
    // Write Logic
    // ============================================================================
    // Q: When does APB write happen?
    // A: PSEL=1, PENABLE=1, PWRITE=1 on a rising clock edge.
    //
    // Q: Why check PENABLE?
    // A: PSEL alone is not enough. PSEL is also high during SETUP phase.
    //    We must write only in ACCESS phase (PENABLE=1) to avoid spurious writes.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            apb_reg <= 32'h0;
        end else if (PSEL && PENABLE && PWRITE) begin
            apb_reg <= PWDATA;
        end
    end

    // ============================================================================
    // Read Logic
    // ============================================================================
    // Q: When does APB read happen?
    // A: PSEL=1, PENABLE=1, PWRITE=0 → slave must drive PRDATA combinatorially
    //    or registered (registered here is safer for timing).
    //
    // Q: Can read be asynchronous/combinatorial?
    // A: APB spec allows PRDATA to be combinatorial, but registered is preferred
    //    in modern designs for timing closure.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 32'h0;
        end else if (PSEL && PENABLE && !PWRITE) begin
            PRDATA <= apb_reg;
        end
    end

    // ============================================================================
    // PREADY (APB4) – Wait State Insertion
    // ============================================================================
    // Q: What if slave needs more than 2 cycles?
    // A: In APB4, slave can deassert PREADY to keep PENABLE high and wait.
    //    Here we just drive PREADY=1 (ready in ACCESS phase), no wait states.
    //
    // Q: What does PREADY=0 do?
    // A: Master stalls – holds PSEL=1, PENABLE=1, address/control stable.
    //    Transfer completes on the first cycle where PREADY=1.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY <= 1'b0;
        end else begin
            PREADY <= PSEL && PENABLE;  // Ready only in ACCESS phase
        end
    end

    // ============================================================================
    // PSLVERR (APB4) – Error Signaling
    // ============================================================================
    // Q: When would a slave assert PSLVERR?
    // A: Invalid address, write to read-only register, clock domain crossing failure.
    //    Here we simply never assert error.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSLVERR <= 1'b0;
        end else begin
            PSLVERR <= 1'b0;  // No errors in this simple slave
        end
    end

endmodule
