module Pipeline5Stage(
    input clk,
    input reset,
    input [31:0] pc_in
);

reg [31:0] pc;
wire [31:0] pc_out, instruction;
wire [4:0] rs1, rs2, rd;
wire [31:0] imm, read_data1, read_data2;
wire [31:0] alu_result, mem_out, wb_data;

IF_stage IF(
    .clk(clk), .reset(reset),
    .pc_in(pc), .pc_out(pc_out),
    .instruction(instruction)
);

ID_stage ID(
    .instruction(instruction),
    .rs1(rs1), .rs2(rs2), .rd(rd), .imm(imm)
);

RegFile RF(
    .clk(clk),
    .rs1(rs1), .rs2(rs2), .rd(rd),
    .write_data(wb_data), .reg_write(1'b1),
    .read_data1(read_data1), .read_data2(read_data2)
);

EX_stage EX(
    .read_data1(read_data1), .imm(imm),
    .alu_result(alu_result)
);

MEM_stage MEM(
    .alu_result(alu_result),
    .mem_out(mem_out)
);

WB_stage WB(
    .mem_out(mem_out),
    .wb_data(wb_data)
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 0;
    else
        pc <= pc_out;
end

endmodule
