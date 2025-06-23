module EX_stage(
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] imm,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [31:0] alu_result
);

always @(*) begin
    case (opcode)
        7'b0010011: begin 
            alu_result = read_data1 + imm;
        end

        7'b0110011: begin  // R-type
            case ({funct7, funct3})
                10'b0000000000: alu_result = read_data1 + read_data2; // ADD
                10'b0100000000: alu_result = read_data1 - read_data2; // SUB
                10'b0000000111: alu_result = read_data1 & read_data2; // AND
                10'b0000000110: alu_result = read_data1 | read_data2; // OR
                10'b0000000001: alu_result = read_data1 << read_data2[4:0]; // SLL
                default:        alu_result = 32'b0; 
            endcase
        end

        default: begin
            alu_result = 32'b0; 
        end
    endcase
end

endmodule
