// read register 1: rs , read register 2: rt, write register: rd
// Opcode
`define	ALU_OP	4'd15

`define	ADI_OP	4'd4 // ADDI. rt = rs + imm
`define	ORI_OP	4'd5 // rt = rs | imm
`define	LHI_OP	4'd6 // rt = (imm << 8)

`define	LWD_OP	4'd7 // rt = memory[rs + offset]
`define	SWD_OP	4'd8 // memory[rs + offset] = rt

`define	BNE_OP	4'd0 // if rs!=rt then pc=pc+offset else pc=pc+1
`define	BEQ_OP	4'd1 // if rs=rt then pc=pc+offset else pc=pc+1
`define BGZ_OP	4'd2 // if rs>0 then pc=pc+offset else pc=pc+1
`define BLZ_OP	4'd3 // if rs<0 then pc=pc+offset else pc=pc+1

// Extender 그대로 받음. PCMuxSelector == 2
`define	JMP_OP	4'd9 // pc = {pc[15:12], target[11:0]}

// Extender 그대로 받음. PCMuxSelector == 2

// ALUout 에 pc + 0. ALUresult = extend_delegator (aluinput1 은 무시됨)
`define JAL_OP	4'd10 // reg[2] = pc; pc = {pc[15:12], target[11:0]}

`define	JPR_OP	4'd15 // pc = rs
`define	JRL_OP	4'd15 // reg[2] = pc; pc = rs;

`define   HLT_OP   4'd15 // End of the program
`define   WWD_OP   4'd15 // outputport <- rs;

// ALU Function Codes
`define   FUNC_ADD   3'b000
`define   FUNC_SUB   3'b001             
`define   FUNC_AND   3'b010
`define   FUNC_ORR   3'b011                            
`define   FUNC_NOT   3'b100
`define   FUNC_TCP   3'b101
`define   FUNC_SHL   3'b110
`define   FUNC_SHR   3'b111   

// ALU instruction function codes
`define INST_FUNC_ADD 6'd0
`define INST_FUNC_SUB 6'd1
`define INST_FUNC_AND 6'd2
`define INST_FUNC_ORR 6'd3
`define INST_FUNC_NOT 6'd4
`define INST_FUNC_TCP 6'd5
`define INST_FUNC_SHL 6'd6
`define INST_FUNC_SHR 6'd7
`define INST_FUNC_JPR 6'd25
`define INST_FUNC_JRL 6'd26
`define INST_FUNC_WWD 6'd28
`define INST_FUNC_HLT 6'd29

`define   WORD_SIZE   16         
`define   NUM_REGS   4

// micro state definition
`define IF1 4'd0 
`define IF2 4'd1
`define IF3 4'd2
`define ID 4'd3
`define EX1 4'd4 // 여기서 bcond 계산. bxx operation이 아닌경우에는 쓰레기값이 계산됨. 
`define EX2 4'd5 // rs1 + rs2  or pc + imm 여기가 찐 계산
`define EX3 4'd6 // PC + 4 계산해서, ALUOut
`define MEM1 4'd7
`define MEM2 4'd8
`define MEM3 4'd9
`define MEM4 4'd10
`define WB 4'd11
