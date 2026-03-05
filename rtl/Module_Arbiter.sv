`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2026 12:26:52 PM
// Design Name: 
// Module Name: Module_Arbiter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import Data_Structures::*;

module Module_Arbiter(        
        // Upstream
        input score_t in_score_A, in_score_B,
//        input quote_t in_quote_A, in_quote_B,
        
        // Donwstream
//        output quote_t winner_quote,
        output score_t winner_score
    );
    
    /*
    
    always_comb begin
        if(in_score_A >= in_score_B) begin
//            winner_quote = in_quote_A;
            winner_score = in_score_A;
        end else begin
//            winner_quote = in_quote_B;
            winner_score = in_score_B;
        end
    end */
    
    assign winner_score = (in_score_A >= in_score_B) ? in_score_A : in_score_B;
    
endmodule
