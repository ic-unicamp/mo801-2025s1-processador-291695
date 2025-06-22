module controlUnit(
    input clk, resetn,
    input [6:0] opcode,
    input zero,
    output reg pcwrite, adrsrc, memwrite, irwrite, regwrite,
    output reg [1:0] resultsrc, alusrca, alusrcb, immsrc,
    output reg [2:0] aluctrl
    );

    // decodificacao dos estados
    localparam
        FETCH       = 5'b00000,
        DECODE      = 5'b00001,
        LW_MEMADDR  = 5'b00010,
        LW_MEMREAD  = 5'b00011,
        LW_MEMWRITE = 5'b00100,
        SW_MEMADDR  = 5'b00101,
        SW_MEMWRITE = 5'b00110,
        EXEC_R      = 5'b00111,
        ALU_WB      = 5'b01000,
        EXEC_I      = 5'b01001,
        BEQ         = 5'b01010,
        JAL         = 5'b01011;

    // decodificacao dos opcodes
    localparam
        NOP    = 7'b0000000,
        R_TYPE = 7'b0110011,
        L_TYPE = 7'b0000011,
        I_TYPE = 7'b0010011,
        S_TYPE = 7'b0100011,
        B_TYPE = 7'b1100011,
        J_TYPE = 7'b1101111;

    reg [4:0] state;

    always @(posedge clk) begin
        if (!resetn)
            state = FETCH;
        // Rodolfo: Você devia ter a nova atribuição de state aqui num else.
    end

    always @(posedge clk) begin
        $display("state: %b", state);
        pcwrite = 1'b0;
        adrsrc = 1'b0;
        memwrite = 1'b0;
        irwrite = 1'b0;
        regwrite = 1'b0;
        resultsrc = 2'b00;
        alusrca = 2'b00;
        alusrcb = 2'b00;
        immsrc = 2'b00;
        aluctrl = 3'b000;
        case(state)
            FETCH: begin // fetch
                $display("Fetch");
                adrsrc = 1'b0;
                irwrite = 1'b1;
                alusrca = 2'b00;
                alusrcb = 2'b10;
                resultsrc = 2'b00;
                pcwrite = 1'b1;
                aluctrl = 3'b010;
                state = DECODE; // Rodolfo: não pode atribuir a state em dois always distintos.
            end
            DECODE: begin // decode
                $display("Decode - opcode: %b", opcode);
                alusrca = 2'b01;
                alusrcb = 2'b01;
                aluctrl = 3'b010;
                case(opcode)
                NOP: begin
                    $display("NOP");
                    state = FETCH;
                    end
                R_TYPE: begin // R-type
                    $display("R-type");
                    state = EXEC_R;
                    end
                L_TYPE: begin // L-type
                    $display("L-type");
                    state = LW_MEMADDR;
                    end
                I_TYPE: begin // I-type
                    $display("I-type");
                    state = EXEC_I;
                    end
                S_TYPE: begin // S-type
                    $display("S-type");
                    state = SW_MEMADDR;
                    end
                B_TYPE: begin // B-type
                    $display("B-type");
                    immsrc = 3'b10;
                    aluctrl = 3'b010;
                    state = BEQ;
                    end
                J_TYPE: begin // J-type
                    $display("J-type");
                    state = JAL;
                    end
                endcase
            end
            LW_MEMADDR: begin // MemAddress when opcode == lw
                $display("MemAddress LW");
                alusrca = 2'b10;
                alusrcb = 2'b01;
                state = LW_MEMREAD;
                aluctrl = 3'b010;
            end
            LW_MEMREAD: begin // MemRead when opcode == lw
                $display("MemRead LW");
                resultsrc = 2'b00;
                adrsrc = 1;
                state = LW_MEMWRITE;

            end
            LW_MEMWRITE: begin // MemWB when opcode == lw
                $display("MemWB LW"); 
                resultsrc = 2'b01;
                regwrite = 1'b1;
                state = FETCH; 

            end
            SW_MEMADDR: begin // MemAddress when opcode == sw
                $display("MemAddress SW");
                alusrca = 2'b10;
                alusrcb = 2'b01;
                state = SW_MEMWRITE;

            end
            SW_MEMWRITE: begin // MemWrite when opcode == sw
                $display("MemWrite SW");
                resultsrc = 2'b00;
                adrsrc = 1'b1;
                memwrite = 1'b1;
                state = FETCH;

            end
            EXEC_R: begin // Execute R-type
                $display("Execute R");
                alusrca = 2'b10;
                alusrcb = 2'b00;
                aluctrl = 3'b010;
                state = ALU_WB;

            end
            ALU_WB: begin // ALU WriteBack
                $display("ALU WB");
                resultsrc = 2'b00;
                regwrite = 1'b1;
                state = FETCH;

            end
            EXEC_I: begin // Execute I-type
                $display("Execute I");
                alusrca = 2'b10;
                alusrcb = 2'b01;
                aluctrl = 3'b010;
                state = ALU_WB;

            end
            BEQ: begin
                $display("BEQ - zero: %b", zero);
                alusrca = 2'b10;
                alusrcb = 2'b00;
                resultsrc = 2'b00;
                aluctrl = 3'b110;
                state = FETCH;
                if (zero) begin
                    pcwrite = 1'b1;
                end
            end
            JAL: begin
                $display("JAL");
                alusrca = 2'b01;
                alusrcb = 2'b10;
                resultsrc = 2'b00;
                pcwrite = 1'b1;
                aluctrl = 3'b010;
                state = ALU_WB;
            end
            default: begin
                state = FETCH;
            end
        endcase
    end

endmodule

