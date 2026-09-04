// (c) Technion IIT, Department of Electrical Engineering 2021 
// Written By David Bar-On  June 2018 
// Modified to always display the letter 'L'

module SEG7_letter_L (  
	input  logic clk,
	input  logic resetN,
	input  logic [3:0] iDIG, 
	input  logic darkN,
	output logic [6:0] oSEG  
);

always_comb begin
	if (!darkN) 
		oSEG = 7'b1111111; 
	else 
		case(iDIG)
			4'h1: oSEG = 7'b1000111; // L 
			4'h2: oSEG = 7'b0000110; // E 
			//4'h3: oSEG = 7'b1000001; // V
			4'h3: oSEG = 7'b1100011; // v

			default: oSEG = 7'b1111111; 
		endcase
	end

endmodule