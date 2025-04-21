module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);

always @(posedge clk) begin
  if (resetn == 1'b0) begin
    address = 32'h00000000;
  end 
  else begin
    address = PC;
  end
  we = MemWrite;
  data_out = DataOut;
end


always @(*) begin
  $display("data_in: %h | %b - data_out : %b - address: %b", data_in, data_in, data_out, address);
  $display("PCWrite: %b - AdrSrc: %b - MemWrite: %b - IRWrite: %b - RegWrite: %b - ResultSrc: %b - ALUSrcA: %b - ALUSrcB: %b - ALUCtrl: %b - ALUResult: %b - ALUOut: %b - Result: %b - PC: %b - OldPC: %b - Zero: %b - ReadData: %b", 
    PCWrite, AdrSrc, MemWrite, IRWrite, RegWrite, ResultSrc, ALUSrcA, ALUSrcB, ALUCtrl, ALUResult, ALUOut, Result, PC, OldPC, Zero, ReadData);
  $display("\n");
end

// ---------------------------------------------------
// Estagio de busca
// ---------------------------------------------------
wire [31:0] PC, Instr, OldPC, Data, Result, ResAddr, ReadData, DataOut;

  // Atualiza PC na subida do clk
  flipflop pc_register(
    .clk(clk), 
    .en(PCWrite), 
    .resetn(resetn), 
    .in(Result),
    .out(PC)
  );

  // Seleciona entre PC e resultado da ULA
  mux2to1 addr_selection(
    .sel(AdrSrc), 
    .inA(PC), 
    .inB(Result), 
    .out(ResAddr)
    );

  // Memoria de instrucao e dados: seleciona entre instrucao e dado - N
  instrDataMem instr_data_selecion (
    .clk(clk), 
    .resetn(resetn), 
    .en(MemWrite),
    .inA(ResAddr),
    .inB(DataOut),
    .out(ReadData)
    );

  // Registrador de instrucoes: seleciona entre PC e instrucao da memoria
  instrRegister instr_register(
    .clk(clk), 
    .resetn(resetn), 
    .en(IRWrite),
    .inA(PC), 
    .inB(data_in),
    .outA(OldPC),
    .outB(Instr)
    );

  // Registrador de dados
  flipflop data_register(
    .clk(clk), 
    .en(1'b1), 
    .resetn(resetn), 
    .in(ReadData),
    .out(Data)
  );

// ---------------------------------------------------
// Estagio de decodificacao
// ---------------------------------------------------
wire [31:0] ImmExt, Rd1, Rd2, Areg, Breg;
wire [6:0] Opcode;
wire [4:0] Rs2, Rs1, Rd;
wire [2:0] Funct3;
wire [1:0] ImmSrc;
wire Funct7;

  // Obtem todos os campos de registradores, opcode, funct3 e funct7
  instrDecoder instr_decoder(
    .in(Instr), //data_in
    .rs1(Rs1), 
    .rs2(Rs2), 
    .rd(Rd),
    .funct3(Funct3),
    .funct7(Funct7),
    .opcode(Opcode)
    ); 

  // Acessa banco de registradores
  registerFile regs_file(
    .en(RegWrite), 
    .clk(clk), 
    .resetn(resetn),
    .inA(Rs1), 
    .inB(Rs2), 
    .inC(Rd),
    .inD(Result),
    .out1(Rd1), 
    .out2(Rd2)
    );

  // Extensao de sinal para imediato
  signalExtension sign_extension(
    .in(Instr),
    .sel(ImmSrc),
    .out(ImmExt)
    );

  // Registrador para dado A
  flipflop a_register(
    .clk(clk), 
    .en(1'b1), 
    .resetn(resetn), 
    .in(Rd1), 
    .out(Areg)
  );

  // Registrador para dado B
  flipflop b_register(
    .clk(clk), 
    .en(1'b1), 
    .resetn(resetn), 
    .in(Rd2), 
    .out(DataOut)
  );
// ---------------------------------------------------
// Estagio de enderecamento de memoria
// ---------------------------------------------------
wire [31:0] ALUResult, src_A, src_B;
wire [1:0] ALUSrcA, ALUSrcB;

  // Seleciona a fonte para o dado A
  mux3to1 srcA_selection(
    .sel(ALUSrcA), 
    .inA(PC), 
    .inB(OldPC), 
    .inC(Areg), 
    .out(src_A)
    );

  // Seleciona a fonte para o dado B
  mux3to1 srcB_selection(
    .sel(ALUSrcB), 
    .inA(data_out), 
    .inB(ImmExt), 
    .inC(32'd4), 
    .out(src_B)
    );

  // Unidade Logica e aritmetica
  alu arithmetic_logic_unit(
    .ALUctrl(ALUCtrl),
    .srcA(src_A), 
    .srcB(src_B),
    .ALUOut(ALUResult),
    .Zero(Zero)
    );

// ---------------------------------------------------
// Estagio de leitura de memoria
// ---------------------------------------------------
wire [31:0] ALUOut;
wire [1:0] ResultSrc;

  // Registrador do resultado da ULA
  flipflop alu_register(
    .clk(clk), 
    .en(1'b1), 
    .resetn(resetn),
    .in(ALUResult),
    .out(ALUOut)
  );

  // Seleciona o resultado da ULA para PC
  mux3to1 result_selection(
    .sel(ResultSrc), 
    .inA(ALUOut), 
    .inB(Data), 
    .inC(ALUResult), 
    .out(Result)
  );

// ---------------------------------------------------
// Unidade de controle e maquina de estados
// ---------------------------------------------------
wire [2:0] ALUCtrl;

  controlUnit control_unit(
    .clk(clk),
    .resetn(resetn),
    .opcode(Opcode),
    .zero(Zero),
    .pcwrite(PCWrite), 
    .adrsrc(AdrSrc), 
    .memwrite(MemWrite), 
    .irwrite(IRWrite), 
    .regwrite(RegWrite),
    .resultsrc(ResultSrc), 
    .alusrca(ALUSrcA), 
    .alusrcb(ALUSrcB), 
    .immsrc(ImmSrc),
    .aluctrl(ALUCtrl)
    );

endmodule
