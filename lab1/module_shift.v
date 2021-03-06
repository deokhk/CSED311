`include "alu_func.v"

`define data_width 16


module LLSModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;
output wire [`data_width - 1 : 0] C;

assign C=(A<<1);

endmodule


module LRSModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;
output wire [`data_width - 1 : 0] C;

assign C=(A>>1);

endmodule


module ALSModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;
output wire [`data_width - 1 : 0] C;

assign C=(A<<<1);

endmodule


module ARSModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;
output wire [`data_width - 1 : 0] C;

// TODO: If something went wrong with right shift, check this part.
assign C=($signed(A) >>> 1);

endmodule
