module IF_stage(
    input clk,
    input reset,
    input [31:0] pc_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction
);

reg [31:0] instr_mem [0:15];

initial begin
    instr_mem[0] = 32'h00000013; // NOP
    instr_mem[1] = 32'h00100093; // addi x1, x0, 1
    instr_mem[2] = 32'h00200113; // addi x2, x0, 2
    instr_mem[3] = 32'h00308193; // addi x3, x1, 3
    instr_mem[4] = 32'h00410213; // addi x4, x2, 4
    // Fill rest with NOP
    for (int i = 5; i < 16; i = i + 1)
        instr_mem[i] = 32'h00000013;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 32'd0;
        instruction <= 32'd0;
    end else begin
        instruction <= instr_mem[pc_in[5:2]];
        pc_out <= pc_in + 4;
    end
end

endmodule
