module branch(clk, rt, reset, addr_rt, opcode9, pipe, PCin, predictPCin, predictIn, PCpipe, immediate16);
    input			clk, reset, predictIn;
    input [0:31]		PCin, predictPCin;
    input [0:127]		rt;
    input [0:6]			addr_rt;
    output logic [0:138] 	pipe;
    output logic [0:65]		PCpipe;
    input [0:8]			opcode9;
    input [0:15]		immediate16;
    logic [0:138] 		result;
    logic [0:65]		PCout;
    
    always_ff @(posedge clk) begin
	if(reset) begin
		pipe <= 0;
		PCpipe <= 0;
	end else begin
		pipe <= result;
		PCpipe <= PCout;
	end
    end

    always_comb begin
	result[128:130] = 3'd1;
	result[131] = 1'b1;
	result[132:138] = addr_rt;

	PCout[32] = 1;
	PCout[33:64] = PCin;
	PCout[65] = 0;
	
 			
	case(opcode9)
	    9'b001100100:begin//branch relative GOOD
				result = 0;//need to assign a value
				PCout[0:31] = PCin + $signed({{14{immediate16[0]}}, immediate16, 2'b00});
				PCout[65] = (predictIn == 0 | (predictPCin != PCout[0:31])) ? 1 : 0;
			 end
	    9'b001100110:begin//branch relative and set link
				result[32:127] = 0;
				result[0:31] = PCin + 4;
				PCout[0:31] = PCin + $signed({{14{immediate16[0]}}, immediate16, 2'b00});
				PCout[65] = (predictIn == 0 | (predictPCin != PCout[0:31])) ? 1 : 0;
			 end
	    9'b001000000:begin//branch if zero word GOOD
			    if(rt[0:31] == 0)
				     PCout[0:31] = PCin + $signed({{14{immediate16[0]}},{immediate16, 2'b00}});
			    else begin 	
			    	 PCout[0:31] = (PCin + 8) & (32'b1111_1111_1111_1111_1111_1111_1111_1000);
				     PCout[32] = 0;
			    end
				PCout[65] = ((predictIn != PCout[32]) | (predictPCin != PCout[0:31])) ? 1 : 0;
			    result = 0;//must assign value
			 end
	    9'b001000010:begin//branch if not zero word GOOD
			    if(rt[0:31] != 0)
				     PCout[0:31] = PCin + $signed({{14{immediate16[0]}},{immediate16, 2'b00}});
			    else begin	
			    	 PCout[0:31] = (PCin + 8) & (32'b1111_1111_1111_1111_1111_1111_1111_1000);
				     PCout[32] = 0;
			    end
				PCout[65] = ((predictIn != PCout[32]) | (predictPCin != PCout[0:31])) ? 1 : 0;
			    result = 0;//must assign value
			 end
	    default: begin	    result = 0;
				     PCout = 0;
			end
		
	endcase
    end 
endmodule




