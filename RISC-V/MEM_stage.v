module MEM_stage(
    input [31:0] alu_result,
    output reg [31:0] mem_out
);

// No real memory used here, just pass through
always @(*) begin
    mem_out = alu_result;
end

endmodule
