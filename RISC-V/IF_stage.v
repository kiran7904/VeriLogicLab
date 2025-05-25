module IF_stage(
    input clk,
    input reset,
    input [31:0] pc_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction
);

reg [31:0] instr_mem [0:15];

initial begin
    instr_mem[0] = 32'h00000013;
    instr_mem[1] = 32'h00100093;
    instr_mem[2] = 32'h00200113;
    instr_mem[3] = 32'h00308193;
    instr_mem[4] = 32'h00410213;
    instr_mem[5] = 32'h00000013;
    instr_mem[6] = 32'h00000013;
    instr_mem[7] = 32'h00000013;
    instr_mem[8] = 32'h00000013;
    instr_mem[9] = 32'h00000013;
    instr_mem[10] = 32'h00000013;
    instr_mem[11] = 32'h00000013;
    instr_mem[12] = 32'h00000013;
    instr_mem[13] = 32'h00000013;
    instr_mem[14] = 32'h00000013;
    instr_mem[15] = 32'h00000013;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 0;
        instruction <= 0;
    end else begin
        instruction <= instr_mem[pc_in[5:2]];
        pc_out <= pc_in + 4;
    end
end

endmodule
