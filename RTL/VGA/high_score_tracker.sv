
module high_score_tracker (
    input  logic clk,
    input  logic resetN,
    
    input  logic level_beaten_pulse, 
    
    // The frozen score from score_timer
    input  logic [3:0] current_ones, 
    input  logic [3:0] current_tens,

    // The high score output
    output logic [3:0] high_ones,
    output logic [3:0] high_tens
);

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            high_tens <= 4'd9;
            high_ones <= 4'd9;
        end 
        else begin
            // check the score when level is won
            if (level_beaten_pulse == 1'b1) begin
                
                if ( (current_tens < high_tens) || 
                     (current_tens == high_tens && current_ones < high_ones) ) begin

                    high_tens <= current_tens;
                    high_ones <= current_ones;
                end
            end
        end
    end

endmodule 