module registerFile(
    input en, clk, resetn,
    input [4:0] inA, inB, inC, // rs1, rs2, rd
    input [31:0] inD, // wd3
    output [31:0] out1, out2
    );

    reg [31:0] regs [31:0]; // banco de registradores

    assign out1 = regs[inA];
    assign out2 = regs[inB];

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            regs[0] = 32'b0;
        end else if (en) begin
            regs[inC] = inD;
        end
        $display("RegWrite: %b - regs: %b", en, regs[inC]);
    end

endmodule