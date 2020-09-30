module BTB(clk, reset, currentPC, predictedPC, fb_PC, fb_predictedPC, fb_en, taken, fb_taken, currentPC2, predictedPC2, taken2);
    input				clk, reset, fb_taken, fb_en;
    input [0:31]		currentPC, currentPC2, fb_PC, fb_predictedPC;
    output logic		taken, taken2;
    output logic [0:31]	predictedPC, predictedPC2;

    logic [0:7][0:60] 	bufferTable;//no valid bit, may be redundant, have to settle for misprediction entering a for-loop
    								//but will still be fine when returning to previous for-loops
    logic [0:1]			takenState;
    integer i;
    
    always_ff @(posedge clk) begin
		if(reset) begin
			taken <= 0;
			predictedPC <= 0;
			taken2 <= 0;
			predictedPC2 <= 0;			
			for(i=0; i<8; i++) begin
				bufferTable[i][0:58]=0;
				bufferTable[i][59]=0;//bit 0 of takenState
				bufferTable[i][60]=0;//bit 1 of takenState
			end
		end else begin
			//feed-back from branch pipe
			if(fb_en) begin
				bufferTable[fb_PC[0:2]][0:26]<=fb_PC[3:29];
				bufferTable[fb_PC[0:2]][27:58]<=fb_predictedPC;
				if(bufferTable[fb_PC[0:2]][0:26]==fb_PC[3:29])
					bufferTable[fb_PC[0:2]][59:60]<=takenState;
				else begin
					if(fb_taken)
						bufferTable[fb_PC[0:2]][59:60]<=2'b11;//pretend as if we assumed taken previously, which is the desired behavior of 2-bit history
					else
						bufferTable[fb_PC[0:2]][59:60]<=2'b10;//same assumption
				end
			end

			//PC1
			if(bufferTable[currentPC[0:2]][0:26]==currentPC[3:29]) begin
				if(fb_en && bufferTable[currentPC[0:2]][0:26]==fb_PC[3:29])
					predictedPC<=fb_predictedPC;
				else
					predictedPC<=bufferTable[currentPC[0:2]][27:58];
				taken<=bufferTable[currentPC[0:2]][59];//left bit (of the 2) pretty much defines prediction
			end else 
				taken<=0;

			//PC2
			if(bufferTable[currentPC2[0:2]][0:26]==currentPC2[3:29]) begin
				if(fb_en && bufferTable[currentPC2[0:2]][0:26]==fb_PC[3:29])
					predictedPC2<=fb_predictedPC;
				else
					predictedPC2<=bufferTable[currentPC2[0:2]][27:58];
				taken2<=bufferTable[currentPC2[0:2]][59];//left bit (of the 2) pretty much defines prediction
			end else 
				taken2<=0;
		
		end
	end

	always_comb begin
		//prediction state transistion
		case(bufferTable[fb_PC[0:2]][59:60])
			2'b00: begin
				if(fb_taken)
					takenState=2'b01;
				else
					takenState=2'b00;
			end
			2'b01: begin
				if(fb_taken)
					takenState=2'b11;
				else
					takenState=2'b00;
			end
			2'b11: begin
				if(fb_taken)
					takenState=2'b11;
				else
					takenState=2'b10;
			end
			2'b10: begin
				if(fb_taken)
					takenState=2'b11;
				else
					takenState=2'b00;
			end
			default: takenState=2'b10;
		endcase
	end

endmodule




