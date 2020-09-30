/* Decode module for decoding instructions, detecting hazards and issuing instructions in order after resolving all hazards */
module DecodeUnit(
	input						clk, reset, predictIn0, predictIn1, taken,
	input 		 [0:31]			PCin, predictPCin0, predictPCin1, 
	input		 [0:63]			IR,
	output logic [0:31]			PCOut, predictPCOut,
	output logic				PCSelect, predictOut, flush,
	output logic [0:34]			instructionEven, instructionOdd);

	logic	[0:31]	nextInstr1, nextInstr2, nextInstr1Reg, nextInstr2Reg, oldPC, PCRead, oldPredictPC_0, predictPCRead_0, oldPredictPC_1, predictPCRead_1;
	logic	[0:31]	oldPC_reg, oldPredictPC_0_reg, oldPredictPC_1_reg;
	logic	[0:34]	instr1, instr2, instrEvenReg, instrOddReg;
	logic	[0:34]	ex1_even, ex2_even, ex3_even, ex4_even, ex5_even, ex6_even, ex7_even, wb_even;
	logic	[0:34]	ex1_odd, ex2_odd, ex3_odd, ex4_odd, ex5_odd, ex6_odd, ex7_odd, wb_odd;
	logic	[0:6]	addr_ra, addr_rb, addr_rc;
	logic			firstSrc, secondSrc, thirdSrc, hazard1, hazard2, PCSelectReg, firstBranch, predictRead_0, oldPredict_0, predictRead_1, oldPredict_1;
	logic			oldPredict_0_reg, oldPredict_1_reg;
	
	always_ff @(posedge clk) begin
		if(reset | taken) begin
			instructionEven <= 35'b0100_0000_0010_0000_0000_0000_0000_0000_111;
			instructionOdd <= 35'b0000_0000_0010_0000_0000_0000_0000_0000_111;
		end
		else begin
			/* Outputs containing instructions to be passed to the RF module for operand fetch.
			   Also functions as a register which remembers the instructions currently going through RF stage.*/
			instructionEven <= instrEvenReg;
			instructionOdd <= instrOddReg;
		end
		
		// Registers to remember all instructions currently executing in the even pipe
		ex1_even <= instructionEven;
		ex2_even <= ex1_even;
		ex3_even <= ex2_even;
		ex4_even <= ex3_even;
		ex5_even <= ex4_even;
		ex6_even <= ex5_even;
		ex7_even <= ex6_even;
		wb_even <= ex7_even;
		
		// Registers to remember all instructions currently executing in the odd pipe
		ex1_odd <= instructionOdd;
		ex2_odd <= ex1_odd;
		ex3_odd <= ex2_odd;
		ex4_odd <= ex3_odd;
		ex5_odd <= ex4_odd;
		ex6_odd <= ex5_odd;
		ex7_odd <= ex6_odd;
		wb_odd <= ex7_odd;
		
		// PC and prediction forwarded
		if(firstBranch) begin
			PCOut <= PCRead;
			predictOut <= predictRead_0;
			predictPCOut <= predictPCRead_0;
			flush <= 1;
		end
		else begin
			PCOut <= PCRead + 4;
			predictOut <= predictRead_1;
			predictPCOut <= predictPCRead_1;
			flush <= 0;
		end
			
		// Register to store next instructions in case all instructions in the current set were not pushed
		nextInstr1Reg <= nextInstr1;
		nextInstr2Reg <= nextInstr2;
		oldPC_reg <= oldPC;
		oldPredict_0_reg <= oldPredict_0;
		oldPredict_1_reg <= oldPredict_1;
		oldPredictPC_0_reg <= oldPredictPC_0;
		oldPredictPC_1_reg <= oldPredictPC_1;
		
		//PC Select signal forwarded
		PCSelectReg <= PCSelect;
	end

	always_comb begin
		
		// Read two instructions from the IR each cycle
		instr1[0:31] = (PCSelectReg) ? nextInstr1Reg : IR[0:31];
		instr2[0:31] = (PCSelectReg) ? nextInstr2Reg : IR[32:63];
		PCRead = (PCSelectReg) ? oldPC_reg : PCin;
		predictRead_0 = (PCSelectReg) ? oldPredict_0_reg : predictIn0;
		predictRead_1 = (PCSelectReg) ? oldPredict_1_reg : predictIn1;
		predictPCRead_0 = (PCSelectReg) ? oldPredictPC_0_reg : predictPCin0;
		predictPCRead_1 = (PCSelectReg) ? oldPredictPC_1_reg : predictPCin1;
		
		// Decode instructions starting from the first of two instructions fetched
		// Default value of '111' for unit ID for no-op instructions
		instr1[32:34] = 3'b111;
		instr2[32:34] = 3'b111;
		instrEvenReg = 35'b0100_0000_0010_0000_0000_0000_0000_0000_111;
		instrOddReg = 35'b0000_0000_0010_0000_0000_0000_0000_0000_111;
		// Set Hazard flag to zero before evaluating hazards
		PCSelect = 0;
		hazard1 = 0;
		hazard2 = 0;
		firstBranch = 0;
		// If data not ready for this instruction, need to set this to 1 and stall the pipeline

		// Start decoding first instruction only if it is not a no-op
		if(instr1[0:10] != 11'b0100_0000_001 & instr1[0:10] != 11'b0000_0000_001 & instr1[0:10] != 11'b0000_0000_000) begin
			firstSrc = 0;
			secondSrc = 0;
			thirdSrc = 0;
			// instr1 going to simple fixed 1 unit
			if(instr1[0:10] == 11'b00011001000 | instr1[0:10] == 11'b00011000000 | instr1[0:10] == 11'b00001001000 | instr1[0:10] == 11'b00001000000
			 | instr1[0:10] == 11'b01010100101 | instr1[0:10] == 11'b00110110110 | instr1[0:10] == 11'b00110110101 | instr1[0:10] == 11'b00110110100
			 | instr1[0:10] == 11'b00011000001 | instr1[0:10] == 11'b00001000001 | instr1[0:10] == 11'b00111110000 | instr1[0:10] == 11'b01001000001
			 | instr1[0:10] == 11'b01111010000 | instr1[0:10] == 11'b01111001000 | instr1[0:10] == 11'b01111000000 | instr1[0:10] == 11'b01001010000
			 | instr1[0:10] == 11'b01001001000 | instr1[0:10] == 11'b01001000000 | instr1[0:10] == 11'b01011010000 | instr1[0:10] == 11'b01011001000
			 | instr1[0:10] == 11'b01011000000 | instr1[0:8] == 9'b010000011 | instr1[0:8] == 9'b010000010 | instr1[0:8] == 9'b010000001
			 | instr1[0:8] == 9'b011000001 | instr1[0:8] == 9'b001100101 | instr1[0:7] == 8'b00011101 | instr1[0:7] == 8'b00011100
			 | instr1[0:7] == 8'b00001101 | instr1[0:7] == 8'b00001100 | instr1[0:7] == 8'b00010110 | instr1[0:7] == 8'b00010101
			 | instr1[0:7] == 8'b00010100 | instr1[0:7] == 8'b00000110 | instr1[0:7] == 8'b00000101 | instr1[0:7] == 8'b00000100
			 | instr1[0:7] == 8'b01000110 | instr1[0:7] == 8'b01000101 | instr1[0:7] == 8'b01000100 | instr1[0:7] == 8'b01111110
			 | instr1[0:7] == 8'b01111101 | instr1[0:7] == 8'b01111100 | instr1[0:7] == 8'b01001110 | instr1[0:7] == 8'b01001101
			 | instr1[0:7] == 8'b01001100 | instr1[0:7] == 8'b01011110 | instr1[0:7] == 8'b01011101 | instr1[0:7] == 8'b01011100
			 | instr1[0:6] == 7'b0100001) begin
				instr1[32:34] = 3'b000;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				if(instr1[0:8] != 9'b010000011 & instr1[0:8] != 9'b010000010 & instr1[0:8] != 9'b010000001 & instr1[0:8] != 9'b011000001
				 & instr1[0:8] != 9'b001100101 & instr1[0:6] != 7'b0100001) firstSrc = 1;
				if(instr1[0:10] == 11'b00011001000 | instr1[0:10] == 11'b00011000000 | instr1[0:10] == 11'b00001001000 | instr1[0:10] == 11'b00001000000
				 | instr1[0:10] == 11'b00011000001 | instr1[0:10] == 11'b00001000001 | instr1[0:10] == 11'b01001000001 | instr1[0:10] == 11'b01111010000 
				 | instr1[0:10] == 11'b01111001000 | instr1[0:10] == 11'b01111000000 | instr1[0:10] == 11'b01001010000 | instr1[0:10] == 11'b01001001000
				 | instr1[0:10] == 11'b01001000000 | instr1[0:10] == 11'b01011010000 | instr1[0:10] == 11'b01011001000 | instr1[0:10] == 11'b01011000000)
					secondSrc = 1;
			end
			// instr1 going to simple fixed 2 unit
			else if(instr1[0:10] == 11'b00001011111 | instr1[0:10] == 11'b00001011011 | instr1[0:10] == 11'b00001011100 | instr1[0:10] == 11'b00001011000
			 	  | instr1[0:10] == 11'b00001011101 | instr1[0:10] == 11'b00001011001 | instr1[0:10] == 11'b00001011110 | instr1[0:10] == 11'b00001011010
			 	  | instr1[0:10] == 11'b00001111111 | instr1[0:10] == 11'b00001111011 | instr1[0:10] == 11'b00001111100 | instr1[0:10] == 11'b00001111000
			 	  | instr1[0:10] == 11'b00001111101 | instr1[0:10] == 11'b00001111001 | instr1[0:10] == 11'b00001111110 | instr1[0:10] == 11'b00001111010) begin
				instr1[32:34] = 3'b001;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				firstSrc = 1;
				if(instr1[0:10] == 11'b00001011111 | instr1[0:10] == 11'b00001011011 | instr1[0:10] == 11'b00001011100 | instr1[0:10] == 11'b00001011000
			 	  | instr1[0:10] == 11'b00001011101 | instr1[0:10] == 11'b00001011001 | instr1[0:10] == 11'b00001011110 | instr1[0:10] == 11'b00001011010)
					secondSrc = 1;
			end
			// instr1 going to single precision unit
			else if(instr1[0:10] == 11'b01111000100 | instr1[0:10] == 11'b01111001100 | instr1[0:10] == 11'b01111000101 | instr1[0:10] == 11'b01011000100
			 	  | instr1[0:10] == 11'b01011000101 | instr1[0:10] == 11'b01011000110 | instr1[0:10] == 11'b01111000010 | instr1[0:10] == 11'b01111001010
			 	  | instr1[0:10] == 11'b01011000010 | instr1[0:10] == 11'b01011001010 | instr1[0:9] == 10'b0111011010 | instr1[0:9] == 10'b0111011000
			 	  | instr1[0:9] == 10'b0111011011 | instr1[0:9] == 10'b0111011001 | instr1[0:7] == 8'b01110100 | instr1[0:7] == 8'b01110101
				  | instr1[0:3] == 4'b1100 | instr1[0:3] == 4'b1110 | instr1[0:3] == 4'b1111) begin
				instr1[32:34] = 3'b010;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				addr_rc = instr1[25:31];
				firstSrc = 1;
				if(instr1[0:10] == 11'b01111000100 | instr1[0:10] == 11'b01111001100 | instr1[0:10] == 11'b01111000101 | instr1[0:10] == 11'b01011000100
			 	 | instr1[0:10] == 11'b01011000101 | instr1[0:10] == 11'b01011000110 | instr1[0:10] == 11'b01111000010 | instr1[0:10] == 11'b01111001010
			 	 | instr1[0:10] == 11'b01011000010 | instr1[0:10] == 11'b01011001010 | instr1[0:3] == 4'b1100 | instr1[0:3] == 4'b1110 | instr1[0:3] == 4'b1111)
					secondSrc = 1;
				if(instr1[0:3] == 4'b1100 | instr1[0:3] == 4'b1110 | instr1[0:3] == 4'b1111) thirdSrc = 1;
			end
			// instr1 going to byte unit
			else if(instr1[0:10] == 11'b01010110100 | instr1[0:10] == 11'b00011010011 | instr1[0:10] == 11'b00001010011 | instr1[0:10] == 11'b01001010011) begin
				instr1[32:34] = 3'b011;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				firstSrc = 1;
				if(instr1[0:10] == 11'b00011010011 | instr1[0:10] == 11'b00001010011 | instr1[0:10] == 11'b01001010011) secondSrc = 1;
			end
			// instr1 going to permute unit
			else if(instr1[0:10] == 11'b00110110010 | instr1[0:10] == 11'b00110110000 | instr1[0:10] == 11'b00111011111 | instr1[0:10] == 11'b00111111111
			 | instr1[0:10] == 11'b00111011100 | instr1[0:10] == 11'b00111111100 | instr1[0:10] == 11'b00111011101 | instr1[0:10] == 11'b00111111101) begin
				instr1[32:34] = 3'b100;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				firstSrc = 1;
				if(instr1[0:10] == 11'b00111011111 | instr1[0:10] == 11'b00111011100 | instr1[0:10] == 11'b00111011101) secondSrc = 1;
			end
			// instr1 going to local store unit
			else if(instr1[0:8] == 9'b001100001 | instr1[0:8] == 9'b001100111 | instr1[0:8] == 9'b001000001 | instr1[0:8] == 9'b001000111
				  | instr1[0:7] == 8'b00110100 | instr1[0:7] == 8'b00100100) begin
				instr1[32:34] = 3'b101;
				addr_ra = instr1[18:24];
				addr_rb = instr1[11:17];
				addr_rc = instr1[25:31];
				if(instr1[0:7] == 8'b00110100 | instr1[0:7] == 8'b00100100) firstSrc = 1;
				if(instr1[0:8] == 9'b001000001| instr1[0:8] == 9'b001000111 | instr1[0:7] == 8'b00100100) thirdSrc = 1;
			end
			// instr1 going to branch unit
			else if(instr1[0:8] == 9'b001100100 | instr1[0:8] == 9'b001100110 | instr1[0:8] == 9'b001000000 | instr1[0:8] == 9'b001000010) begin
				instr1[32:34] = 3'b110;
				addr_rc = instr1[25:31];
				if(instr1[0:8] == 9'b001000000 | instr1[0:8] == 9'b001000010) thirdSrc = 1;
			end
			
			// Ra Rb or Rc slot dependency on a previous instruction

			// Instruction in Execution Stage 5 should not be a No-op. Instructions from Odd Pipe is always ready after 6 stages.
			if(ex5_even[0:10] != 11'b0100_0000_001) begin
				if(ex5_even[32:34] == 3'b010) begin // Dependency with integer mul and madd instructions
					if(ex5_even[0:10] == 11'b01111000100 | ex5_even[0:10] == 11'b01111001100 | ex5_even[0:10] == 11'b01111000101 | ex5_even[0:7] == 8'b01110100
					| ex5_even[0:7] == 8'b01110101 | ex5_even[0:3] == 4'b1100) begin
						if(ex5_even[0:3] != 4'b1100) begin
							if((firstSrc & ex5_even[25:31] == addr_ra) | (secondSrc & ex5_even[25:31] == addr_rb) | (thirdSrc & ex5_even[25:31] == addr_rc))
								hazard1 = 1;
						end
						else begin
							if((firstSrc & ex5_even[4:10] == addr_ra) | (secondSrc & ex5_even[4:10] == addr_rb) | (thirdSrc & ex5_even[4:10] == addr_rc))
								hazard1 = 1;
						end
					end
				end
			end // Only need to consider the Even Pipe since only FP instructions can go upto 7 stages.

			// Instruction in Execution Stage 4 should not be a No-op. Need to consider both Pipes for instructions which take 6 stages or more.
			if(ex4_even[0:10] != 11'b0100_0000_001) begin
				if(ex4_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex4_even[0:3] != 4'b1100 & ex4_even[0:3] != 4'b1110 & ex4_even[0:3] != 4'b1111) begin
						if((firstSrc & ex4_even[25:31] == addr_ra) | (secondSrc & ex4_even[25:31] == addr_rb) | (thirdSrc & ex4_even[25:31] == addr_rc))
							hazard1 = 1;
					end
					else begin
						if((firstSrc & ex4_even[4:10] == addr_ra) | (secondSrc & ex4_even[4:10] == addr_rb) | (thirdSrc & ex4_even[4:10] == addr_rc))
							hazard1 = 1;
					end
				end
			end
			if(ex4_odd[0:10] != 11'b0000_0000_001) begin
				if(ex4_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex4_odd[0:8] == 9'b001100001 | ex4_odd[0:8] == 9'b001100111 | ex4_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex4_odd[25:31] == addr_ra) | (secondSrc & ex4_odd[25:31] == addr_rb) | (thirdSrc & ex4_odd[25:31] == addr_rc))
							hazard1 = 1;
					end
				end
			end

			// Instruction in Execution Stage 3 should not be a No-op. Need to consider both Pipes for instructions which take 5 stages or more.
			if(ex3_even[0:10] != 11'b0100_0000_001) begin
				if(ex3_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex3_even[0:3] != 4'b1100 & ex3_even[0:3] != 4'b1110 & ex3_even[0:3] != 4'b1111) begin
						if((firstSrc & ex3_even[25:31] == addr_ra) | (secondSrc & ex3_even[25:31] == addr_rb) | (thirdSrc & ex3_even[25:31] == addr_rc))
							hazard1 = 1;
					end
					else begin
						if((firstSrc & ex3_even[4:10] == addr_ra) | (secondSrc & ex3_even[4:10] == addr_rb) | (thirdSrc & ex3_even[4:10] == addr_rc))
							hazard1 = 1;
					end
				end
			end
			if(ex3_odd[0:10] != 11'b0000_0000_001) begin
				if(ex3_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex3_odd[0:8] == 9'b001100001 | ex3_odd[0:8] == 9'b001100111 | ex3_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex3_odd[25:31] == addr_ra) | (secondSrc & ex3_odd[25:31] == addr_rb) | (thirdSrc & ex3_odd[25:31] == addr_rc))
							hazard1 = 1;
					end
				end
			end

			// Instruction in Execution Stage 2 should not be a No-op. Need to consider both Pipes for instructions which take 4 stages or more.
			if(ex2_even[0:10] != 11'b0100_0000_001) begin
				if(ex2_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex2_even[0:3] != 4'b1100 & ex2_even[0:3] != 4'b1110 & ex2_even[0:3] != 4'b1111) begin
						if((firstSrc & ex2_even[25:31] == addr_ra) | (secondSrc & ex2_even[25:31] == addr_rb) | (thirdSrc & ex2_even[25:31] == addr_rc))
							hazard1 = 1;
					end
					else begin
						if((firstSrc & ex2_even[4:10] == addr_ra) | (secondSrc & ex2_even[4:10] == addr_rb) | (thirdSrc & ex2_even[4:10] == addr_rc))
							hazard1 = 1;
					end
				end
				if(ex2_even[32:34] == 3'b001 | ex2_even[32:34] == 3'b011) begin // Dependency with Simple Fixed 2 unit or byte unit instructions
					if((firstSrc & ex2_even[25:31] == addr_ra) | (secondSrc & ex2_even[25:31] == addr_rb) | (thirdSrc & ex2_even[25:31] == addr_rc))
						hazard1 = 1;
				end
			end
			if(ex2_odd[0:10] != 11'b0000_0000_001) begin
				if(ex2_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex2_odd[0:8] == 9'b001100001 | ex2_odd[0:8] == 9'b001100111 | ex2_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex2_odd[25:31] == addr_ra) | (secondSrc & ex2_odd[25:31] == addr_rb) | (thirdSrc & ex2_odd[25:31] == addr_rc))
							hazard1 = 1;
					end
				end
				if(ex2_odd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & ex2_odd[25:31] == addr_ra) | (secondSrc & ex2_odd[25:31] == addr_rb) | (thirdSrc & ex2_odd[25:31] == addr_rc))
						hazard1 = 1;
				end
			end

			// Instruction in Execution Stage 1 should not be a No-op. Need to consider both Pipes for instructions which take 3 stages or more.
			if(ex1_even[0:10] != 11'b0100_0000_001) begin
				if(ex1_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex1_even[0:3] != 4'b1100 & ex1_even[0:3] != 4'b1110 & ex1_even[0:3] != 4'b1111) begin
						if((firstSrc & ex1_even[25:31] == addr_ra) | (secondSrc & ex1_even[25:31] == addr_rb) | (thirdSrc & ex1_even[25:31] == addr_rc))
							hazard1 = 1;
					end
					else begin
						if((firstSrc & ex1_even[4:10] == addr_ra) | (secondSrc & ex1_even[4:10] == addr_rb) | (thirdSrc & ex1_even[4:10] == addr_rc))
							hazard1 = 1;
					end
				end
				if(ex1_even[32:34] == 3'b001 | ex1_even[32:34] == 3'b011) begin // Dependency with Simple Fixed 2 unit or byte unit instructions
					if((firstSrc & ex1_even[25:31] == addr_ra) | (secondSrc & ex1_even[25:31] == addr_rb) | (thirdSrc & ex1_even[25:31] == addr_rc))
						hazard1 = 1;
				end
			end
			if(ex1_odd[0:10] != 11'b0000_0000_001) begin
				if(ex1_odd[32:34] == 3'b101) begin
					if(ex1_odd[0:8] == 9'b001100001 | ex1_odd[0:8] == 9'b001100111 | ex1_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex1_odd[25:31] == addr_ra) | (secondSrc & ex1_odd[25:31] == addr_rb) | (thirdSrc & ex1_odd[25:31] == addr_rc))
							hazard1 = 1;
					end
				end
				if(ex1_odd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & ex1_odd[25:31] == addr_ra) | (secondSrc & ex1_odd[25:31] == addr_rb) | (thirdSrc & ex1_odd[25:31] == addr_rc))
						hazard1 = 1;
				end
			end

			// Instruction in RF Stage should not be a No-op. Need to consider both Pipes for instructions which take 2 stages or more.
			if(instructionEven[0:10] != 11'b0100_0000_001) begin
				if(instructionEven[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(instructionEven[0:3] != 4'b1100 & instructionEven[0:3] != 4'b1110 & instructionEven[0:3] != 4'b1111) begin
						if((firstSrc & instructionEven[25:31] == addr_ra) | (secondSrc & instructionEven[25:31] == addr_rb) | (thirdSrc & instructionEven[25:31] == addr_rc))
							hazard1 = 1;
					end
					else begin
						if((firstSrc & instructionEven[4:10] == addr_ra) | (secondSrc & instructionEven[4:10] == addr_rb) | (thirdSrc & instructionEven[4:10] == addr_rc))
							hazard1 = 1;
					end
				end
				if(instructionEven[32:34] == 3'b001 | instructionEven[32:34] == 3'b011 | instructionEven[32:34] == 3'b000) begin
					// Dependency with Simple Fixed 2 unit, byte unit or Simple Fixed 1 instructions
					if((firstSrc & instructionEven[25:31] == addr_ra) | (secondSrc & instructionEven[25:31] == addr_rb) | (thirdSrc & instructionEven[25:31] == addr_rc))
						hazard1 = 1;
				end
			end
			if(instructionOdd[0:10] != 11'b0000_0000_001) begin
				if(instructionOdd[32:34] == 3'b101) begin // Dependency with local store instructions
					if(instructionOdd[0:8] == 9'b001100001 | instructionOdd[0:8] == 9'b001100111 | instructionOdd[0:7] == 8'b00110100) begin
						if((firstSrc & instructionOdd[25:31] == addr_ra) | (secondSrc & instructionOdd[25:31] == addr_rb) | (thirdSrc & instructionOdd[25:31] == addr_rc))
							hazard1 = 1;
					end
				end
				if(instructionOdd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & instructionOdd[25:31] == addr_ra) | (secondSrc & instructionOdd[25:31] == addr_rb) | (thirdSrc & instructionOdd[25:31] == addr_rc))
						hazard1 = 1;
				end
			end

		end
				
		// Start decoding second instruction only if it is not a no-op
		if(instr2[0:10] != 11'b0100_0000_001 & instr2[0:10] != 11'b0000_0000_001 & instr2[0:10] != 11'b0000_0000_000) begin
			firstSrc = 0;
			secondSrc = 0;
			thirdSrc = 0;
			// instr2 going to simple fixed 1 unit
			if(instr2[0:10] == 11'b00011001000 | instr2[0:10] == 11'b00011000000 | instr2[0:10] == 11'b00001001000 | instr2[0:10] == 11'b00001000000
			 | instr2[0:10] == 11'b01010100101 | instr2[0:10] == 11'b00110110110 | instr2[0:10] == 11'b00110110101 | instr2[0:10] == 11'b00110110100
			 | instr2[0:10] == 11'b00011000001 | instr2[0:10] == 11'b00001000001 | instr2[0:10] == 11'b00111110000 | instr2[0:10] == 11'b01001000001
			 | instr2[0:10] == 11'b01111010000 | instr2[0:10] == 11'b01111001000 | instr2[0:10] == 11'b01111000000 | instr2[0:10] == 11'b01001010000
			 | instr2[0:10] == 11'b01001001000 | instr2[0:10] == 11'b01001000000 | instr2[0:10] == 11'b01011010000 | instr2[0:10] == 11'b01011001000
			 | instr2[0:10] == 11'b01011000000 | instr2[0:8] == 9'b010000011 | instr2[0:8] == 9'b010000010 | instr2[0:8] == 9'b010000001
			 | instr2[0:8] == 9'b011000001 | instr2[0:8] == 9'b001100101 | instr2[0:7] == 8'b00011101 | instr2[0:7] == 8'b00011100
			 | instr2[0:7] == 8'b00001101 | instr2[0:7] == 8'b00001100 | instr2[0:7] == 8'b00010110 | instr2[0:7] == 8'b00010101
			 | instr2[0:7] == 8'b00010100 | instr2[0:7] == 8'b00000110 | instr2[0:7] == 8'b00000101 | instr2[0:7] == 8'b00000100
			 | instr2[0:7] == 8'b01000110 | instr2[0:7] == 8'b01000101 | instr2[0:7] == 8'b01000100 | instr2[0:7] == 8'b01111110
			 | instr2[0:7] == 8'b01111101 | instr2[0:7] == 8'b01111100 | instr2[0:7] == 8'b01001110 | instr2[0:7] == 8'b01001101
			 | instr2[0:7] == 8'b01001100 | instr2[0:7] == 8'b01011110 | instr2[0:7] == 8'b01011101 | instr2[0:7] == 8'b01011100
			 | instr2[0:6] == 7'b0100001) begin
				instr2[32:34] = 3'b000;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				firstSrc = 1;
				if(instr2[0:8] != 9'b010000011 & instr2[0:8] != 9'b010000010 & instr2[0:8] != 9'b010000001 & instr2[0:8] != 9'b011000001
				 & instr2[0:8] != 9'b001100101 & instr2[0:6] != 7'b0100001) firstSrc = 1;
				if(instr2[0:10] == 11'b00011001000 | instr2[0:10] == 11'b00011000000 | instr2[0:10] == 11'b00001001000 | instr2[0:10] == 11'b00001000000
				 | instr2[0:10] == 11'b00011000001 | instr2[0:10] == 11'b00001000001 | instr2[0:10] == 11'b01001000001 | instr2[0:10] == 11'b01111010000 
				 | instr2[0:10] == 11'b01111001000 | instr2[0:10] == 11'b01111000000 | instr2[0:10] == 11'b01001010000 | instr2[0:10] == 11'b01001001000
				 | instr2[0:10] == 11'b01001000000 | instr2[0:10] == 11'b01011010000 | instr2[0:10] == 11'b01011001000 | instr2[0:10] == 11'b01011000000)
					secondSrc = 1;
			end
			// instr2 going to simple fixed 2 unit
			else if(instr2[0:10] == 11'b00001011111 | instr2[0:10] == 11'b00001011011 | instr2[0:10] == 11'b00001011100 | instr2[0:10] == 11'b00001011000
			 	  | instr2[0:10] == 11'b00001011101 | instr2[0:10] == 11'b00001011001 | instr2[0:10] == 11'b00001011110 | instr2[0:10] == 11'b00001011010
			 	  | instr2[0:10] == 11'b00001111111 | instr2[0:10] == 11'b00001111011 | instr2[0:10] == 11'b00001111100 | instr2[0:10] == 11'b00001111000
			 	  | instr2[0:10] == 11'b00001111101 | instr2[0:10] == 11'b00001111001 | instr2[0:10] == 11'b00001111110 | instr2[0:10] == 11'b00001111010) begin
				instr2[32:34] = 3'b001;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				firstSrc = 1;
				if(instr2[0:10] == 11'b00001011111 | instr2[0:10] == 11'b00001011011 | instr2[0:10] == 11'b00001011100 | instr2[0:10] == 11'b00001011000
			 	  | instr2[0:10] == 11'b00001011101 | instr2[0:10] == 11'b00001011001 | instr2[0:10] == 11'b00001011110 | instr2[0:10] == 11'b00001011010)
					secondSrc = 1;
			end
			// instr2 going to single precision unit
			else if(instr2[0:10] == 11'b01111000100 | instr2[0:10] == 11'b01111001100 | instr2[0:10] == 11'b01111000101 | instr2[0:10] == 11'b01011000100
			 	  | instr2[0:10] == 11'b01011000101 | instr2[0:10] == 11'b01011000110 | instr2[0:10] == 11'b01111000010 | instr2[0:10] == 11'b01111001010
			 	  | instr2[0:10] == 11'b01011000010 | instr2[0:10] == 11'b01011001010 | instr2[0:9] == 10'b0111011010 | instr2[0:9] == 10'b0111011000
			 	  | instr2[0:9] == 10'b0111011011 | instr2[0:9] == 10'b0111011001 | instr2[0:7] == 8'b01110100 | instr2[0:7] == 8'b01110101
				  | instr2[0:3] == 4'b1100 | instr2[0:3] == 4'b1110 | instr2[0:3] == 4'b1111) begin
				instr2[32:34] = 3'b010;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				addr_rc = instr2[25:31];
				firstSrc = 1;
				if(instr2[0:10] == 11'b01111000100 | instr2[0:10] == 11'b01111001100 | instr2[0:10] == 11'b01111000101 | instr2[0:10] == 11'b01011000100
			 	 | instr2[0:10] == 11'b01011000101 | instr2[0:10] == 11'b01011000110 | instr2[0:10] == 11'b01111000010 | instr2[0:10] == 11'b01111001010
			 	 | instr2[0:10] == 11'b01011000010 | instr2[0:10] == 11'b01011001010 | instr2[0:3] == 4'b1100 | instr2[0:3] == 4'b1110 | instr2[0:3] == 4'b1111)
					secondSrc = 1;
				if(instr2[0:3] == 4'b1100 | instr2[0:3] == 4'b1110 | instr2[0:3] == 4'b1111) thirdSrc = 1;
			end
			// instr2 going to byte unit
			else if(instr2[0:10] == 11'b01010110100 | instr2[0:10] == 11'b00011010011 | instr2[0:10] == 11'b00001010011 | instr2[0:10] == 11'b01001010011) begin
				instr2[32:34] = 3'b011;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				firstSrc = 1;
				if(instr2[0:10] == 11'b00011010011 | instr2[0:10] == 11'b00001010011 | instr2[0:10] == 11'b01001010011) secondSrc = 1;
			end
			// instr2 going to permute unit
			else if(instr2[0:10] == 11'b00110110010 | instr2[0:10] == 11'b00110110000 | instr2[0:10] == 11'b00111011111 | instr2[0:10] == 11'b00111111111
			 | instr2[0:10] == 11'b00111011100 | instr2[0:10] == 11'b00111111100 | instr2[0:10] == 11'b00111011101 | instr2[0:10] == 11'b00111111101) begin
				instr2[32:34] = 3'b100;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				firstSrc = 1;
				if(instr1[0:10] == 11'b00111011111 | instr1[0:10] == 11'b00111011100 | instr1[0:10] == 11'b00111011101) secondSrc = 1;
			end
			// instr2 going to local store unit
			else if(instr2[0:8] == 9'b001100001 | instr2[0:8] == 9'b001100111 | instr2[0:8] == 9'b001000001 | instr2[0:8] == 9'b001000111
				  | instr2[0:7] == 8'b00110100 | instr2[0:7] == 8'b00100100) begin
				instr2[32:34] = 3'b101;
				addr_ra = instr2[18:24];
				addr_rb = instr2[11:17];
				if(instr2[0:7] == 8'b00110100 | instr2[0:7] == 8'b00100100) firstSrc = 1;
				if(instr2[0:8] == 9'b001000001| instr2[0:8] == 9'b001000111 | instr2[0:7] == 8'b00100100) thirdSrc = 1;
			end
			// instr2 going to branch unit
			else if(instr2[0:8] == 9'b001100100 | instr2[0:8] == 9'b001100110 | instr2[0:8] == 9'b001000000 | instr2[0:8] == 9'b001000010) begin
				instr2[32:34] = 3'b110;
				addr_rc = instr2[25:31];
				if(instr2[0:8] == 9'b001000000 | instr2[0:8] == 9'b001000010) thirdSrc = 1;
			end
			
			// Ra Rb or Rc slot dependency on a previous instruction

			// Instruction in Execution Stage 5 should not be a No-op. Instructions from Odd Pipe is always ready after 6 stages.
			if(ex5_even[0:10] != 11'b0100_0000_001) begin
				if(ex5_even[32:34] == 3'b010) begin // Dependency with integer mul and madd instructions
					if(ex5_even[0:10] == 11'b01111000100 | ex5_even[0:10] == 11'b01111001100 | ex5_even[0:10] == 11'b01111000101 | ex5_even[0:7] == 8'b01110100
					| ex5_even[0:7] == 8'b01110101 | ex5_even[0:3] == 4'b1100) begin
						if(ex5_even[0:3] != 4'b1100) begin
							if((firstSrc & ex5_even[25:31] == addr_ra) | (secondSrc & ex5_even[25:31] == addr_rb) | (thirdSrc & ex5_even[25:31] == addr_rc))
								hazard2 = 1;
						end
						else begin
							if((firstSrc & ex5_even[4:10] == addr_ra) | (secondSrc & ex5_even[4:10] == addr_rb) | (thirdSrc & ex5_even[4:10] == addr_rc))
								hazard2 = 1;
						end
					end
				end
			end // Only need to consider the Even Pipe since only FP instructions can go upto 7 stages.

			// Instruction in Execution Stage 4 should not be a No-op. Need to consider both Pipes for instructions which take 6 stages or more.
			if(ex4_even[0:10] != 11'b0100_0000_001) begin
				if(ex4_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex4_even[0:3] != 4'b1100 & ex4_even[0:3] != 4'b1110 & ex4_even[0:3] != 4'b1111) begin
						if((firstSrc & ex4_even[25:31] == addr_ra) | (secondSrc & ex4_even[25:31] == addr_rb) | (thirdSrc & ex4_even[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & ex4_even[4:10] == addr_ra) | (secondSrc & ex4_even[4:10] == addr_rb) | (thirdSrc & ex4_even[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
			end
			if(ex4_odd[0:10] != 11'b0000_0000_001) begin
				if(ex4_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex4_odd[0:8] == 9'b001100001 | ex4_odd[0:8] == 9'b001100111 | ex4_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex4_odd[25:31] == addr_ra) | (secondSrc & ex4_odd[25:31] == addr_rb) | (thirdSrc & ex4_odd[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
			end

			// Instruction in Execution Stage 3 should not be a No-op. Need to consider both Pipes for instructions which take 5 stages or more.
			if(ex3_even[0:10] != 11'b0100_0000_001) begin
				if(ex3_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex3_even[0:3] != 4'b1100 & ex3_even[0:3] != 4'b1110 & ex3_even[0:3] != 4'b1111) begin
						if((firstSrc & ex3_even[25:31] == addr_ra) | (secondSrc & ex3_even[25:31] == addr_rb) | (thirdSrc & ex3_even[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & ex3_even[4:10] == addr_ra) | (secondSrc & ex3_even[4:10] == addr_rb) | (thirdSrc & ex3_even[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
			end
			if(ex3_odd[0:10] != 11'b0000_0000_001) begin
				if(ex3_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex3_odd[0:8] == 9'b001100001 | ex3_odd[0:8] == 9'b001100111 | ex3_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex3_odd[25:31] == addr_ra) | (secondSrc & ex3_odd[25:31] == addr_rb) | (thirdSrc & ex3_odd[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
			end

			// Instruction in Execution Stage 2 should not be a No-op. Need to consider both Pipes for instructions which take 4 stages or more.
			if(ex2_even[0:10] != 11'b0100_0000_001) begin
				if(ex2_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex2_even[0:3] != 4'b1100 & ex2_even[0:3] != 4'b1110 & ex2_even[0:3] != 4'b1111) begin
						if((firstSrc & ex2_even[25:31] == addr_ra) | (secondSrc & ex2_even[25:31] == addr_rb) | (thirdSrc & ex2_even[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & ex2_even[4:10] == addr_ra) | (secondSrc & ex2_even[4:10] == addr_rb) | (thirdSrc & ex2_even[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
				if(ex2_even[32:34] == 3'b001 | ex2_even[32:34] == 3'b011) begin // Dependency with Simple Fixed 2 unit or byte unit instructions
					if((firstSrc & ex2_even[25:31] == addr_ra) | (secondSrc & ex2_even[25:31] == addr_rb) | (thirdSrc & ex2_even[25:31] == addr_rc))
						hazard2 = 1;
				end
			end
			if(ex2_odd[0:10] != 11'b0000_0000_001) begin
				if(ex2_odd[32:34] == 3'b101) begin // Dependency with load instructions
					if(ex2_odd[0:8] == 9'b001100001 | ex2_odd[0:8] == 9'b001100111 | ex2_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex2_odd[25:31] == addr_ra) | (secondSrc & ex2_odd[25:31] == addr_rb) | (thirdSrc & ex2_odd[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
				if(ex2_odd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & ex2_odd[25:31] == addr_ra) | (secondSrc & ex2_odd[25:31] == addr_rb) | (thirdSrc & ex2_odd[25:31] == addr_rc))
						hazard2 = 1;
				end
			end

			// Instruction in Execution Stage 1 should not be a No-op. Need to consider both Pipes for instructions which take 3 stages or more.
			if(ex1_even[0:10] != 11'b0100_0000_001) begin
				if(ex1_even[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(ex1_even[0:3] != 4'b1100 & ex1_even[0:3] != 4'b1110 & ex1_even[0:3] != 4'b1111) begin
						if((firstSrc & ex1_even[25:31] == addr_ra) | (secondSrc & ex1_even[25:31] == addr_rb) | (thirdSrc & ex1_even[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & ex1_even[4:10] == addr_ra) | (secondSrc & ex1_even[4:10] == addr_rb) | (thirdSrc & ex1_even[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
				if(ex1_even[32:34] == 3'b001 | ex1_even[32:34] == 3'b011) begin // Dependency with Simple Fixed 2 unit or byte unit instructions
					if((firstSrc & ex1_even[25:31] == addr_ra) | (secondSrc & ex1_even[25:31] == addr_rb) | (thirdSrc & ex1_even[25:31] == addr_rc))
						hazard2 = 1;
				end
			end
			if(ex1_odd[0:10] != 11'b0000_0000_001) begin
				if(ex1_odd[32:34] == 3'b101) begin
					if(ex1_odd[0:8] == 9'b001100001 | ex1_odd[0:8] == 9'b001100111 | ex1_odd[0:7] == 8'b00110100) begin
						if((firstSrc & ex1_odd[25:31] == addr_ra) | (secondSrc & ex1_odd[25:31] == addr_rb) | (thirdSrc & ex1_odd[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
				if(ex1_odd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & ex1_odd[25:31] == addr_ra) | (secondSrc & ex1_odd[25:31] == addr_rb) | (thirdSrc & ex1_odd[25:31] == addr_rc))
						hazard2 = 1;
				end
			end

			// Instruction in RF Stage should not be a No-op. Need to consider both Pipes for instructions which take 2 stages or more.
			if(instructionEven[0:10] != 11'b0100_0000_001) begin
				if(instructionEven[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(instructionEven[0:3] != 4'b1100 & instructionEven[0:3] != 4'b1110 & instructionEven[0:3] != 4'b1111) begin
						if((firstSrc & instructionEven[25:31] == addr_ra) | (secondSrc & instructionEven[25:31] == addr_rb) | (thirdSrc & instructionEven[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & instructionEven[4:10] == addr_ra) | (secondSrc & instructionEven[4:10] == addr_rb) | (thirdSrc & instructionEven[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
				if(instructionEven[32:34] == 3'b001 | instructionEven[32:34] == 3'b011 | instructionEven[32:34] == 3'b000) begin
					// Dependency with Simple Fixed 2 unit, byte unit or Simple Fixed 1 instructions
					if((firstSrc & instructionEven[25:31] == addr_ra) | (secondSrc & instructionEven[25:31] == addr_rb) | (thirdSrc & instructionEven[25:31] == addr_rc))
						hazard2 = 1;
				end
			end
			if(instructionOdd[0:10] != 11'b0000_0000_001) begin
				if(instructionOdd[32:34] == 3'b101) begin // Dependency with local store instructions
					if(instructionOdd[0:8] == 9'b001100001 | instructionOdd[0:8] == 9'b001100111 | instructionOdd[0:7] == 8'b00110100) begin
						if((firstSrc & instructionOdd[25:31] == addr_ra) | (secondSrc & instructionOdd[25:31] == addr_rb) | (thirdSrc & instructionOdd[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
				if(instructionOdd[32:34] == 3'b100) begin // Dependency with permute unit instructions
					if((firstSrc & instructionOdd[25:31] == addr_ra) | (secondSrc & instructionOdd[25:31] == addr_rb) | (thirdSrc & instructionOdd[25:31] == addr_rc))
						hazard2 = 1;
				end
			end
			
			// Dependency with first instruction of current set
			if(instr1[0:10] != 11'b0100_0000_001 & instr1[0:10] != 11'b0000_0000_001) begin
				if(instr1[32:34] == 3'b010) begin // Dependency with all single precision unit instructions
					if(instr1[0:3] != 4'b1100 & instr1[0:3] != 4'b1110 & instr1[0:3] != 4'b1111) begin
						if((firstSrc & instr1[25:31] == addr_ra) | (secondSrc & instr1[25:31] == addr_rb)
						 | (thirdSrc & instr1[25:31] == addr_rc))
							hazard2 = 1;
					end
					else begin
						if((firstSrc & instr1[4:10] == addr_ra) | (secondSrc & instr1[4:10] == addr_rb)
						 | (thirdSrc & instr1[4:10] == addr_rc))
							hazard2 = 1;
					end
				end
				if(instr1[32:34] == 3'b001 | instr1[32:34] == 3'b011 | instr1[32:34] == 3'b000) begin
					// Dependency with Simple Fixed 2 unit, byte unit or Simple Fixed 1 instructions
					if((firstSrc & instr1[25:31] == addr_ra) | (secondSrc & instr1[25:31] == addr_rb)
					 | (thirdSrc & instr1[25:31] == addr_rc))
						hazard2 = 1;
				end
				if(instr1[32:34] == 3'b101) begin // Dependency with local store instructions
					if(instr1[0:8] == 9'b001100001 | instr1[0:8] == 9'b001100111 | instr1[0:7] == 8'b00110100) begin
						if((firstSrc & instr1[25:31] == addr_ra) | (secondSrc & instr1[25:31] == addr_rb)
						 | (thirdSrc & instr1[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
				if(instr1[32:34] == 3'b100) begin
					// Dependency with permute unit instructions
					if((firstSrc & instr1[25:31] == addr_ra) | (secondSrc & instr1[25:31] == addr_rb)
					 | (thirdSrc & instr1[25:31] == addr_rc))
						hazard2 = 1;
				end
				if(instr1[32:34] == 3'b110) begin
					// Dependency with branch unit instructions
					if(instr1[0:8] == 9'b001000000) begin
						if((firstSrc & instr1[25:31] == addr_ra) | (secondSrc & instr1[25:31] == addr_rb)
					 	 | (thirdSrc & instr1[25:31] == addr_rc))
							hazard2 = 1;
					end
				end
			end
		end
				
		if(hazard1 == 1) begin // Data hazard in first instruction, cannot push any instruction further
			nextInstr1 = instr1[0:31];
			nextInstr2 = instr2[0:31];
			PCSelect = 1;
		end
		else if(instr1[0:10] == 11'b0000_0000_000) begin // First instruction is a stop instruction, need to push no-ops to fill both pipes
			if(wb_even[0:10] == 11'b0100_0000_001 & ex7_even[0:10] == 11'b0100_0000_001 & ex6_even[0:10] == 11'b0100_0000_001 & ex5_even[0:10] == 11'b0100_0000_001
			& ex4_even[0:10] == 11'b0100_0000_001 & ex3_even[0:10] == 11'b0100_0000_001 & ex2_even[0:10] == 11'b0100_0000_001 & ex1_even[0:10] == 11'b0100_0000_001
			& instructionEven[0:10] == 11'b0100_0000_001 & wb_odd[0:10] == 11'b0000_0000_001 & ex7_odd[0:10] == 11'b0000_0000_001 & ex6_odd[0:10] == 11'b0000_0000_001
			& ex5_odd[0:10] == 11'b0000_0000_001 & ex4_odd[0:10] == 11'b0000_0000_001 & ex3_odd[0:10] == 11'b0000_0000_001 & ex2_odd[0:10] == 11'b0000_0000_001
			& ex1_odd[0:10] == 11'b0000_0000_001 & instructionOdd[0:10] == 11'b0000_0000_001) begin
				nextInstr1 = 32'b0100_0000_0010_0000_0000_0000_0000_0000;
				nextInstr2 = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
			end
			else begin
				nextInstr1 = instr1;
				nextInstr2 = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
			end
			PCSelect = 1;
		end
		else begin // No data hazards in first instruction
			if(instr1[32:34] != 3'b111 & instr1[32:34] < 3'b100) begin // First instruction goign to even pipe
				instrEvenReg = instr1;
				if(instr2[32:34] != 3'b111 & instr2[32:34] < 3'b100) // Second instruction also going to even pipe, HAZARD
					hazard2 = 1;
				else if(instr2[32:34] != 3'b111 & instr2[32:34] >= 3'b100) begin // If second instruction going to odd pipe
					if(instr2[0:8] != 9'b001100100 & instr2[0:8] != 9'b001000000 & instr2[0:8] != 9'b001000010 & instr2[0:8] != 9'b001000001
					 & instr2[0:8] != 9'b001000111 & instr2[0:7] != 8'b00100100) begin // Check Rt Rt structural hazard
						if(((instr1[0:3] == 4'b1100 | instr1[0:3] == 4'b1110 | instr1[0:3] == 4'b1111) & (instr2[25:31] == instr1[4:10]))
						| (((instr1[0:3] != 4'b1100 & instr1[0:3] != 4'b1110 & instr1[0:3] != 4'b1111) & (instr2[25:31] == instr1[25:31]))))
							hazard2 = 1;
					end
				end
			end
			else if(instr1[32:34] != 3'b111 & instr1[32:34] >= 3'b100) begin // First instruction going to odd pipe
				instrOddReg = instr1;
				firstBranch = (instr1[32:34] == 3'b110);
				if(instr2[32:34] != 3'b111 & instr2[32:34] >= 3'b100) // Second instruction also going to odd pipe, HAZARD
					hazard2 = 1;
				else if(instr2[32:34] != 3'b111 & instr2[32:34] < 3'b100) begin // If second instruction going to even pipe
					if(((instr2[0:3] == 4'b1100 | instr2[0:3] == 4'b1110 | instr2[0:3] == 4'b1111) & (instr1[25:31] == instr2[4:10]))
					| (((instr2[0:3] != 4'b1100 & instr2[0:3] != 4'b1110 & instr2[0:3] != 4'b1111) & (instr1[25:31] == instr2[25:31])))) 
						// Check Rt Rt structural hazard
						if(instr1[0:8] != 9'b001100100 & instr1[0:8] != 9'b001000000 & instr1[0:8] != 9'b001000010 & instr1[0:8] != 9'b001000001
						 & instr1[0:8] != 9'b001000111 & instr1[0:7] != 8'b00100100) begin
							hazard2 = 1;
					end
				end
			end
			nextInstr1 = 32'b0100_0000_0010_0000_0000_0000_0000_0000;
			if(hazard2 == 1 | hazard2 == 1) begin // Second instruction has a hazard detected, cannot push it further
				PCSelect = 1;
				nextInstr2 = instr2[0:31];
			end
			else if(instr2[0:10] == 11'b0000_0000_000) begin // Second instruction is a stop instruction, need to push no-ops to fill both pipes
				if(wb_even[0:10] == 11'b0100_0000_001 & ex7_even[0:10] == 11'b0100_0000_001 & ex6_even[0:10] == 11'b0100_0000_001 & ex5_even[0:10] == 11'b0100_0000_001
				& ex4_even[0:10] == 11'b0100_0000_001 & ex3_even[0:10] == 11'b0100_0000_001 & ex2_even[0:10] == 11'b0100_0000_001 & ex1_even[0:10] == 11'b0100_0000_001
				& instructionEven[0:10] == 11'b0100_0000_001 & wb_odd[0:10] == 11'b0000_0000_001 & ex7_odd[0:10] == 11'b0000_0000_001 & ex6_odd[0:10] == 11'b0000_0000_001
				& ex5_odd[0:10] == 11'b0000_0000_001 & ex4_odd[0:10] == 11'b0000_0000_001 & ex3_odd[0:10] == 11'b0000_0000_001 & ex2_odd[0:10] == 11'b0000_0000_001
				& ex1_odd[0:10] == 11'b0000_0000_001 & instructionOdd[0:10] == 11'b0000_0000_001) begin
					nextInstr1 = 32'b0100_0000_0010_0000_0000_0000_0000_0000;
					nextInstr2 = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
				end
				else begin
					nextInstr2 = instr2;
					nextInstr1 = 32'b0100_0000_0010_0000_0000_0000_0000_0000;
				end
				PCSelect = 1;
			end
			else begin // Safe to push second instruction
				if(instr2[32:34] != 3'b111 & instr2[32:34] < 3'b100)
					instrEvenReg = instr2;
				else if(instr2[32:34] != 3'b111 & instr2[32:34] >= 3'b100)
					instrOddReg = instr2;
				nextInstr2 = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
			end
		end
		
		if(PCSelect) begin
			oldPC = PCRead;
			oldPredict_0 = predictRead_0;
			oldPredict_1 = predictRead_1;
			oldPredictPC_0 = predictPCRead_0;
			oldPredictPC_1 = predictPCRead_1;
		end
		
	end

endmodule
