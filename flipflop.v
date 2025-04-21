module flipflop(
    input clk, en, resetn,
    input [31:0] in,
    output reg [31:0] out
);

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            out = 31'b0;
        end else if (en) begin
            out = in;
        end
    end
endmodule