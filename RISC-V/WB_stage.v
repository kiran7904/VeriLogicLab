module WB_stage(
    input [31:0] mem_out,
    output reg [31:0] wb_data
);

always @(*) begin
    wb_data = mem_out;
end

endmodule
