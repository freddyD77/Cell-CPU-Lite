/* Module for Simple Fixed 1 unit containing all instruction coded
 * Imagine all the calculations for all the instructions would be done in the first cycle and then just shifted through
 * Things to Note:- 
 * 1. "result" and "result_reg" are internal logic since the pipeline depth is 2. "out_data" is output going to 
 * forwarding registers.
*/
module SimpleFixed1(
  input                 	clk, reset, flush,
  input      	[0:127]    	data_ra, data_rb,
  input      	[0:17]     	immediate,
  input      	[0:6]    	addr_rt,
  input      	[0:10]     	opcode,
  output logic 	[0:138]    	out_data);
  
  logic [0:138] 		result, result_reg;
  logic [0:15]			temp16a, temp16b, temp16c, temp16d;
  logic [0:7]			temp8a, temp8b, temp8c, temp8d;
  logic [0:3]			temp4a, temp4b, temp4c, temp4d;
  
  
  always_ff @(posedge clk) begin
	if(reset) begin
	  result_reg <= 0;
	  out_data <= 0;
	end
	else begin
      result_reg <= result;
      out_data <= (flush) ? 0 : result_reg;
	end
  end

  always_comb begin
    integer i, j;
    result[128:130] = 3'd2;
	result[131] = 1'b1;
	result[132:138] = addr_rt;
    case(opcode) // RR format with 11 bit opcode
        11'b00011001000: begin // Add Halfword
          for(i = 0; i < 8 ; i++) result[(i * 16) +:16] = $signed(data_ra[(i * 16) +:16]) + $signed(data_rb[(i * 16) +:16]);
        end
        11'b00011000000: begin // Add word
          for(i = 0; i < 4 ; i++) result[(i * 32) +:32] = $signed(data_ra[(i * 32) +:32]) + $signed(data_rb[(i * 32) +:32]);
        end
        11'b00001001000: begin // Subtract from halfword
          for(i = 0; i < 8 ; i++) result[(i * 16) +:16] = $signed(data_rb[(i * 16) +:16]) - $signed(data_ra[(i * 16) +:16]);
        end
        11'b00001000000: begin // Subtract from word
          for(i = 0; i < 4 ; i++) result[(i * 32) +:32] = $signed(data_rb[(i * 32) +:32]) - $signed(data_ra[(i * 32) +:32]);
        end
        11'b01010100101: begin // Count Leading Zeroes
		  result[0:127] = 128'd0;
          for(i = 0; i < 4; i++) begin
			for(j = 0; j < 32; j++) begin
			  if(data_ra[(i * 32) + j] == 0) result[(i * 32) +:32] = result[(i * 32) +:32] + 1;
			  else break;
			end
		  end
        end
        11'b00110110110: begin // Form Select mask for bytes
          for(i = 0; i < 16 ; i++) begin
            if(data_ra[16 + i] == 0)
			  result[(i * 8) +:8] = 8'h00;
			else
			  result[(i * 8) +:8] = 8'hff;
          end
        end
        11'b00110110101: begin // Form Select mask for halfword
          for(i = 0; i < 8 ; i++) begin
            if(data_ra[24 + i] == 0)
			  result[(i * 16) +:16] = 16'h0000;
			else
			  result[(i * 16) +:16] = 16'hffff;
          end
        end
        11'b00110110100: begin // Form Select mask for word
           for(i = 0; i < 4 ; i++) begin
            if(data_ra[28 + i] == 0)
			  result[(i * 32) +:32] = 32'h0000_0000;
			else
			  result[(i * 32) +:32] = 32'hffff_ffff;
          end
        end
        11'b00011000001: begin // and
		  result[0:127] = data_ra & data_rb;
        end
        11'b00001000001: begin // or
          result[0:127] = data_ra | data_rb;
        end
        11'b00111110000: begin // or across
		  result[96:127] = data_ra[0:31] | data_ra[32:63] | data_ra[64:95] | data_ra[96:127];
		  result[0:95] = 0;
        end
        11'b01001000001: begin // xor
		  result[0:127] = data_ra ^ data_rb;
        end
		11'b01111010000: begin // Compare Equal Byte
		  for(i = 0; i < 16; i++) result[(i * 8) +:8] = (data_ra[(i * 8) +:8] == data_rb[(i * 8) +:8]) ? 8'hff : 8'h00;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01111001000: begin // Compare Equal Halfword
		  for(i = 0; i < 8; i++) result[(i * 16) +:16] = (data_ra[(i * 16) +:16] == data_rb[(i * 16) +:16]) ? 16'hffff : 16'h0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01111000000: begin // Compare Equal Word
		  for(i = 0; i < 4; i++) result[(i * 32) +:32] = (data_ra[(i * 32) +:32] == data_rb[(i * 32) +:32]) ? 32'hffff_ffff : 32'h0000_0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01001010000: begin // Compare Greater than Byte
		  for(i = 0; i < 16; i++) result[(i * 8) +:8] = ($signed(data_ra[(i * 8) +:8]) > $signed(data_rb[(i * 8) +:8])) ? 8'hff : 8'h00;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01001001000: begin // Compare Greater than Halfword
		  for(i = 0; i < 8; i++) result[(i * 16) +:16] = ($signed(data_ra[(i * 16) +:16]) > $signed(data_rb[(i * 16) +:16])) ? 16'hffff : 16'h0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01001000000: begin // Compare Greater than Word
		  for(i = 0; i < 4; i++) result[(i * 32) +:32] = ($signed(data_ra[(i * 32) +:32]) > $signed(data_rb[(i * 32) +:32])) ? 32'hffff_ffff : 32'h0000_0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01011010000: begin // Compare Logical Greater than Byte
		  for(i = 0; i < 16; i++) result[(i * 8) +:8] = (data_ra[(i * 8) +:8] > data_rb[(i * 8) +:8]) ? 8'hff : 8'h00;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01011001000: begin // Compare Logical Greater than Halfword
		  for(i = 0; i < 8; i++) result[(i * 16) +:16] = (data_ra[(i * 16) +:16] > data_rb[(i * 16) +:16]) ? 16'hffff : 16'h0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
		11'b01011000000: begin // Compare Logical Greater than Word
		  for(i = 0; i < 4; i++) result[(i * 32) +:32] = (data_ra[(i * 32) +:32] > data_rb[(i * 32) +:32]) ? 32'hffff_ffff : 32'h0000_0000;
		  result[128:130] = 3'd2;
		  result[131] = 1'b1;
		end
        default: begin

          case(opcode[0:8]) // RI16 format with 9 bit opcode
            9'b010000011: begin // Immediate Load Half word
              for(i = 0; i < 8; i++) result[(i * 16) +:16] = immediate[2:17];
			  result[128:130] = 3'd2;
		  	  result[131] = 1'b1;
            end
			9'b010000010: begin // Immediate Load halfword upper
              for(i = 0; i < 4; i++) result[(i * 32) +:32] = {immediate[2:17], 16'b0000};
			  result[128:130] = 3'd2;
		  	  result[131] = 1'b1;
            end
			9'b010000001: begin // Immediate Load word
              for(i = 0; i < 4; i++) result[(i * 32) +:32] = {{8{immediate[2]}}, immediate[2:17]};
			  result[128:130] = 3'd2;
		  	  result[131] = 1'b1;
            end
			9'b011000001: begin // Immediate Load halfword lower
              for(i = 0; i < 8; i++) result[(i * 16) +:16] = immediate[2:17];
			  result[128:130] = 3'd2;
		  	  result[131] = 1'b1;
            end
			9'b001100101: begin // Form select mask for bytes immediate
              for(i = 0; i < 8; i++) result[(i * 16) +:16] = immediate[2:17];
			  result[128:130] = 3'd2;
		  	  result[131] = 1'b1;
            end
			default: begin

			  case(opcode[0:7]) // RI10 format with 8 bit opcode
				8'b00011101: begin // Add Halfword immediate
				  for(i = 0; i < 8 ; i++) result[(i * 16) +:16] = $signed(data_ra[(i * 16) +:16]) + $signed(immediate[1:10]);
          		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00011100: begin // Add word immediate
				  for(i = 0; i < 4 ; i++) result[(i * 32) +:32] = $signed(data_ra[(i * 32) +:32]) + $signed(immediate[1:10]);
          		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00001101: begin // Subtract from Halfword immediate
				  for(i = 0; i < 8 ; i++) result[(i * 16) +:16] = $signed(immediate[1:10]) - $signed(data_ra[(i * 16) +:16]);
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00001100: begin // Subtract from word immediate
				  for(i = 0; i < 4 ; i++) result[(i * 32) +:32] = $signed(immediate[1:10]) - $signed(data_ra[(i * 32) +:32]);
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00010110: begin // and byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = data_ra[(i * 8) +:8] & (immediate[1:10] & 16'h00ff);
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00010101: begin // and halfword immediate
				  for(i = 0; i < 8; i++) result[(i * 16) +:16] = data_ra[(i * 16) +:16] & {{6{immediate[1]}}, immediate[1:10]};
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00010100: begin // and word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = data_ra[(i * 32) +:32] & {{22{immediate[1]}}, immediate[1:10]};
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00000110: begin // or byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = data_ra[(i * 8) +:8] | (immediate[1:10] & 16'h00ff);
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00000101: begin // or halfword immediate
				  for(i = 0; i < 8; i++) result[(i * 16) +:16] = data_ra[(i * 16) +:16] | {{6{immediate[1]}}, immediate[1:10]};
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b00000100: begin // or word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = data_ra[(i * 32) +:32] | {{22{immediate[1]}}, immediate[1:10]};
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01000110: begin // xor byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = data_ra[(i * 8) +:8] ^ (immediate[1:10] & 16'h00ff);
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01000101: begin // xor halfword immediate
				  for(i = 0; i < 8; i++) begin
				  	result[(i * 16) +:16] = data_ra[(i * 16) +:16] ^ {{6{immediate[1]}}, immediate[1:10]};
				  end
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01000100: begin // xor word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = data_ra[(i * 32) +:32] ^ {{22{immediate[1]}}, immediate[1:10]};
				  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01111110: begin // Compare Equal Byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = (data_ra[(i * 8) +:8] == immediate[3:10]) ? 8'hff : 8'h00;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01111101: begin // Compare Equal Halfword immediate
				  for(i = 0; i < 8; i++) result[(i * 16) +:16] = (data_ra[(i * 16) +:16] == {{6{immediate[1]}}, immediate[1:10]}) ? 16'hffff : 16'h0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01111100: begin // Compare Equal Word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = (data_ra[(i * 32) +:32] == {{22{immediate[1]}}, immediate[1:10]}) ? 32'hffff_ffff : 32'h0000_0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01001110: begin // Compare Greater than Byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = ($signed(data_ra[(i * 8) +:8]) > immediate[3:10]) ? 8'hff : 8'h00;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01001101: begin // Compare Greater than Halfword immediate
				  for(i = 0; i < 8; i++) result[(i * 16) +:16] = ($signed(data_ra[(i * 16) +:16]) > {{6{immediate[1]}}, immediate[1:10]}) ? 16'hffff : 16'h0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01001100: begin // Compare Greater than Word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = ($signed(data_ra[(i * 32) +:32]) > {{22{immediate[1]}}, immediate[1:10]}) ? 32'hffff_ffff : 32'h0000_0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01011110: begin // Compare Logical Greater than Byte immediate
				  for(i = 0; i < 16; i++) result[(i * 8) +:8] = (data_ra[(i * 8) +:8] > immediate[3:10]) ? 8'hff : 8'h00;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01011101: begin // Compare Logical Greater than Halfword immediate
				  for(i = 0; i < 8; i++) result[(i * 16) +:16] = (data_ra[(i * 16) +:16] > {{6{immediate[1]}}, immediate[1:10]}) ? 16'hffff : 16'h0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				8'b01011100: begin // Compare Logical Greater then Word immediate
				  for(i = 0; i < 4; i++) result[(i * 32) +:32] = (data_ra[(i * 32) +:32] > {{22{immediate[1]}}, immediate[1:10]}) ? 32'hffff_ffff : 32'h0000_0000;
		  		  result[128:130] = 3'd2;
		  		  result[131] = 1'b1;
				end
				default:begin // RI18 format - Immediate load Address with 7 bit opcode

				  case(opcode[0:6])
					7'b0100001: begin
				  	  for(i = 0; i < 4; i++) result[(i * 32) +:32] = {{14'd0}, immediate};
				      result[128:130] = 3'd2;
		  		      result[131] = 1'b1;
					end
					default: result = 0;
				  endcase
				end
			  endcase

			end
          endcase

        end
    endcase
  end
endmodule


