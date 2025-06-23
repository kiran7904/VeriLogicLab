module ID_stage(
    input clk,
    input reset,
    input [31:0] instruction,
    output reg [4:0] rs1, rs2, rd,
    output reg [31:0] reg_data1,
    output reg [31:0] reg_data2,
    output reg [31:0] imm_out,
    output reg [6:0] opcode,
    output reg [2:0] funct3,
    output reg [6:0] funct7
);

reg [31:0] registers [0:31];

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 0;
end

always @(*) begin
    opcode  = instruction[6:0];
    rd      = instruction[11:7];
    funct3  = instruction[14:12];
    rs1     = instruction[19:15];
    rs2     = instruction[24:20];
    funct7  = instruction[31:25];

    reg_data1 = registers[rs1];
    reg_data2 = registers[rs2];

    imm_out = {{20{instruction[31]}}, instruction[31:20]};
end

always @(posedge clk) begin
    if (reset)
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 0;
end

endmodule
