`include "alu_func.v"

`define data_width 16


module IDModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;

output wire [`data_width - 1 : 0] C;

assign C=A;

endmodule


module TCPModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;

output wire [`data_width - 1 : 0] C;

assign C=~A+1;

endmodule


module ZEROModule(
    C
);

output wire [`data_width - 1 : 0] C;

assign C=0;

endmodule
