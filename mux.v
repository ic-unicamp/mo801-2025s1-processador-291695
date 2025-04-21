module mux2to1(
    input sel, 
    input [31:0] inA, inB, 
    output [31:0] out
    );
    
    assign out = (sel) ? inB : inA;

endmodule

module mux3to1(
    input [1:0] sel,
    input [31:0] inA, inB, inC, 
    output [31:0] out
    );

    wire [31:0] inD;

    assign out = (sel == 2'b00) ? inA : (sel == 2'b01) ? inB : (sel == 2'b10) ? inC : inD;

endmodule