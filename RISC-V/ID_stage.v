module ID_stage(
    input clk,
    input reset,
    input [31:0] instruction,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [31:0] imm
);

always @(*) begin
    rs1 = instruction[19:15];
    rs2 = instruction[24:20];
    rd  = instruction[11:7];
    imm = {{20{instruction[31]}}, instruction[31:20]}; // I-type immediate
end

endmodule
