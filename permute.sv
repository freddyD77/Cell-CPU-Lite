module permute(clk, ra, rb, opcode11, immediate7, WBpipe3, addr_rt, reset);
    input			clk, reset;
    input [0:6]			addr_rt;
    input [0:127]		ra, rb;
    output logic [0:138] 	WBpipe3; 
    logic [0:138] 		result, pipe1, pipe2;
    input [0:10]		opcode11;
    input [0:6]			immediate7;
    integer i;
    
    always_ff @(posedge clk) begin
	if(reset) begin
		pipe1 <= 0;
		pipe2 <= 0;
		WBpipe3 <= 0;
	end else begin
		pipe1 <= result;
		pipe2 <= pipe1;
		WBpipe3 <= pipe2;
	end
    end

    always_comb begin

	result[128:130] = 3'd3;
	result[131] = 1'b1;
	result[132:138] = addr_rt;
		
	case(opcode11)
	    11'b00110110010:begin//gather bits from bytes GOOD
				result[0:15] = 0;
				result[32:127] = 0;
				result[16:31] = {ra[7], ra[15], ra[23], ra[31], ra[39], ra[47], ra[55], ra[63], ra[71], ra[79], ra[87], ra[95], ra[103], ra[111], ra[119], ra[127]};
			    end
	    11'b00110110000:begin//gather bits from word GOOD
				result[0:27] = 0;
				result[32:127] = 0;
				result[28:31] = {ra[31], ra[63], ra[95], ra[127]};
			    end
	    11'b00111011111://shift left quadword by bytes GOOD
			    if(rb[27:31] > 15)
				    result[0:127] = 0;
			    else 	
			    	result[0:127] = ra << 8*rb[27:31];
	    11'b00111111111://shift left quadword by bytes immediate GOOD
			    if(immediate7[2:6] > 15)
				     result[0:127] = 0;
			    else 	
			    	     result[0:127] = ra << 8*immediate7[2:6];
	    11'b00111011100://rotate quadword by bytes GOOD
			    result[0:127] = (ra << 8*rb[28:31]) | (ra >> 8*(16-rb[28:31]));
	    11'b00111111100://rotate quadword by bytes immediate GOOD
			    result[0:127] = (ra << 8*immediate7[2:6]) | (ra >> 8*(16-immediate7[2:6]));
	    11'b00111011101://rotate and mask quadword by bytes GOOD
			    if((0-rb[0:31])%32 < 16)
				     result[0:127] = ra >> ((0-rb[0:31])%32)*8;
			    else 	
			    	     result[0:127] = 0;
	    11'b00111111101://rotate and mask quadword by bytes immediate GOOD
			    if((0-immediate7)%32 < 16)
				     result[0:127] = ra >> ((0-immediate7)%32)*8;
			    else 	
			    	     result[0:127] = 0;
	    default:	    result = 0;
		
	endcase

	
    end 
endmodule




