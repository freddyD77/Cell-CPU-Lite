module singlePrec(clk, ra, rb, rc, opcode11, opcode10, opcode8, opcode4, immediate10, immediate8, pipe6out, pipe7out, addr_rt, reset, flush);
    input			clk, reset, flush;
    input [0:127]		ra, rb, rc; 
    output logic [0:138] 	pipe6out, pipe7out;
    logic [0:138]		pipe1, pipe2, pipe3, pipe4, pipe5, pipe6, result;
    input [0:10]		opcode11;
    input [0:9]			opcode10;
    input [0:7]			opcode8;
    input [0:3]			opcode4;
    input [0:9]			immediate10;
    logic [0:7]			scale1, scale2;
    input [0:7]			immediate8;
    input [0:6]			addr_rt;
    integer			i;
    
    always_ff @(posedge clk) begin
	if(reset)begin
		pipe1 <= 0;
		pipe2 <= 0;
		pipe3 <= 0;
		pipe4 <= 0;
		pipe5 <= 0;
		pipe6 <= 0;
		pipe6out <= 0;
		pipe7out <= 0;
	end else begin
		pipe1 <= result;
		pipe2 <= (flush) ? 0 : pipe1;
		pipe3 <= pipe2;
		pipe4 <= pipe3;
		pipe5 <= pipe4;
		if(pipe5[128:130] == 3'd6)
		    pipe6out <= pipe5;
		else
		    pipe6out <= 0;
		pipe6 <= pipe5;
		if(pipe6[128:130] == 3'd7)
		    pipe7out <= pipe6;
		else
		    pipe7out <= 0;
	end
    end

    always_comb begin
	scale1 = 155 - immediate8;
	scale2 = 173 - immediate8;
 
	result[128:130] = 3'd6;
	result[131] = 1'b1;
	result[132:138] = addr_rt;

	case(opcode11)
	    11'b01111000100:begin//multiply			good
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = $signed(ra[((2*i)+1)*16 +:16]) * $signed(rb[((2*i)+1)*16 +:16]);
				result[128:130] = 3'd7;
				end
	    11'b01111001100:begin//multiply unsigned		good
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = ra[((2*i)+1)*16 +:16] * rb[((2*i)+1)*16 +:16];
				result[128:130] = 3'd7;
				end
	    11'b01111000101:begin//multiply high		good
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = ($signed(ra[2*i*16 +:16]) * $signed(rb[((2*i)+1)*16 +:16])) << 16;
				result[128:130] = 3'd7;
				end
	    11'b01011000100://floating add
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = shortreal'(ra[i*32 +:32]) + shortreal'(rb[i*32 +:32]);
	    11'b01011000101://floating subtract
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = shortreal'(ra[i*32 +:32]) - shortreal'(rb[i*32 +:32]);
	    11'b01011000110://floating mult
			    for (i=0; i<4; i=i+1) result[i*32 +:32] = shortreal'(ra[i*32 +:32]) * shortreal'(rb[i*32 +:32]);

	    11'b01111000010:begin//Floating Compare Equal
			    for (i=0; i<4; i=i+1) begin
				if(shortreal'(ra[i*32 +:32]) == shortreal'(ra[i*32 +:32]))
				     result[i*32 +:32] = 32'hFFFFFFFF;
				else 	
			    	     result[i*32 +:32] = 32'h00000000;
			    end
			    end
	    11'b01111001010:begin//Floating Compare Magnitude Equal
			    for (i=0; i<4; i=i+1) begin
				if(shortreal'(ra[i*32 +:31]) == shortreal'(rb[i*32 +:31]))
				     result[i*32 +:32] = 32'hFFFFFFFF;
				else 	
			    	     result[i*32 +:32] = 32'h00000000;
			    end
			    end
	    11'b01011000010:begin//Floating Compare Greater Than
			    for (i=0; i<4; i=i+1) begin
				if(shortreal'(ra[i*32 +:32]) > shortreal'(rb[i*32 +:32]))
				     result[i*32 +:32] = 32'hFFFFFFFF;
				else 	
			    	     result[i*32 +:32] = 32'h00000000;
			    end
			    end
	    11'b01011001010:begin//Floating Compare Magnitude Greater Than
			    for (i=0; i<4; i=i+1) begin
				if(shortreal'(ra[i*32 +:31]) > shortreal'(rb[i*32 +:31]))
				     result[i*32 +:32] = 32'hFFFFFFFF;
				else 	
			    	     result[i*32 +:32] = 32'h00000000;
			    end
			    end

	    default:begin	case(opcode10)
				 10'b0111011010://Convert Signed Integer to Floating	//need to add some kind of saturation
				    for (i=0; i<4; i=i+1) begin
					if($signed(scale1) < 0)
					     result[i*32 +:32] = 32'hxxxxxxxx;
					else 	
				    	     result[i*32 +:32] = shortreal'($signed(ra[i*32 +:32])) / shortreal'(2 ** scale1);
				    end
			    	10'b0111011000://Convert Floating to Signed Integer	//need to add some kind of saturation
				    for (i=0; i<4; i=i+1) begin
					if($signed(scale2) < 0)
					     result[i*32 +:32] = 32'hxxxxxxxx;
					else 	
				    	     result[i*32 +:32] = $signed(int'(shortreal'(ra[i*32 +:32]) * shortreal'(2 ** scale2)));
				    end
			    	10'b0111011011://Convert Unsigned Integer to Floating	//need to add some kind of saturation
				    for (i=0; i<4; i=i+1) begin
					if($signed(scale1) < 0)
					     result[i*32 +:32] = 32'hxxxxxxxx;
					else 	
				    	     result[i*32 +:32] = shortreal'(ra[i*32 +:32]) / shortreal'(2 ** scale1);
				    end
			    	10'b0111011001://Convert Floating to Unsigned Integer	//need to add some kind of saturation
				    for (i=0; i<4; i=i+1) begin
					if($signed(scale2) < 0)
					     result[i*32 +:32] = 32'hxxxxxxxx;
					else 	
				    	     result[i*32 +:32] = int'(shortreal'(ra[i*32 +:32]) * shortreal'(2 ** scale2));
				    end
				default:begin
						case(opcode8)
							8'b01110100: begin//multiply immediate	good
							    for (i=0; i<4; i=i+1) result[i*32 +:32] = $signed(ra[((2*i)+1)*16 +:16]) * $signed(immediate10);
								result[128:130] = 3'd7;
								end
							8'b01110101:begin//multiply immediate	good
							    for (i=0; i<4; i=i+1) result[i*32 +:32] = $signed(ra[((2*i)+1)*16 +:16]) * $signed(immediate10);
								result[128:130] = 3'd7;
								end
							default:begin	case(opcode4)
										4'b1100:begin//multiply add
										    for (i=0; i<4; i=i+1) result[i*32 +:32] = ($signed(ra[((2*i)+1)*16 +:16]) * $signed(rb[((2*i)+1)*16 +:16])) + $signed(rc[i*32 +:32]);
											result[128:130] = 3'd7;
											end
										4'b1110://floating multiply add	//need to add some kind of saturation
										    for (i=0; i<4; i=i+1) result[i*32 +:32] = (shortreal'(ra[i*32 +:32]) * shortreal'(rb[i*32 +:32])) + shortreal'(rc[i*32 +:32]);
										4'b1111://floating multiply subtract	//need to add some kind of saturation
										    for (i=0; i<4; i=i+1) result[i*32 +:32] = (shortreal'(ra[i*32 +:32]) * shortreal'(rb[i*32 +:32])) - shortreal'(rc[i*32 +:32]);
										default:
										    result = 0;
										    
									endcase
								end
						endcase
					end
				endcase
		end

	endcase
    end 
endmodule



