module hardDisk(clk, reset, missedPC, instr32, miss, valid);
    input						clk, reset, miss;
    input [0:31]				missedPC;//first 2 bits aren't used
    output logic				valid;
    output logic [0:31][0:31]	instr32;//8 word outputs

    reg [0:31] mem [0:127];//128 instructions, 32 bit wide
    logic [0:2]			penalty;
    integer i;
    initial $readmemb("instructions.txt", mem);//initializes instructions with values from a txt file

    always_ff @(posedge clk) begin
		if(reset) begin
			penalty<=0;
		end else begin
			if(penalty<4) begin//4 cycle delay
				if(miss || penalty!=0)
					penalty<=penalty+1;
				else
					penalty<=0;
			end else
				penalty<=0;

		end
	end

	always_comb begin
		if(penalty==3) begin//4 cycle delay
			for(i=0; i<32; i++)
				instr32[i]=mem[missedPC[0:29]+i];
			valid=1;

		end	else begin
			valid=0;
		end
	end

endmodule




