
module score_combiner (

	 input  logic		  enable,
    input  logic       tens_req,
    input  logic [7:0] tens_RGB,
    input  logic       ones_req,
    input  logic [7:0] ones_RGB,

    output logic       combined_req,
    output logic [7:0] combined_RGB
);


	always_comb begin
        // DEFAULT VALUES 
        combined_req = 1'b0;
        combined_RGB = 8'hFF; 

        // combines if enabled
        if (enable == 1'b1) begin
            if (tens_req == 1'b1) begin
                combined_req = 1'b1;
                combined_RGB = tens_RGB;
            end 
            else if (ones_req == 1'b1) begin
                combined_req = 1'b1;
                combined_RGB = ones_RGB;
            end 
        end
    end

endmodule 