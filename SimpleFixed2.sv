/* Module for Simple Fixed 2 unit containing all instruction coded
 * Imagine all the calculations for all the instructions would be done in the first cycle and then just shifted through
 * Things to Note:- 
 * 1. "result", "result_reg" and "result_reg_1" are internal logic since the pipeline depth is 2. "out_data" is output going to 
 * forwarding registers.
 */
module SimpleFixed2(
  input                 	clk, reset, flush,
  input      	[0:127]    	data_ra, data_rb,
  input      	[0:6]      	immediate,
  input      	[0:6]    	addr_rt,
  input      	[0:10]     	opcode,
  output logic 	[0:138]     out_data);

  logic [0:138] result, result_reg, result_reg_1;
  logic [0:15]	temp16, temp16_reg;
  logic [0:31]	temp32, temp32_reg;

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
	integer i, j;
	result[128:130] = 3'd4;
	result[131] = 1'b1;
	result[132:138] = addr_rt;
	case(opcode)
		// RR type instructions
		11'b00001011111: begin // Shift left halfword
		  for(i = 0; i < 8 ; i++) begin
			temp16 = data_rb[(i * 16) +:16] & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg << temp16 : 16'h0000;
		  end
		end
		11'b00001011011: begin // Shift left word
		  for(i = 0; i < 4 ; i++) begin
			temp32 = data_rb[(i * 32) +:32] & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg << temp32 : 32'h0000_0000;
		  end
		end
		11'b00001011100: begin // Rotate halfword
		  for(i = 0; i < 8 ; i++) begin
			temp16 = data_rb[(i * 16) +:16] & 16'h000f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16_reg << temp16) | (temp16_reg >> (16 - temp16));
		  end
		end
		11'b00001011000: begin // Rotate word
		  for(i = 0; i < 4 ; i++) begin
			temp32 = data_rb[(i * 32) +:32] & 32'h0000_001f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32_reg << temp32) | (temp32_reg >> (32 - temp32));
		  end
		end
		11'b00001011101: begin // Rotate and mask halfword
		  for(i = 0; i < 8 ; i++) begin
			temp16 = (0 - data_rb[(i * 16) +:16]) & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg >> temp16 : 16'h0000;
		  end
		end
		11'b00001011001: begin // Rotate and mask word
		  for(i = 0; i < 4 ; i++) begin
			temp32 = (0 - data_rb[(i * 32) +:32]) & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg >> temp32 : 32'h0000_0000;
		  end
		end
		11'b00001011110: begin // Rotate and mask algebraic halfword
		  for(i = 0; i < 8 ; i++) begin
			temp16 = (0 - data_rb[(i * 16) +:16]) & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg >>> temp16 : 16'h0000;
		  end
		end
		11'b00001011010: begin // Rotate an mask algebraic word
		  for(i = 0; i < 4 ; i++) begin
			temp32 = data_rb[(i * 32) +:32] & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg >>> temp32 : 32'h0000_0000;
		  end
		end
		// RI7 type instructions
		11'b00001111111: begin // Shift left halfword immediate
		  for(i = 0; i < 8 ; i++) begin
			temp16 = {{9{immediate[0]}}, immediate} & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg << temp16 : 16'h0000;
		  end
		end
		11'b00001111011: begin // Shift left word immediate
		  for(i = 0; i < 4 ; i++) begin
			temp32 = {{25{immediate[0]}}, immediate} & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg << temp32 : 32'h0000_0000;
		  end
		end
		11'b00001111100: begin // Rotate halfword immediate
		  for(i = 0; i < 8 ; i++) begin
			temp16 = {{9{immediate[0]}}, immediate} & 16'h000f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16_reg << temp16) | (temp16_reg >> (16 - temp16));;
		  end
		end
		11'b00001111000: begin // Rotate word immediate
		  for(i = 0; i < 4 ; i++) begin
			temp32 = {{25{immediate[0]}}, immediate} & 32'h0000_001f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32_reg << temp32) | (temp32_reg >> (32 - temp32));;
		  end
		end
		11'b00001111101: begin // Rotate and mask halfword immediate
		  for(i = 0; i < 8 ; i++) begin
			temp16 = (0 - {{9{immediate[0]}}, immediate}) & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg >> temp16 : 16'h0000;
		  end
		end
		11'b00001111001: begin // Rotate and mask word immediate
		  for(i = 0; i < 4 ; i++) begin
			temp32 = (0 - {{25{immediate[0]}}, immediate}) & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg >> temp32 : 32'h0000_0000;
		  end
		end
		11'b00001111110: begin // Rotate and mask algebraic halfword immediate
		  for(i = 0; i < 8 ; i++) begin
			temp16 = (0 - {{9{immediate[0]}}, immediate}) & 16'h001f;
			temp16_reg = data_ra[(i * 16) +:16];
			result[(i * 16) +:16] = (temp16 < 16) ? temp16_reg >>> temp16 : 16'h0000;
		  end
		end
		11'b00001111010: begin // Rotate and mask algebraic word immediate
		  for(i = 0; i < 4 ; i++) begin
			temp32 = (0 - {{25{immediate[0]}}, immediate}) & 32'h0000_003f;
			temp32_reg = data_ra[(i * 32) +:32];
			result[(i * 32) +:32] = (temp32 < 32) ? temp32_reg >>> temp32 : 32'h0000_0000;
		  end
		end
		default: result = 0;
	endcase
  end

endmodule
