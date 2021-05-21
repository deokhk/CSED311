module Bank(
    reset_n, clk,
    tag_addr, idx_addr, 
    line_in, bank_write_en,

    tag_bank, valid_bank, // for checking hit
    line_bank, dirty_bank
);

	input wire clk, reset_n;
    input wire [11:0] tag_addr;
    input wire [1:0] idx_addr;
    input wire [15:0] line_in [0:3];
    input wire bank_write_en;

    output wire [11:0] tag_bank;
    output wire valid_bank;
    output wire [15:0] line_bank [0:3];
    output wire dirty_bank;

    reg [11:0] tag [0:3];
    reg [15:0] data [0:3][0:3];
    reg is_valid [0:3];
    reg is_dirty [0:3];

    assign tag_bank = tag[idx_addr];
    assign valid_bank = is_valid[idx_addr];
    assign dirty_bank = is_dirty[idx_addr];
    assign line_bank = data[idx_addr][0:3];

    integer i, j;
    initial begin
        for (i=0; i<4; i+=1) begin
            tag[i] = 0;
            is_valid[i] = 0;
            is_dirty[i] = 0;

            for (j=0; j<4; j+=1) begin
                data[i][j] = 0;
            end
        end
    end

	always @(posedge reset_n) begin
        for (i=0; i<4; i+=1) begin
            tag[i] <= 0;
            is_valid[i] <= 0;
            is_dirty[i] <= 0;

            for (j=0; j<4; j+=1) begin
                data[i][j] <= 0;
            end
        end
	end


    

    assign aaa = (aaa_enable) ? aaa : 0;
    always @(posedge clk) begin
        if (~~~)
        aaa_enable = true;
    end
    always @(*) begin
        write
    end


    always @(posedge clk) begin
        if (reg_write_signal) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule





module Cache(
    reset_n, clk, addr,
    cache_write_en,
    cache_write_line,

    hit_cache,
    evict_write_back_line,
    evict_write_back_addr,
    evict_write_back_require
);
    input wire reset_n;
    input wire clk;
    input wire [15:0] addr;
    input wire cache_write_en; // miss난 이후 memory로부터 가져온 값을 cache에 쓰기 위함.
    input wire [15:0] cache_write_line [0:3];

    wire [12:0] tag;
    wire [1:0] idx;
    wire [1:0] bo;
    wire [15:0] line_in [0:3]; // bank에 써질 애들.
    wire bank_write_en0;
    wire bank_write_en1;

    wire [12:0] tag_bank0;
    wire valid_bank0;
    wire [15:0] line_bank0 [0:3];
    wire dirty_bank0;

    wire [12:0] tag_bank1;
    wire valid_bank1;
    wire [15:0] line_bank1 [0:3];
    wire dirty_bank1;

    wire hit_bank0;
    wire hit_bank1;

    wire is_dirty_write_line; 

    reg [15:0] dirty_line [0:3]; // evict && dirty 인 line. memory 에 write back 되엉야 함.
    reg recently_used_bank [0:3];

    output wire hit_cache;
    output wire [15:0] evict_write_back_line [0:3]; // memory 에 쓸, write back 해야할 line
    output wire [15:0] evict_write_back_addr; // 그 주소
    output wire evict_write_back_require; // memory 에 write back 해야한다고 말하는 signal


    Bank bank0 (
        .reset_n(reset_n), .clk(clk),
        .tag_addr(tag), .idx_addr(idx), 
        .line_in(line_in), .bank_write_en(bank_write_en0),

        .tag_bank(tag_bank0), .valid_bank(valid_bank0), // for checking hit
        .line_bank(line_bank0), .dirty_bank(dirty_bank0)
    );

    Bank bank1 (
        .reset_n(reset_n), .clk(clk),
        .tag_addr(tag), .idx_addr(idx), 
        .line_in(line_in), .bank_write_en(bank_write_en1),

        .tag_bank(tag_bank1), .valid_bank(valid_bank1), // for checking hit
        .line_bank(line_bank1), .dirty_bank(dirty_bank1)
    );

    assign tag = addr[15:4];
    assign idx = addr[3:2];
    assign bo = addr[1:0];
    
    assign hit_bank0 = (tag == tag_bank0) && valid_bank0;
    assign hit_bank1 = (tag == tag_bank1) && valid_bank1;
    assign hit_cache = (hit_bank0 || hit_bank1);

    // 우리가 Memory에서 가져온 data를 몇 번 bank에 넣을거냐?
    assign write_bank_num = (!valid_bank0 && !valid_bank1) ? 0 :
                            (!valid_bank0 && valid_bank1) ? 0 :
                            (valid_bank0 && !valid_bank1) ? 1 :
                            !recently_used_bank[idx];
    
    // 현재 우리가 쓰려고 하는 위치의 line이, dirty한 지 여부를 반환.
    assign is_dirty_write_line = (write_bank_num == 0) ? dirty_bank0 : dirty_bank1; 

    // miss && dirty
    // evict된 후 memory에 wb이 되어야 함.
    // 이를 위해, 해당 위치의 line을 backup해두기 위한 signal.
    assign evict_write_back_require = (!hit_cache) && is_dirty_write_line;
    assign evict_write_back_line = dirty_line;
    assign evict_write_back_addr = addr;

    integer i;
    initial begin        
        for(i=0; i<4; i=i+1) begin
            recently_used_bank[i] = 0;
            dirty_line[i] = 0;
        end
    end

    always @(posedge reset_n) begin
        for(i=0; i<4; i=i+1) begin
            recently_used_bank[i] <= 0;
            dirty_line[i] <= 0;
        end
    end

    always @(posedge clk) begin
        if(evict_write_back_require) begin
            dirty_line <= (write_bank_num) ? line_bank1 : line_bank0;
        end
        if(cache_write_en) begin
            if(write_bank_num == 0) begin
                line_bank0[][] <= 
        end
    end

endmodule

