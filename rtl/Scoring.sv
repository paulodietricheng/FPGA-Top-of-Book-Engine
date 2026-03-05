`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 07:22:29 AM
// Design Name: 
// Module Name: Scoring
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

module Scoring(
        input clk, rst_n, // Signals
//        input quote_t in_quote, in_quote_c, // Upstream
        input quote_t in_quote_c,
        // Downstream
        output score_t out_score 
//        output quote_t out_quote
    );
    
    score_t reg_score;
//    quote_t reg_quote;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_score <= '0;
//            reg_quote <= '0;
        end else if(in_quote_c.valid) begin
            reg_score.valid <= in_quote_c.valid;
            reg_score.price <= in_quote_c.price;
            reg_score.timestamp <= in_quote_c.timestamp;
            reg_score.lane_id <= in_quote_c.lane_id;   
            reg_score.size <= in_quote_c.size;         
//            reg_quote <= in_quote;
        end
    end
    
    assign out_score = reg_score;
//    assign out_quote = reg_quote;
    
endmodule
