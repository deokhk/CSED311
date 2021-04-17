`include "opcodes.v"


module MicroCodeController(opcode, func_code, reset_n, clk,

                           mem_read, mem_to_reg, mem_write, reg_write,
                           alu_src_a, alu_src_b,
                           i_or_d, ir_write,
                           pc_source, pc_write, 
                           wwd, halt, pass_input_1, pass_input_2
                           );

    input wire [3:0] opcode;
    input wire [5:0] func_code;

    // existing control signals
    output wire mem_read;
    output wire mem_to_reg;
    output wire mem_write;
    output wire reg_write;

    // new control signals 
    output wire alu_src_a; // 0 -> ALU input1 이 PC. 1 -> ALU input1 이 RF port 1 에서 (A latch 에서) 옴.

    // 0 -> RF port 2, B latch 에서
    // 1 -> 1 for pc increment
    // 2 -> from extend 값
    // 이 값이 ALU 두 번째 input
    output wire [1:0] alu_src_b;

    // 0 -> inst fetch. addr by PC
    // 1 -> ld or sd 에서, ALUOut
    // 값이 addr 결정
    output wire i_or_d; 
    
    // 0 -> Inst register 에 write 금지
    // 1 -> Inst register 에 write enable
    // IF 4 개 스텝 중에 IF1 일 때만 읽어서 Inst reg 에 저장해둠
    // 나머지 스텝에서는 끔
    output wire ir_write;

    // 0 -> nextpc는 aluout(예전에 계산했고, latched 해둔 값)
    // 1 -> nextpc는 aluresult(지금 계산한 값)
    output wire pc_source;

    // 0 -> pass
    // 1 -> PCSource Mux 에서 오는 next pc 를, 무지성으로 pc <= pc_next;
    output wire pc_write;


    
    output wire wwd;
    output wire halt;

    output wire pass_input_1;
    output wire pass_input_2;
    reg [3:0] state;

    assign mem_read = (state == `IF2) || (state == `IF3) || ((opcode == `LWD_OP) && (state >= `MEM1) && (state <= `MEM3));
    assign mem_to_reg = (opcode == `LWD_OP) && (state == `WB);
    assign mem_write = ((opcode == `SWD_OP) && (state >= `MEM1) && (state <= `MEM3));
    assign reg_write = (state == `WB);
    
    // alu_src_a, b 는 ID 에서 결정돼야함.

    // EX1 에서는, bcond 계산
    // EX2 에서는, PC+1 계산
    // EX3에서 각 연산이 요구하는 operation을 수행함.
    //((state == `EX2) || ((state == `EX3) && (opcode >= `BNE_OP) && (opcode <= `BLZ_OP))) ? 0 : 1;
    assign alu_src_a = (state == `EX1) || 
                       ((state >= `EX3) && (opcode >= `ADI_OP) && (opcode <= `SWD_OP)) || 
                       ((state >= `EX3) && (opcode == `ALU_OP));
    assign [1:0] alu_src_b = ((state == `EX1) || ((state >= `EX3) && (opcode == `ALU_OP))) ? 0
                            : ((state == `EX2) ? 1
                            : 2);
    assign pass_input_1 = (opcode == `JAL_OP) && (state == `EX2);
    assign pass_input_2 = (opcode == `JAL_OP) && (state >= `EX3);

    // TODO: EX4 에서, next_pc = (output from ps_source_mux)
    // TODO: 각종 reg latch 들을, 특정 스테이지에서만 허용해줘야함.
    // bcond reg, ALUout, next_pc reg -> 각 EX stage 마다, 적절히 시그널 만들어서 뿌려줘야하고
    // A, B: ID stage 일때만, A_write_en, B_write_en 켜줌.


    assign i_or_d = ((opcode == `LWD_OP) || (opcode == `SWD_OP)) && (state >= `MEM1) && (state <= `MEM3);
    assign ir_write = (state == `IF2) || (state == `IF3);

    // pcmuxselector 가 bcond 랑 함께 처리해줄 거야
    // TODO: bcond reg 만들어서, EX1 의 결과만 쓰도록 해줘야 함.
    assign pc_source = ((opcode >= `BNE_OP) && (opcode <= `BLZ_OP))
                    || (opcode == `JMP_OP) || (opcode == `JAL_OP)
                    || ((opcode == `JPR_OP) && ((func_code == `INST_FUNC_JPR) || (func_code == `INST_FUNC_JRL)));
    assign pc_write = (state == `IF1); // next_pc 만들어서, IF1 일 때, pc = next_pc
    assign wwd = ;
    assign halt = ;
    

    always @(posedge clk) begin
        case(state)
            `IF1: begin // PC update 는 IF1 에서 하는 것.
                state = `IF2;
            end
            `IF2: begin
                state = `IF3;
            end
            `IF3: begin
                if (opcode == `JAL_OP) begin
                    state = `EX1;
                end
                else begin 
                    state = `ID;
                end
            end
            `ID: begin
                state = `EX1;
            end 
            `EX1: begin
                state = `EX2;
            end
            `EX2: begin
                state = `EX3;
            end
            `EX3: begin
                state = `EX4;
            end
            `EX4: begin
                if (opcode == `BNE_OP || opcode == `BEQ_OP || opcode == `BGZ_OP || opcode == `BLZ_OP) begin
                    state = `IF1;
                    // TODO: PVSWriteEn=1이 되어야 하는데, 이를 어떻게 처리해줄지 생각해볼것.
                end
                else if (opcode == `JMP_OP || opcode == `JPR_OP) begin
                    state = `IF1;
                end
                else if (opcode == `WWD_OP || opcode == `HLT_OP) begin
                    state = `IF1;
                end
                else if (opcode == `LWD_OP || opcode == `SWD_OP) begin
                    state = `MEM1;
                end
                else begin
                    state = `WB;
                end
            end
            `MEM1: begin
                state = `MEM2;
            end
            `MEM2: begin
                state = `MEM3;
            end
            `MEM3: begin
                if (opcode == `LWD_OP) begin
                    state = `WB;
                end
                else begin
                    state = `IF1;
                end
            end
            `WB: begin
                state = `IF1;
            end
            default: begin state = `IF1; end
         endcase
    end
                           


endmodule


module PCMuxSelector(pc_source, bcond, opcode,
                     
                     pc_mux_sel);
    input wire pc_source;
    input wire bcond;
    input wire opcode;

    output wire pc_mux_sel;

    // not branch -> only pcsource
    // branch -> pcsource && bcond
    assign pc_mux_sel = ((opcode >= `opcode) && (opcode <= `BLZ_OP)) ? (pc_source && bcond) : pc_source;

endmodule


