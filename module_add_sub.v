
`define data_width 16


module ADDModule(
    A, B,
    C, OverflowFlag
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;
output wire OverflowFlag;

assign C=A+B;
assign OverflowFlag = (A[`data_width - 1] == B[`data_width - 1]) & (A[`data_width - 1] != C[`data_width - 1]);

endmodule


module SUBModule(
    A, B,
    C, OverflowFlag
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;
output wire OverflowFlag;

assign C=A-B;
assign OverflowFlag = (A[`data_width - 1] != B[`data_width - 1]) & (B[`data_width - 1] == C[`data_width - 1]);

endmodule
