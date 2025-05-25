module EX_stage(
    input [31:0] read_data1,
    input [31:0] imm,
    output reg [31:0] alu_result
);

always @(*) begin
    alu_result = read_data1 + imm; // Only addi for demo
end

endmodule
