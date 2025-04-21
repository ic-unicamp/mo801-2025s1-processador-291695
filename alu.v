module alu(
    input [2:0] ALUctrl,
    input [31: 0] srcA, srcB,
    output reg [31:0] ALUOut,
    output Zero
    );

    assign Zero = (ALUOut == 0); // Zero eh 1 se ALUOut eh 0
    always @(ALUctrl, srcA, srcB) begin
        case (ALUctrl)
            3'b000: ALUOut = srcA & srcB; // and
            3'b001: ALUOut = srcA | srcB; // or
            3'b010: ALUOut = srcA + srcB; // add
            3'b110: ALUOut = srcA - srcB; // sub
            3'b111: ALUOut = srcA < srcB ? 1 : 0; // set less than
            // 12: ALUOut = ~(srcA | srcB); //nor
            default: ALUOut = 0;
        endcase
        $display("ALUCtrl: %b - SrcA: %b - Srcb: %b - ALUOut: %b", ALUctrl, srcA, srcB, ALUOut);
    end


endmodule