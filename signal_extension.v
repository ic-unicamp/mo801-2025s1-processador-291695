module signalExtension(
    input [31:0] in,
    input [1:0] sel,
    output reg [31:0] out
    );

    // Definicao dos imediatos dependendo do tipo da instrucao
    localparam [1:0]
        I_L_TYPE = 2'b00,
        S_TYPE = 2'b01,
        B_TYPE = 2'b10,
        J_TYPE = 2'b11;

    always @(*) begin
        case (sel)
            J_TYPE:
                out = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0};
            B_TYPE:
                out = {{19{in[31]}}, in[31], in[7], in[30:25], in[11:8], 1'b0};
            S_TYPE:
                out = {{20{in[31]}}, in[31:25], in[11:7]};
            I_L_TYPE:
                out = {{20{in[31]}}, in[31:20]};
            default:
                out = 32'b0;
        endcase
        $display("Imediato: %b - in: %b - out: %b", sel, in, out);
    end

endmodule