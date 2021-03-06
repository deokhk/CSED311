`include "alu_func.v"

`define data_width 16


module others(
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
        `FUNC_ID:begin C<=A; OverflowFlag<=0; end
        `FUNC_TCP:begin C<=~A+1; OverflowFlag<=0; end
        `FUNC_ZERO:begin C<=0; OverflowFlag<=0; end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule
