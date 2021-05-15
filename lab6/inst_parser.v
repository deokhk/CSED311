`include "opcodes.v"

`define	NumBits	16


module InstParser (inst, 
                    
                    opcode, in_addr1, in_addr2, write_addr, func_code,
                    immediate_and_offset, target_address);
    input wire [`NumBits-1:0] inst;

    output wire [3:0] opcode;
    output wire [1:0] in_addr1;
    output wire [1:0] in_addr2;
    output wire [1:0] write_addr;
    output wire [5:0] func_code;
    output wire [7:0] immediate_and_offset;
    output wire [11:0] target_address;


    assign opcode = inst[`NumBits-1:12];
    assign in_addr1 = inst[11:10];
    assign in_addr2 = inst[9:8];
    assign write_addr = ((opcode == `JAL_OP) || ((opcode == `JRL_OP) && (func_code == `INST_FUNC_JRL))) ? 2 : 
                        (((opcode == `ADI_OP) || (opcode == `ORI_OP) || (opcode == `LHI_OP) || (opcode == `LWD_OP) || (opcode == `SWD_OP)) ? inst[9:8] : 
                        inst[7:6]);
    assign func_code = inst[5:0];
    assign immediate_and_offset = inst[7:0];
    assign target_address = inst[11:0];

endmodule
