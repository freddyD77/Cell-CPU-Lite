/* Module for Byte unit containing all instruction coded
 * Imagine all the calculations for all the instructions would be done in the first cycle and then just shifted through
 * Things to Note:- 
 * 1. "result", "result_reg" and "result_reg_1" are internal logic since the pipeline depth is 2. "out_data" is output going to 
 * forwarding registers.
*/
module Byte(
  input                 	clk, reset, flush,
  input      	[0:127]    	data_ra, data_rb,
  input      	[0:6]    	addr_rt,
  input      	[0:10]     	opcode,
  output logic 	[0:138]    	out_data);

  logic [0:138] result, result_reg, result_reg_1;
  logic [0:9]	temp;

  always_ff @(posedge clk) begin
    if(reset) begin
	  result_reg <= 0;
	  result_reg_1 <= 0;
	  out_data <= 0;
	end
	else begin
	  result_reg <= result;
	  result_reg_1 <= (flush) ? 0 : result_reg;
	  out_data <= result_reg_1;
	end
  end

  always_comb begin
	integer i,j;
	result[128:130] = 3'd4;
	result[131] = 1'b1;
	result[132:138] = addr_rt;
	case(opcode)
	    11'b01010110100: begin // Count Ones in bytes
		  for(i = 0; i < 16; i++) begin
			temp = 0;
			for(j = 0; j < 8; j++) begin
			  if(data_ra[(i * 8) + j] == 1'b1) temp = temp + 1;
			end
			result[(i * 8) +:8] = temp[2:9];
		  end
		end
		11'b00011010011: begin // Average Bytes
		  for(i = 0; i < 16; i++) begin
			temp = {{2'b00}, data_ra[(i * 8) +:8]} + {{2'b00}, data_rb[(i * 8) +:8]} + 1;
			temp = temp >> 1;
			result[(i * 8) +:8] = temp[2:9];
		  end
		end
		11'b00001010011: begin // Absolute Differences of bytes
		  for(i = 0; i < 16; i++) result[(i * 8) +:8] = (data_rb[(i * 8) +:8] > data_ra[(i * 8) +:8]) ? (data_rb[(i * 8) +:8] - data_ra[(i * 8) +:8]) 
									: (data_ra[(i * 8) +:8] - data_rb[(i * 8) +:8]);
		end
		11'b01001010011: begin // Sum Bytes into Halfwords
		  j = 0;
		  for(i = 0; i < 4; i++) begin
			result[(i * 32) +:16] = data_rb[(j * 32) +:8] + data_rb[((j * 32) + 8) +:8] + data_rb[((j * 32)+16) +:8] + data_rb[((j * 32) + 24) +:8];
			result[((i * 32) + 16) +:16] = data_ra[(j * 32) +:8] + data_ra[((j * 32) + 8) +:8] + data_ra[((j * 32)+16) +:8] + data_ra[((j * 32) + 24) +:8];
			j = j + 1;
		  end
		end

		default: result = 0;
	endcase
  end

endmodule
