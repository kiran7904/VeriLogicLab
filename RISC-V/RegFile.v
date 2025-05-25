module RegFile(
    input clk,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output [31:0] read_data1,
    output [31:0] read_data2
);

reg [31:0] regs[0:31];

initial begin
    for (int i = 0; i < 32; i = i + 1)
        regs[i] = 32'd0;
end

assign read_data1 = regs[rs1];
assign read_data2 = regs[rs2];

always @(posedge clk) begin
    if (reg_write && rd != 0)
        regs[rd] <= write_data;
end

endmodule
