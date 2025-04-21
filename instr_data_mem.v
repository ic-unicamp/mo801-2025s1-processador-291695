module instrDataMem(
    input clk, resetn, en,
    input [31:0] inA, inB,
    output reg [31:0] out
    );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            out = 31'b0;
        end else if (en) begin
            out = inB;
        end else begin
            out = inA;
        end
    end
endmodule