// (c) Technion IIT, Department of Electrical Engineering 2025 

module random ( 
    input  logic clk,
    input  logic resetN, 
    input  logic rise, // used to add extra randomness to the module based on human input
    output logic unsigned [SIZE_BITS-1:0] dout    
);

parameter SIZE_BITS = 8;
logic [7:0] lfsr;

wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3] ^ rise;

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        lfsr <= 8'hAA; // a XOR LFSR can never be initialized to 0
    end else begin
        lfsr <= {lfsr[6:0], feedback}; // Shift left and feed back
    end
end

assign dout = lfsr;

endmodule
