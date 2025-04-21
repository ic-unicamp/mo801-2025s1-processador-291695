module instrRegister(
    input clk, resetn, en,
    input [31:0] inA, inB,
    output reg [31:0] outA, outB
    );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            outA = 31'b0;
            outB = 31'b0;
        end else if (en) begin
            outA = inA;
            outB = inB;
        end
    end
endmodule