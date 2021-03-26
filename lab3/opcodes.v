// read register 1: rs , read register 2: rt, write register: rd
// Opcode
`define	ALU_OP	4'd15

`define	ADI_OP	4'd4 // ADDI. rt = rs + imm
`define	ORI_OP	4'd5 // rt = rs | imm
`define	LHI_OP	4'd6 // rt = (imm << 8)

`define	LWD_OP	4'd7 // rt = memory[rs + offset]
`define	SWD_OP	4'd8 // memory[rs + offset] = rt

`define	BNE_OP	4'd0 // if rs!=rt then pc=pc+offset else pc=pc+4
`define	BEQ_OP	4'd1 // if rs=rt then pc=pc+offset else pc=pc+4
`define BGZ_OP	4'd2 // if rs>0 then pc=pc+offset else pc=pc+4
`define BLZ_OP	4'd3 // if rs<0 then pc=pc+offset else pc=pc+4

// Extender 그대로 받음. PCMuxSelector == 2
`define	JMP_OP	4'd9 // pc = {pc[15:12], target[11:0]}

// Extender 그대로 받음. PCMuxSelector == 2
`define JAL_OP	4'd10 // reg[2] = pc; pc = {pc[15:12], target[11:0]}

`define	JPR_OP	4'd15 // pc = rs
`define	JRL_OP	4'd15 // reg[2] = pc; pc = rs;
// TODO: JAL, JRL. pc+4 ? or pc ?

// ALU Function Codes
`define	FUNC_ADD	3'b000
`define	FUNC_SUB	3'b001				 
`define	FUNC_AND	3'b010
`define	FUNC_ORR	3'b011								    
`define	FUNC_NOT	3'b100
`define	FUNC_TCP	3'b101
`define	FUNC_SHL	3'b110
`define	FUNC_SHR	3'b111	

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

`define	WORD_SIZE	16			
`define	NUM_REGS	4