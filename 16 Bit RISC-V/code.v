module pipeline_cpu (
    input wire clk,
    input wire rst,
    output reg [15:0] regfile_out [0:15]
);

    reg [15:0] instr_mem [0:15];
    reg [15:0] instr_reg;
    reg [3:0] opcode, rs1, rs2, rd;
    reg [15:0] regfile [0:15];
    reg [15:0] alu_out;
    integer pc;

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND_ = 4'b0010;
    localparam OR_  = 4'b0011;
    localparam XOR_ = 4'b0100;
    localparam MUL  = 4'b0101;
    localparam DIV  = 4'b0110;
    localparam MOV  = 4'b0111;
    localparam LDI  = 4'b1000;
    localparam SHL  = 4'b1001;
    localparam SHR  = 4'b1010;
    localparam NOP  = 4'b1111;

    initial begin
        instr_mem[0]  = {ADD, 4'd2, 4'd3, 4'd1};
        instr_mem[1]  = {SUB, 4'd5, 4'd6, 4'd4};
        instr_mem[2]  = {ADD, 4'd1, 4'd4, 4'd7};
        instr_mem[3]  = {AND_, 4'd2, 4'd3, 4'd8};
        instr_mem[4]  = {OR_, 4'd5, 4'd6, 4'd9};
        instr_mem[5]  = {XOR_, 4'd4, 4'd7, 4'd10};
        instr_mem[6]  = {MUL, 4'd2, 4'd3, 4'd11};
        instr_mem[7]  = {DIV, 4'd5, 4'd2, 4'd12};
        instr_mem[8]  = {SHL, 4'd11, 4'd2, 4'd13};
        instr_mem[9]  = {SHR, 4'd12, 4'd1, 4'd14};
        instr_mem[10] = {MOV, 4'd3, 4'd0, 4'd15};
        instr_mem[11] = {NOP, 4'd0, 4'd0, 4'd0};
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_reg <= 0;
            opcode <= 0;
            rs1 <= 0;
            rs2 <= 0;
            rd  <= 0;
            alu_out <= 0;
            pc <= 0;
            for (integer i = 0; i < 16; i = i + 1)
                regfile[i] <= i;
        end else begin
            instr_reg <= instr_mem[pc];
            pc <= pc + 1;

            opcode <= instr_reg[15:12];
            rs1    <= instr_reg[11:8];
            rs2    <= instr_reg[7:4];
            rd     <= instr_reg[3:0];

            case (opcode)
                ADD:  alu_out <= regfile[rs1] + regfile[rs2];
                SUB:  alu_out <= regfile[rs1] - regfile[rs2];
                AND_: alu_out <= regfile[rs1] & regfile[rs2];
                OR_:  alu_out <= regfile[rs1] | regfile[rs2];
                XOR_: alu_out <= regfile[rs1] ^ regfile[rs2];
                MUL:  alu_out <= regfile[rs1] * regfile[rs2];
                DIV:  alu_out <= (regfile[rs2] != 0) ? regfile[rs1] / regfile[rs2] : 0;
                MOV:  alu_out <= regfile[rs1];
                SHL:  alu_out <= regfile[rs1] << regfile[rs2][3:0];
                SHR:  alu_out <= regfile[rs1] >> regfile[rs2][3:0];
                LDI:  alu_out <= {12'd0, instr_reg[3:0]};
                default: alu_out <= 0;
            endcase

            if (opcode != NOP)
                regfile[rd] <= alu_out;
        end
    end

    always @(*) begin
        for (int i = 0; i < 16; i = i + 1)
            regfile_out[i] = regfile[i];
    end

endmodule

`timescale 1ns/1ps
module tb_pipeline_cpu;

    reg clk, rst;
    wire [15:0] regfile_out [0:15];

    pipeline_cpu dut (
        .clk(clk),
        .rst(rst),
        .regfile_out(regfile_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting pipeline CPU test...");
        rst = 1;
        #10 rst = 0;
        #200;
        $display("\nFinal Register File State:");
        for (int i = 0; i < 16; i = i + 1)
            $display("regfile[%0d] = %0d", i, regfile_out[i]);
        $finish;
    end

endmodule
