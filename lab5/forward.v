module ForwardingUnit(rs1_addr_ex, rs2_addr_ex,
                      rd_addr_mem, reg_write_mem,
                      rd_addr_wb, reg_write_wb,
                      
                      forward_a, forward_b);
    input wire [1:0] rs1_addr_ex;
	input wire [1:0] rs2_addr_ex;
    input wire [1:0] rd_addr_mem;
    input wire reg_write_mem;
    input wire [1:0] rd_addr_wb;
    input wire reg_write_wb;

    output wire [1:0] forward_a;
    output wire [1:0] forward_b;

    // 0 -> just rs1, rs2. No forwarding
    // 1 -> from mem. dist 1
    // 2 -> from wb. dist 2
    assign forward_a = ((rs1_addr_ex == rd_addr_mem) && reg_write_mem) ? 1 : 
                       (((rs1_addr_ex == rd_addr_wb) && reg_write_wb) ? 2 : 0);
    assign forward_b = ((rs2_addr_ex == rd_addr_mem) && reg_write_mem) ? 1 : 
                       (((rs2_addr_ex == rd_addr_wb) && reg_write_wb) ? 2 : 0);

endmodule
