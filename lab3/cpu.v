`include "opcodes.v"
`include "alu.v" 	
`include "control_unit.v"
`include "extend.v"
`include "inst_decoder.v"
`include "mux.v"
`include "register_file.v"   

module cpu (readM, writeM, address,
			data,
			ackOutput, inputReady, reset_n, clk);
	inout [`WORD_SIZE-1:0] data;
	
	input ackOutput; // 메모리에 데이터 다 썼다고 알려줌. 좀 있다 0 됨
	input inputReady; // 메모리가 데이터 다 읽었다고 알려줌. 좀 있다 0 됨. 따라서 지금 data는 memory로부터 read한 값임.
	input reset_n; // 0 일 때 reset. 1 이면 정상작동
	input clk;

	output reg readM; // 우리가 메모리로부터 데이터 읽고 싶을때 이거를 1로 해야 됨.	다시 꺼야 함.
	output reg writeM; // 우리가 메모리에 데이터 쓰고 싶을때 이거를 1로 해야 됨. 다시 꺼야함.
	output reg [`WORD_SIZE-1:0] address;	

	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] one;
	reg [`WORD_SIZE-1:0] instruction;

	wire [`WORD_SIZE-1:0] pc_plus_1;
	wire [`WORD_SIZE-1:0] pc_plus_imm;
	wire [`WORD_SIZE-1:0] pc_next;

	wire [`WORD_SIZE-1:0] extended_output;
	wire [`WORD_SIZE-1:0] alu_output;
	wire bcond;
	wire [1:0] pc_mux_sel;
	
    wire is_branch;
    wire is_jmp_jal;
    wire is_jpr_jrl;
    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    wire pc_to_reg;

	wire [3:0] opcode;
	wire [1:0] in_addr1;
	wire [1:0] in_addr2;
	wire [1:0] write_addr;
	wire [5:0] func_code;
	wire [7:0] immediate_and_offset;
	wire [11:0] target_address;

    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
	wire [15:0] write_data;
	wire [15:0] mem_to_reg_data;
	wire [15:0] alu_src_data;


	ADDModule pc_plus_1_adder (
		.A(pc), .B(one),
		.C(pc_plus_1)
	);
	ADDModule pc_plus_imm_adder (
		.A(pc), .B(extended_output),
		.C(pc_plus_imm)
	);


 	Mux4to1 pc_mux (
		.in0(pc_plus_1), .in1(pc_plus_imm),
		.in2(extended_output), .in3(alu_output), .sel(pc_mux_sel),

        .out(pc_next)
	);
	Mux2to1 pc_to_reg_mux(
		.in0(mem_to_reg_data), .in1(pc), .sel(pc_to_reg),
        .out(write_data)
	);
	Mux2to1 mem_to_reg_mux(
		.in0(alu_output), .in1(data), .sel(mem_to_reg),
        .out(mem_to_reg_data)
	);
	Mux2to1 alu_src_mux(
		.in0(reg_data2), .in1(extended_output), .sel(alu_src),
        .out(alu_src_data)
	);
    PcMuxSelector pc_mux_selector (
		.is_branch(is_branch), .is_jmp_jal(is_jmp_jal),
		.is_jpr_jrl(is_jpr_jrl), .bcond(bcond),

        .pc_mux_sel(pc_mux_sel)
	);


	Control control (
		.opcode(opcode), .func_code(func_code),

		.is_branch(is_branch), .is_jmp_jal(is_jmp_jal), .is_jpr_jrl(is_jpr_jrl),
		.mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
		.alu_src(alu_src), .reg_write(reg_write), .pc_to_reg(pc_to_reg)
	);

    ALU alu (
		.alu_input_1(reg_data1), .alu_input_2(alu_src_data),
		.opcode(opcode), .func_code(func_code),
			
		.alu_output(alu_output), .bcond(bcond)
	);

	InstDecoder inst_decoder (
		.inst(instruction),
                    
		.opcode(opcode), .in_addr1(in_addr1), .in_addr2(in_addr2),
		.write_addr(write_addr), .func_code(func_code),
		.immediate_and_offset(immediate_and_offset), .target_address(target_address)
	);

	RegisterFile register_file(
		.in_addr1(in_addr1), .in_addr2(in_addr2),
        .write_addr(write_addr), .write_data(write_data),
        .reg_write_signal(reg_write), .clk(clk),

        .reg_data1(reg_data1), .reg_data2(reg_data2)
	); 

	ExtendDelegator extend_delegator(
		.pc(pc), .opcode(opcode),
        .immediate_and_offset(immediate_and_offset), .target_address(target_address),
                        
        .extended_output(extended_output)
	);


	assign data = (writeM || ackOutput) ? reg_data2 : `WORD_SIZE'bz;


	initial begin
		pc = 0;
		one = 1;
		instruction = 0;
		readM = 0;
		writeM = 0;
		address = 0;
	end


	// combinational logic
	always @(*) begin
	// 컨트롤 모듈에서, SWD 면 -> writeM = 1
	// 끝나면 writeM  = 0
	// ackOutput == 0 이 되면, -> writeM  = 0
	// read 는 input ready 
		if (inputReady == 1) begin
			if (opcode != `LWD_OP) begin
				instruction = data;
			end
			readM = 0;
		end
		else begin readM = 0; end

		if(ackOutput == 1) begin
			writeM = 0;
		end
		else begin writeM = 0; end

		if (opcode == `LWD_OP) begin
			address = alu_output;
			readM = 1;
		end

		if (opcode == `SWD_OP) begin
			address = alu_output;
			writeM = 1;
		end

		if (reset_n == 0) begin
			pc = 0;
			one = 1;
			instruction = 0;
			readM = 0;
			writeM = 0;
			address = 0;
		end

	end



	// sequential logic 으로 pc, 다른 register 연산 수행
	always @(posedge clk) begin
		// pc <= pc_next;
		address <= pc;
		readM <= 1;
		// 30 ns 흐르고, 다 읽어서 inputReady 1 됨
		// instruction fetch 하고, 실행까지 완료됨

	end

	always @(negedge clk) begin
		// 50 ns 에서 시작
		// LWD, SWD 이면, 시그널 보내

		// 근데 LWD 거나 SWD 이면 시그널 보내는 거는
		// Combinational logic 에서 가능한 거 아님???

		// if (opcode == `LWD_OP) begin
		// 	address <= alu_output;
		// 	readM <= 1;

		// end

		// if (opcode == `SWD_OP) begin
		// 	address <= alu_output;
		// 	writeM <= 1;
		// end

		pc <= pc_next;
	end


endmodule
