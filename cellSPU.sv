module cellSPU(clk, reset);
    input               clk, reset;

    logic               flush, enable;
    logic [0:31]        instrIF, instr2IF;
    logic               stall, miss, predictIF2, predictIF, predictOutD;
    logic [0:31]        PCin, PCoutIF, PCoutD, predictPCOutD, 
                        predictedPCIF2, predictedPCIF;
    logic [0:65]            PCoutBranch;
    logic [0:34]            instructionEven, instructionOdd;


    IF i0(.clk(clk), .reset(reset), .instr(instrIF), .instr2(instr2IF), .stall(stall), 
        .predictedPC(predictedPCIF), .fb_PC(PCoutBranch[33:64]), .fb_taken(PCoutBranch[32]), 
        .fb_predictedPC(PCoutBranch[0:31]), .fb_en(enable), .pc_reg(PCoutIF), 
        .taken(predictIF), .taken2(predictIF2), .predictedPC2(predictedPCIF2) , .fb_mispredict(PCoutBranch[65]));

    DecodeUnit d0(.clk(clk), .reset(reset), .predictIn0(predictIF), .predictIn1(predictIF2), 
        .PCin(PCoutIF), .predictPCin0(predictedPCIF), .predictPCin1(predictedPCIF2), 
        .IR({instrIF, instr2IF}), .PCSelect(stall), .predictOut(predictOutD), 
        .instructionOdd(instructionOdd), .instructionEven(instructionEven), 
        .PCOut(PCoutD), .predictPCOut(predictPCOutD), .flush(flush), .taken(PCoutBranch[65]));
    
    ProcessingUnit P0( 
    .instructionOdd (instructionOdd),
    .instructionEven (instructionEven),
    .PCout (PCoutBranch),
    .PCin (PCoutD),
    .predictPCin(predictPCOutD),
    .predictIn(predictOutD),
    .reset (reset),
    .clk (clk),
    .flush(flush));

    assign enable = (PCoutBranch != 0);

endmodule




