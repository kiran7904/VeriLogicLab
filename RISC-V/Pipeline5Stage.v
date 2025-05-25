module Pipeline5Stage(
    input clk,
    input reset
);

reg [31:0] pc;
wire [31:0] instruction, pc_out;
wire [4:0] rs1, rs2, rd;
wire [31:0] imm, read_data1, read_data2, alu_result, mem_out, wb_data;

IF_stage IF(clk, reset, pc, pc_out, instruction);
ID_stage ID(clk, reset, instruction, rs1, rs2, rd, imm);
RegFile RF(clk, rs1, rs2, rd, wb_data, 1'b1, read_data1, read_data2);
EX_stage EX(read_data1, imm, alu_result);
MEM_stage MEM(alu_result, mem_out);
WB_stage WB(mem_out, wb_data);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 0;
    else
        pc <= pc_out;
end

endmodule
