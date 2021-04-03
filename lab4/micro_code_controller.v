`include "opcodes.v"


module MicroCodeController(opcode, func_code, reset_n, clk,

                           mem_read, mem_to_reg, mem_write, reg_write,
                           alu_src_a, alu_src_b,
                           i_or_d, ir_write,
                           pc_source, pc_write, pc_write_not_cond,
                           wwd, halt
                           );

    input wire [3:0] opcode;
    input wire [5:0] func_code;

    // existing control signals
    output wire mem_read;
    output wire mem_to_reg;
    output wire mem_write;
    output wire reg_write;

    // new control signals 
    output wire alu_src_a;
    output wire [1:0] alu_src_b;
    output wire i_or_d;
    output wire ir_write;
    output wire pc_source;
    output wire pc_write;
    output wire pc_write_not_cond;
    output wire wwd;
    output wire halt;

    reg [3:0] state;


    

    always @(posedge clk) begin
        case(state)
            `IF1: begin
                state = `IF2;
            end
            `IF2: begin
                state = `IF3;
            end
            `IF3: begin
                state = `IF4;
            end
            `IF4: begin
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
                state = `MEM4;
            end
            `MEM4: begin
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