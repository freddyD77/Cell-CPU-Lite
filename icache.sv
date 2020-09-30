module icache(clk, reset, pc, instr, instr2, miss);
    input				clk, reset;
    input [0:31]		pc;//first 2 bits aren't used, next 3 bits for word offset, next 6 for cache index, last 21 for tag
    output logic		miss;
    output logic [0:31]	instr, instr2;

    logic [0:63][0:1043] 	cache;//1 valid bit, 19 bit tag, 32 32bit words
    logic [0:31]		missedPC;
    logic 				validPCs;
    logic [0:31][0:31]	instr32;
    integer i, j;

    hardDisk h0(.clk(clk), .reset(reset), .missedPC(missedPC), 
    	.miss(miss), .instr32(instr32), .valid(validPCs));
    
    always_ff @(posedge clk) begin
		if(reset) begin
			instr<=32'b0100_0000_0010_0000_0000_0000_0000_0000;
			instr2<=32'b0000_0000_0010_0000_0000_0000_0000_0000;
			miss<=0;
		end else begin
			//instruction 1
			if(cache[pc[19:24]][0]==1) begin//check for valid bit
				if(cache[pc[19:24]][1:19]==pc[0:18]) begin//check for tag
					instr<=cache[pc[19:24]][20+(pc[25:29] * 32) +:32];
					instr2<=cache[pc[19:24]][20+((pc[25:29] + 1) * 32) +:32];
					miss <= 0;
					missedPC <= 0;
				end else begin
					instr<=32'b0100_0000_0010_0000_0000_0000_0000_0000;
					instr2<=32'b0000_0000_0010_0000_0000_0000_0000_0000;
					miss <= 1;
					missedPC <=pc;
				end
			end else begin
				instr<=32'b0100_0000_0010_0000_0000_0000_0000_0000;
				instr2<=32'b0000_0000_0010_0000_0000_0000_0000_0000;
				miss <= 1;
				missedPC <= pc;
			end
				
			if(validPCs) begin
				cache[pc[19:24]][0]<=1;
				cache[pc[19:24]][1:19]<=pc[0:18];
				for(i=0; i<32; i++)
					cache[pc[19:24]][20+(32*i) +:32]<=instr32[i];//writing 8 instructions to cache
			end

		end
	end

endmodule




