module localstore(clk, ra, rt, addr_rt, opcode9, opcode8, immediate16, immediate10, FWpipe6, PCin, reset);
    input			clk, reset;
    input [0:6]			addr_rt;
    input [0:31]		PCin;
    input [0:127]		ra, rt; 
    output logic [0:138] 	FWpipe6;
    logic [0:1]			wr_en, wr_en_pipe1;
	logic [0:127]		rt_pipe;
    logic [0:138]		memOut, pipe1, pipe2, pipe3, pipe4, pipe5, result;
    logic [0:31]		memAddr, memAddr_pipe1;
    input [0:8]			opcode9;
    input [0:7]			opcode8;
    input [0:15]		immediate16;
    input [0:9]			immediate10;
    // Double Dimension array should suffice as memory, do not require another module
    logic [0:255][0:7] mem;
    // All memory reads and writes will be in always_ff block
    always_ff @(posedge clk) begin
		integer i;
		if(wr_en==2) begin
			for(i = 0; i < 16; i++) mem[memAddr[24:31] + i] <= rt[(i * 8) +:8];
			result <= 0;
		end
		else begin if(wr_en==1) begin
			if(wr_en_pipe1 == 2 & memAddr_pipe1 == memAddr) result[0:127] <= rt_pipe;
			else
				for(i = 0; i < 16; i++) result[(i * 8) +:8] <= mem[memAddr[24:31] + i];
			result[128:130] <= 3'd6;
			result[131] <= 1'b1;
			result[132:138] <= addr_rt;
		end else
			result <= 0;
		end
		
		if(reset)begin
			pipe2 <= 0;
			pipe3 <= 0;
			pipe4 <= 0;
			pipe5 <= 0;
			FWpipe6 <= 0;
			wr_en_pipe1 <= 0;
			memAddr_pipe1 <= 0;
			rt_pipe <= 0;
			for (i=0; i<64; i=i+1) begin 
				mem[4*i] <= 0;
				mem[(4*i)+1] <= 0;
				mem[(4*i)+2] <= 0;
				mem[(4*i)+3] <= i;
			end
		end else begin
			pipe2 <= result;
			pipe3 <= pipe2;
			pipe4 <= pipe3;
			pipe5 <= pipe4;
			FWpipe6 <= pipe5;
			wr_en_pipe1 <= wr_en;
			memAddr_pipe1 <= memAddr;
			rt_pipe <= rt;
		end
    end

    always_comb begin
 			
	case(opcode9)
	    9'b001100001:begin//load quad word A-form
		    	memAddr = {{14{immediate16[0]}},{immediate16, 2'b00}} & 32'hFFFFFFF0;
				wr_en = 1;
			 end
	    9'b001100111:begin//load quad word instruction relative A-form
				memAddr = (PCin + {immediate16, 2'b00}) & 32'hFFFFFFF0;
				wr_en = 1;
			 end
	    9'b001000001:begin//store quad word A-form
				memAddr = {{14{immediate16[0]}},{immediate16, 2'b00}} & 32'hFFFFFFF0;
				wr_en = 2;
			 end
	    9'b001000111:begin//store quad word instruction relative A-form
				memAddr = (PCin + {{14{immediate16[0]}},{immediate16, 2'b00}}) & 32'hFFFFFFF0;
				wr_en = 2;
			 end
    	default:begin	case(opcode8)
			    8'b00110100:begin//load quad word D-form
						memAddr = ({{18{immediate10[0]}}, {immediate10, 4'b0000}} + ra[0:31]) & 32'hFFFFFFF0;
						wr_en = 1;
					end
			    8'b00100100:begin//store quad word D-form
						memAddr = ({{18{immediate10[0]}}, {immediate10, 4'b0000}} + ra[0:31]) & 32'hFFFFFFF0;
						wr_en = 2;
					end
			    default:	wr_en = 0;//output 0 when unit not called
			endcase
		end
	endcase
    end 
endmodule
