`include "vending_machine_def.v"

	

module check_time_and_coin(
	clk,
	reset_n,
	i_input_coin,
	i_select_item,
	i_trigger_return,
	o_available_item,
	current_total,
	
	o_return_coin,
	wait_time
	);

	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input i_trigger_return;
	input [`kNumItems-1:0] o_available_item;
	input [`kTotalBits-1:0] current_total;

	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	reg [`kTotalBits-1:0] tmp_total;


	// initiate values
	initial begin
		o_return_coin <= 'd0;
		wait_time <= 'd100;
	end

	// update waiting time
	always @(i_input_coin, i_select_item) begin
		if (i_input_coin != 0)
		    wait_time = 100;
		if (i_select_item & o_available_item)
			wait_time = 100;
	end

	always @(*) begin
		// TODO: 실제로 current_total 바꾸는 것은, calculate_current_state 모듈에서 해야함
		if ((wait_time <= 0) || (i_trigger_return)) begin
			tmp_total = current_total;

			if (tmp_total >= 1000) begin
				tmp_total -= 1000;
				o_return_coin[`kNumCoins-1] = 1;
				end;

			if (tmp_total >= 500) begin
				tmp_total -= 500;
				o_return_coin[`kNumCoins-2] = 1;
				end;

			if (tmp_total >= 100) begin
				tmp_total -= 100;
				o_return_coin[`kNumCoins-3] = 1;
				end;
			end;
		else
			o_return_coin = 0;
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// NOTE: reset_n 은 0 일 때 reset 하는 거임!
			o_return_coin = 0;
			wait_time = 100;
		end
		else begin
		    // TODO: output reg o_return_coin 도 여기서 해야하나?
			wait_time = wait_time-1;
		end
	end
endmodule 