// ============================================================================
// MODERATE APB4 SLAVE – 4 Registers + Wait States + Error Response
// ============================================================================
// Q: What are the three APB transfer phases?
// A: IDLE (PSEL=0), SETUP (PSEL=1, PENABLE=0), ACCESS (PSEL=1, PENABLE=1)
//
// Q: What is the minimum number of cycles per transfer?
// A: 2 cycles (1 SETUP + 1 ACCESS). Wait states add more.
//
// Q: APB4 additions over APB3?
// A: PREADY (wait states), PSLVERR (error response), PSTRB (byte strobes)
// ============================================================================

module apb_slave_moderate (
    input  wire        PCLK,
    input  wire        PRESETn,      // Active LOW
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [7:0]  PADDR,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output reg         PREADY,
    output reg         PSLVERR
);

    // ============================================================================
    // Phase Detection
    // ============================================================================
    // Q: Why differentiate SETUP vs ACCESS?
    // A: SETUP presents address/control; ACCESS actually performs the transfer.
    wire setup_phase  = PSEL && !PENABLE;
    wire access_phase = PSEL && PENABLE;

    // ============================================================================
    // Address Decoding (4 registers → use 2 LSBs of address)
    // ============================================================================
    // Q: How does slave know which register is being accessed?
    // A: Decodes lower address bits. Upper bits are used by the bridge to generate PSEL.
    wire [1:0] reg_addr = PADDR[3:2];   // 4 word-aligned registers

    localparam [1:0] REG_CTRL    = 2'b00;  // Read/Write
    localparam [1:0] REG_STATUS  = 2'b01;  // Read-Only
    localparam [1:0] REG_TIMER   = 2'b10;  // Read/Write (with wait states)
    localparam [1:0] REG_SCRATCH = 2'b11;  // Write-Only

    // ============================================================================
    // Wait States on TIMER Register Writes (APB4 Feature)
    // ============================================================================
    // Q: How does a slave delay the ACCESS phase?
    // A: Deassert PREADY. Bridge holds PSEL=1, PENABLE=1 until PREADY=1.
    reg [1:0] wait_cnt;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            wait_cnt <= 2'b00;
        end else if (setup_phase && PWRITE && (reg_addr == REG_TIMER)) begin
            wait_cnt <= 2'b11;                  // Request 3 extra wait cycles
        end else if (access_phase && (|wait_cnt)) begin
            wait_cnt <= wait_cnt - 1'b1;        // Count down in ACCESS phase
        end
    end

    // Q: When is PREADY = 1?
    // A: ACCESS phase AND no active wait counter.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            PREADY <= 1'b0;
        else
            PREADY <= access_phase && (wait_cnt == 2'b00);
    end

    // ============================================================================
    // Valid Transfer Condition
    // ============================================================================
    // Q: When does the actual data transfer happen?
    // A: ACCESS phase + PREADY=1 + no error.
    wire write_valid = access_phase &&  PWRITE && PREADY && !PSLVERR;
    wire read_valid  = access_phase && !PWRITE && PREADY && !PSLVERR;

    // ============================================================================
    // Internal Registers
    // ============================================================================
    reg [31:0] ctrl_reg, timer_reg, scratch_reg;
    reg [31:0] status_reg;  // Read-Only: driven by internal logic

    // Write operations
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ctrl_reg    <= 32'h0;
            timer_reg   <= 32'h0;
            scratch_reg <= 32'h0;
        end else begin
            // Q: Why use write_valid instead of just PSEL && PENABLE?
            // A: Ensures writes happen exactly once when transfer completes,
            //    not on every wait-state cycle.
            if (write_valid) begin
                case (reg_addr)
                    REG_CTRL:    ctrl_reg    <= PWDATA;
                    REG_TIMER:   timer_reg   <= PWDATA;
                    REG_SCRATCH: scratch_reg <= PWDATA;
                    // REG_STATUS is RO → no write; handled by error logic
                endcase
            end
        end
    end

    // Status register (RO – updated by internal events, not by APB writes)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            status_reg <= 32'h0;
        end else begin
            status_reg[0] <= (timer_reg != 32'h0);  // e.g., timer running flag
        end
    end

    // ============================================================================
    // Read Operation
    // ============================================================================
    // Q: Why register PRDATA?
    // A: Better timing closure. Combinatorial reads create long paths.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 32'h0;
        end else if (read_valid) begin
            case (reg_addr)
                REG_CTRL:    PRDATA <= ctrl_reg;
                REG_STATUS:  PRDATA <= status_reg;
                REG_TIMER:   PRDATA <= timer_reg;
                REG_SCRATCH: PRDATA <= 32'h0;   // WO: read returns 0
                default:     PRDATA <= 32'h0;
            endcase
        end
    end

    // ============================================================================
    // Error Handling – PSLVERR (APB4 Feature)
    // ============================================================================
    // Q: What triggers PSLVERR in this slave?
    // A: - Write to Read-Only register (STATUS)
    //    - Read from Write-Only register (SCRATCH)
    //    - Access to unimplemented address
    wire invalid_addr    = (reg_addr > REG_SCRATCH);
    wire write_to_ro     = write_valid && (reg_addr == REG_STATUS);
    wire read_from_wo    = read_valid  && (reg_addr == REG_SCRATCH);
    wire error_condition = write_to_ro || read_from_wo || invalid_addr;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSLVERR <= 1'b0;
        end else if (access_phase && PREADY) begin
            // Q: Should PSLVERR be pulsed or held?
            // A: Typically asserted only in the completing ACCESS cycle.
            PSLVERR <= error_condition;
        end else begin
            PSLVERR <= 1'b0;
        end
    end

endmodule
