module Cache(
    reset_n, clk,
    in_addr1, in_addr2, // 1 for instruction, 2 for data
    in_read_en1, in_read_en1, // cache 를 읽는지 안 읽는지

    in_store_en1, in_store_en2,
    in_store_word1, in_store_word2,

    in_write_line_en1, in_write_line_en2, // cache에 쓰는지 안쓰는지 (from memory)
    in_write_line1, in_write_line2, // cache에 쓸 data


    out_hit1, out_hit2, out_data1, out_data2
);
    // NOTE: Cache read done
    // TODO: Implement cache write

    input wire reset_n;
    input wire clk;
    input wire [15:0] in_addr1;
    input wire [15:0] in_addr2;
    input wire in_store_en1;
    input wire in_store_en2;
    input wire [15:0] in_store_word1;
    input wire [15:0] in_store_word2;
    input wire in_write_en1;
    input wire in_write_en2;
    input wire [15:0] in_write_line1 [0:3];
    input wire [15:0] in_write_line2 [0:3];

    output wire out_hit1;
    output wire out_hit2;
    output wire [15:0] out_data1;
    output wire [15:0] out_data2;

    wire [11:0] in_tag1;
    wire [1:0] in_idx1;
    wire [1:0] in_bo1;
    wire [11:0] in_tag2;
    wire [1:0] in_idx2;
    wire [1:0] in_bo2;

    reg [11:0] tag [0:3];
    reg valid [0:3];
    reg [15:0] data [0:3][0:3];


    assign in_tag1 = in_addr1[15:4];
    assign in_idx1 = in_addr1[3:2];
    assign in_bo1 = in_addr1[1:0];
    assign in_tag2 = in_addr2[15:4];
    assign in_idx2 = in_addr2[3:2];
    assign in_bo2 = in_addr2[1:0];

    assign out_hit1 = (in_read_en1 || in_store_en1 || in_write_en1) && (tag[in_idx1] == in_tag1) && valid[in_idx1];
    assign out_hit2 = (in_read_en2 || in_store_en2 || in_write_en2) && (tag[in_idx2] == in_tag2) && valid[in_idx2];

    assign out_data1 = data[in_idx1][in_bo1];
    assign out_data2 = data[in_idx2][in_bo2];


    initial begin        
        data[0][0] = 0;
        data[0][1] = 0;
        data[0][2] = 0;
        data[0][3] = 0;
        data[1][0] = 0;
        data[1][1] = 0;
        data[1][2] = 0;
        data[1][3] = 0;
        data[2][0] = 0;
        data[2][1] = 0;
        data[2][2] = 0;
        data[2][3] = 0;
        data[3][0] = 0;
        data[3][1] = 0;
        data[3][2] = 0;
        data[3][3] = 0;

        tag[0] = 0;
        tag[1] = 0;
        tag[2] = 0;
        tag[3] = 0;

        valid[0] = 0;
        valid[1] = 0;
        valid[2] = 0;
        valid[3] = 0;
    end


    always @(posedge reset_n) begin
        data[0][0] <= 0;
        data[0][1] <= 0;
        data[0][2] <= 0;
        data[0][3] <= 0;
        data[1][0] <= 0;
        data[1][1] <= 0;
        data[1][2] <= 0;
        data[1][3] <= 0;
        data[2][0] <= 0;
        data[2][1] <= 0;
        data[2][2] <= 0;
        data[2][3] <= 0;
        data[3][0] <= 0;
        data[3][1] <= 0;
        data[3][2] <= 0;
        data[3][3] <= 0;

        tag[0] <= 0;
        tag[1] <= 0;
        tag[2] <= 0;
        tag[3] <= 0;

        valid[0] <= 0;
        valid[1] <= 0;
        valid[2] <= 0;
        valid[3] <= 0;
    end

    always @(posedge clk) begin
        if(in_write_en1 == 1) begin
            tag[in_idx1] <= in_tag1;
            valid[in_idx1] <= 1;
            data[in_idx1][0] <= in_write_line1[0];
            data[in_idx1][1] <= in_write_line1[1];
            data[in_idx1][2] <= in_write_line1[2];
            data[in_idx1][3] <= in_write_line1[3];
        end
        if(in_write_en2 == 1) begin
            tag[in_idx2] <= in_tag2;
            valid[in_idx2] <= 1;
            data[in_idx2][0] <= in_write_line2[0];
            data[in_idx2][1] <= in_write_line2[1];
            data[in_idx2][2] <= in_write_line2[2];
            data[in_idx2][3] <= in_write_line2[3];
        end
        if(in_store_en1 && out_hit1) begin
            data[in_idx1][in_bo1] <= in_store_word1;
        end
        if(in_store_en2 && out_hit2) begin
            data[in_idx2][in_bo2] <= in_store_word2;
        end
    end

endmodule

