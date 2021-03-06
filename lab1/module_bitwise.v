`include "alu_func.v"

`define data_width 16


module bitwise(
    A,
    B,
    FuncCode,
    C,
    OverflowFlag);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;
input wire [3:0] FuncCode;
output reg [`data_width - 1 : 0] C;
output reg OverflowFlag;

always@(A or B or FuncCode) begin
    case (FuncCode)
        `FUNC_NOT:begin C<=~A; OverflowFlag<=0; end
        `FUNC_AND:begin C<=A&B; OverflowFlag<=0; end
        `FUNC_OR:begin C<=A|B; OverflowFlag<=0; end
        `FUNC_NAND:begin C<=~(A&B); OverflowFlag<=0; end
        `FUNC_NOR:begin C<=~(A|B); OverflowFlag<=0; end
        `FUNC_XOR:begin C<=A^B; OverflowFlag<=0; end
        `FUNC_XNOR:begin C<=~(A^B); OverflowFlag<=0; end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule
