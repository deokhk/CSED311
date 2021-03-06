`include "alu_func.v"

`define data_width 16


module add_sub(
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
        `FUNC_ADD:begin
            C=A+B;
            if (A[`data_width - 1] == B[`data_width - 1])
                if (A[`data_width - 1] != C[`data_width - 1])
                    OverflowFlag=1;
                else
                    OverflowFlag=0;
            else
                OverflowFlag=0;
         end
        `FUNC_SUB:begin
            C=A-B;
            if (A[`data_width - 1] != B[`data_width - 1])
                if (B[`data_width - 1] == C[`data_width - 1])
                    OverflowFlag=1;
                else
                    OverflowFlag=0;
            else
                OverflowFlag=0;

        end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule
