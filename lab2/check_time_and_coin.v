`include "vending_machine_def.v"

	

module check_time_and_coin(
	clk,
	reset_n,
	i_input_coin,
	i_select_item,
	o_available_item,
	
	return_flag,
	wait_time
	);

	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input [`kNumItems-1:0] o_available_item;

	output reg return_flag;
	output reg [31:0] wait_time;

	reg [`kTotalBits-1:0] tmp_total;


	// initiate values
	initial begin
		return_flag <= 'd0;
		wait_time <= 'd10;
	end

	// update waiting time
	always @(i_input_coin, i_select_item) begin
		if (i_input_coin != 0)
		    wait_time = 10;
		if (i_select_item & o_available_item)
			wait_time = 10;
	end

	always @(*) begin
		if ($signed(wait_time) <= 0) return_flag=1; else return_flag=0;
	end
	// always @(*) begin
	// 	// TODO: 실제로 current_total 바꾸는 것은, calculate_current_state 모듈에서 해야함
	// 	// TODO: 직접 1000원을 빼주느게 아니라, coin_value에 해당하는 값으로 빼주기!
	// 	if (($signed(wait_time) <= 0)) begin
	// 		tmp_total = current_total;

	// 		if (tmp_total >= 1000) begin
	// 			tmp_total = tmp_total - 1000;
	// 			o_return_coin[`kNumCoins-1] = 1;
	// 			end
	// 		else
	// 			o_return_coin[`kNumCoins-1] = 0;

	// 		if (tmp_total >= 500) begin
	// 			tmp_total = tmp_total - 500;
	// 			o_return_coin[`kNumCoins-2] = 1;
	// 			end
	// 		else
	// 			o_return_coin[`kNumCoins-2] = 0;

	// 		if (tmp_total >= 100) begin
	// 			tmp_total = tmp_total - 100;
	// 			o_return_coin[`kNumCoins-3] = 1;
	// 			end
	// 		else
	// 			o_return_coin[`kNumCoins-3] = 0;

	// 		end
	// 	else
	// 		o_return_coin = 0;
	// end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// NOTE: reset_n 은 0 일 때 reset 하는 거임!
			wait_time <= 10;
		end
		else begin
		    // TODO: output reg o_return_coin 도 여기서 해야하나?
			wait_time <= wait_time-1;
		end
	end
endmodule 