`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 07:03:59 AM
// Design Name: 
// Module Name: Signal_Generation
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

module Signal_Generation #(parameter PRICE_W = 32)(
    input logic clk, rst_n, // Signals
    // Upstream
    input quote_t in_BID, in_ASK,
    // Downstream
    output logic cross_true,
    output logic [PRICE_W-1:0] spread, midpoint,
    output quote_t out_BID, out_ASK
    );
    
    // Intermediate varialbles
    logic [PRICE_W-1:0] reg_spread;
    logic [PRICE_W:0] reg_mid;
    logic reg_cross;
    quote_t reg_BID, reg_ASK;
    
    // Calculations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_spread <= '0;
            reg_mid <= '0;
            reg_cross <= 1'b0;
            reg_BID <= '0;
            reg_ASK <= '0;
        end 
        else if (in_BID.valid && in_ASK.valid) begin
            
            // Cross / Lock detection
            reg_cross <= (in_BID.price >= in_ASK.price);
    
            // Spread (unsigned, clamped to zero if crossed)
            if (in_ASK.price > in_BID.price)
                reg_spread <= in_ASK.price - in_BID.price;
            else
                reg_spread <= '0;
    
            // Midpoint
            reg_mid <= (in_BID.price + in_ASK.price) >> 1;
    
            reg_BID <= in_BID;
            reg_ASK <= in_ASK;
        end
    end
    
    // Output   
    assign spread = reg_spread;
    assign midpoint = reg_mid[PRICE_W-1:0];
    assign cross_true = reg_cross;
    assign out_BID = reg_BID;
    assign out_ASK = reg_ASK;
    
endmodule
