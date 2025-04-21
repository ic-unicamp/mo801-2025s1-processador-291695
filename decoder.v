module instrDecoder(
    input [31:0] in,
    output [4:0] rs1, rs2, rd,
    output [2:0] funct3,
    output funct7,
    output [6:0] opcode
    );

    assign opcode = in[6:0];
    assign funct7 = in[30];
    assign rs2 = in[24:20];
    assign rs1 = in[19:15];
    assign funct3 = in[14:12];
    assign rd = in[11:7];

endmodule