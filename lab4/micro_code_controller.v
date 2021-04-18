`include "opcodes.v"


module MicroCodeController(opcode, func_code, reset_n, clk,

                           mem_read, mem_to_reg, mem_write, reg_write,
                           alu_src_a, alu_src_b,
                           i_or_d, ir_write, dr_write,
                           pc_source, pc_write, 
                           wwd, halt, pass_input_1, pass_input_2,
                           A_write_en, B_write_en,
                           bcond_write_en, aluout_write_en, next_pc_reg_write_en,
                           wb_out_reg_write_en,
                           alu_opcode, wb_sel,
                           num_inst,


                           state

                           );

    input wire [3:0] opcode;
    input wire [5:0] func_code;
    input wire reset_n;
    input wire clk;

    output wire mem_read;
    output wire mem_to_reg;
    output wire mem_write;
    output wire reg_write;

    output wire alu_src_a;
    output wire [1:0] alu_src_b;

    output wire i_or_d; 
    output wire ir_write;
    output wire dr_write;

    output wire pc_source;
    output wire pc_write;
    
    output wire wwd;
    output wire halt;

    output wire pass_input_1;
    output wire pass_input_2;

    output wire A_write_en;
    output wire B_write_en;
    output wire bcond_write_en;
    output wire aluout_write_en;
    output wire next_pc_reg_write_en;
    output wire wb_out_reg_write_en;

    output wire [3:0] alu_opcode;
    output wire wb_sel;
    output reg [`WORD_SIZE-1:0] num_inst;

    output reg [3:0] state;


	initial begin
		state = 0;
		num_inst = -1;
	end


	always @(posedge reset_n) begin
		state <= 0;
		num_inst <= -1;
	end


    // EX3에서 우리 alu는 pc+1을 계산해야됨.
    // 이를 명시적으로 강제하기 위해서, 우리는 현재 state가 EX3이고 특정 operation이 아닌 경우 opcode를 ADI로 바꿔 주어 pc+1을 계산함. 
    assign alu_opcode = (state == `EX3) && 
    !((opcode == `JMP_OP) ||
      (opcode == `JAL_OP) ||
      ((opcode == `JPR_OP) && (func_code == `INST_FUNC_JPR)) ||
      ((opcode == `JRL_OP) && (func_code == `INST_FUNC_JRL))) ? `ADI_OP : opcode;


    assign mem_read = (state == `IF2) || (state == `IF3) || ((opcode == `LWD_OP) && (state >= `MEM1) && (state <= `MEM4));
    assign mem_to_reg = (opcode == `LWD_OP) && (state == `WB);
    assign mem_write = ((opcode == `SWD_OP) && (state >= `MEM1) && (state <= `MEM4));
    assign reg_write = (state == `WB);
    
    // alu_src_a, b 는 ID 에서 결정돼야함.

    // EX1 에서는, bcond 계산
    // EX2 에서는 각 연산이 요구하는 operation을 수행함.
    // EX3에서 PC+1 계산
    //((state == `EX2) || ((state == `EX3) && (opcode >= `BNE_OP) && (opcode <= `BLZ_OP))) ? 0 : 1;
    assign alu_src_a = (state == `EX1) || 
                       ((state == `EX2) && (opcode >= `ADI_OP) && (opcode <= `SWD_OP)) || 
                       ((state == `EX2) && (opcode == `ALU_OP));
    assign alu_src_b = ((state == `EX1) || ((state == `EX2) && (opcode == `ALU_OP))) ? 0
                            : ((state == `EX3) ? 1
                            : 2);
    assign pass_input_1 = (opcode == `JAL_OP) && (state == `EX3);
    assign pass_input_2 = (opcode == `JAL_OP) && (state == `EX2);

    // TODO: EX3 에서, next_pc = (output from ps_source_mux)
    // TODO: 각종 reg latch 들을, 특정 스테이지에서만 허용해줘야함.
    // bcond reg, ALUout, next_pc reg -> 각 EX state 마다, 적절히 시그널 만들어서 뿌려줘야하고
    // A, B: ID state 일때만, A_write_en, B_write_en 켜줌.

    // TODO: CPU 에서 어케 업데이트 할지는, always (bcond) 이런 거로 ㄱㄱ
    assign bcond_write_en = (state == `EX1);
    assign aluout_write_en = (state == `EX2);
    assign next_pc_reg_write_en = (state == `EX3);
    assign wb_out_reg_write_en = (state == `EX3);

    assign A_write_en = (state == `ID);
    assign B_write_en = (state == `ID);


    assign i_or_d = ((opcode == `LWD_OP) || (opcode == `SWD_OP)) && (state >= `MEM1) && (state <= `MEM4);
    assign ir_write = (state == `IF2) || (state == `IF3);
    assign dr_write = (opcode == `LWD_OP) && (state >= `MEM1) && (state <= `MEM4);

    // pcmuxselector 가 bcond 랑 함께 처리해줄 거야
    // TODO: bcond reg 만들어서, EX1 의 결과만 쓰도록 해줘야 함.
    assign pc_source = ((opcode >= `BNE_OP) && (opcode <= `BLZ_OP))
                    || (opcode == `JMP_OP) || (opcode == `JAL_OP)
                    || ((opcode == `JPR_OP) && ((func_code == `INST_FUNC_JPR) || (func_code == `INST_FUNC_JRL)));
    assign pc_write = (state == `IF1); // next_pc 만들어서, IF1 일 때, pc = next_pc
    assign wwd = (opcode == `WWD_OP) && (func_code == `INST_FUNC_WWD) &&  (state == `EX1); // rs1 을 외부에 업데이트
    assign halt = (opcode == `HLT_OP) && (func_code == `INST_FUNC_HLT);
    
    assign wb_sel = (opcode == `JAL_OP) ||((opcode == `JRL_OP) && (func_code == `INST_FUNC_JRL));

    always @(posedge clk) begin
        case(state)
            `IF1: begin // PC update 는 IF1 에서 하는 것. 0
                num_inst <= num_inst + 1;
                state <= `IF2;
            end
            `IF2: begin // 1
                state <= `IF3;
            end
            `IF3: begin // 2
                if (opcode == `JAL_OP || opcode == `JMP_OP) begin
                    state <= `EX1;
                end
                else begin 
                    state <= `ID;
                end
            end
            `ID: begin // 3
                state <= `EX1;
            end 
            `EX1: begin // 4
                state <= `EX2;
            end
            `EX2: begin // 5
                state <= `EX3;
            end
            `EX3: begin // 6
                if (opcode == `BNE_OP || opcode == `BEQ_OP || opcode == `BGZ_OP || opcode == `BLZ_OP) begin
                    state <= `IF1;
                end
                else if (opcode == `JMP_OP) begin
                    state <= `IF1;
                end
                else if (opcode == `ALU_OP && (func_code == `INST_FUNC_JPR || func_code == `INST_FUNC_WWD || func_code == `INST_FUNC_HLT)) begin
                    state <= `IF1;
                end
                else if (opcode == `LWD_OP || opcode == `SWD_OP) begin
                    state <= `MEM1;
                end
                else begin
                    state <= `WB;
                end
            end
            `MEM1: begin // 7
                state <= `MEM2;
            end
            `MEM2: begin // 8
                state <= `MEM3;
            end
            `MEM3: begin // 9
                state <= `MEM4;
            end
            `MEM4: begin // 10
                if (opcode == `LWD_OP) begin
                    state <= `WB;
                end
                else begin
                    state <= `IF1;
                end
            end
            `WB: begin // 11
                state <= `IF1;
            end
            default: begin state <= `IF1; end
         endcase
    end
endmodule


module PCMuxSelector(pc_source, bcond, opcode,
                     
                     pc_mux_sel);
    input wire pc_source;
    input wire bcond;
    input wire [3:0] opcode;

    output wire pc_mux_sel;

    // not branch -> only pcsource
    // branch -> pcsource && bcond
    assign pc_mux_sel = ((opcode >= `BNE_OP) && (opcode <= `BLZ_OP)) ? (pc_source && bcond) : pc_source;

endmodule


