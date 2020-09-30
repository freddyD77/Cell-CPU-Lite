module IF(clk, reset, stall, predictedPC, fb_PC, fb_predictedPC, fb_en, taken, fb_taken, fb_mispredict, predictedPC2, taken2, 
			instr, instr2, pc_reg);
    input				clk, reset, fb_taken, fb_en, fb_mispredict, stall;
    input [0:31]		fb_PC, fb_predictedPC;
    output logic		taken, taken2;
    output logic [0:31]	predictedPC, predictedPC2, instr, instr2, pc_reg;

    logic				miss, stall_reg;
    logic [0:31]		pc2, pc, im_rd_addr, instr1_out, instr2_out;
    integer i;

    BTB b0(.clk(clk), .reset(reset), .currentPC(im_rd_addr), .currentPC2(im_rd_addr + 4), .fb_PC(fb_PC), .fb_taken(fb_taken), 
    	.fb_en(fb_en), .fb_predictedPC(fb_predictedPC), .taken(taken), .taken2(taken2), .predictedPC(predictedPC), 
    	.predictedPC2(predictedPC2));

    icache i0(.clk(clk), .reset(reset), .pc(im_rd_addr), .instr(instr1_out), .instr2(instr2_out), .miss(miss));
    

	always_ff @(posedge clk) begin
		if(reset) begin
			pc<=0;
			pc_reg <= 0;
			stall_reg <= 0;
		end else begin
			pc<=im_rd_addr+8;
			pc_reg <= im_rd_addr;
			stall_reg <= stall;
		end		
	end


	always_comb begin
		//taken=0; taken2=0; predictedPC=0; predictedPC2=0;

		pc2=pc+4;
		im_rd_addr = (fb_mispredict) ? fb_predictedPC : (stall_reg | miss) ? pc_reg : (taken) ? predictedPC : (taken2) ? predictedPC2 : pc;
		instr = fb_mispredict | miss ? 32'b0100_0000_0010_0000_0000_0000_0000_0000 : instr1_out;
		instr2 = fb_mispredict | miss ? 32'b0000_0000_0010_0000_0000_0000_0000_0000 : instr2_out;
	end

endmodule




