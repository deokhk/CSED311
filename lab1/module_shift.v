`include "alu_func.v"

`define data_width 16


module shift(
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

always@(A or FuncCode) begin
    case (FuncCode)
        `FUNC_LLS:begin C<=(A<<1); OverflowFlag<=0; end
        `FUNC_LRS:begin C<=(A>>1); OverflowFlag<=0; end
        `FUNC_ALS:begin C<=(A<<<1); OverflowFlag<=0; end
        `FUNC_ARS:begin C<=(A>>>1); OverflowFlag<=0; end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule
