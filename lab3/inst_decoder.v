`define	NumBits	16


// input: 16bit instruction
// output: 4bit opcode, 2bit rs, 2bit rt,
//         2bit rd, 6bit function,
//         8bit immediate, 12bit targetaddress
module inst_decoder (inst, 
                    
                    opcode, rs, rt, rd, func_code,
                    immediate_and_offset, target_address);
    input wire [`NumBits-1:0] inst;

    output wire [3:0] opcode;
    output wire [1:0] rs;
    output wire [1:0] rt;
    output wire [1:0] rd;
    output wire [5:0] func_code;
    output wire [7:0] immediate_and_offset;
    output wire [11:0] target_address;


    assign opcode = inst[`NumBits-1:12];
    assign rs = inst[11:10];
    assign rt = inst[9:8];
    assign rd = inst[7:6];
    assign func_code = inst[5:0];
    assign immediate_and_offset = inst[7:0];
    assign target_address = inst[11:0];

endmodule
