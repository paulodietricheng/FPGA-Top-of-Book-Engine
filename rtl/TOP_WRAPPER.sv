`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 08:05:14 PM
// Design Name: 
// Module Name: TOP_WRAPPER
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

module TOP_WRAPPER (
        input logic clk, logic rst_n,
        output logic [97:0] debug_out
    );

    // Dummy variables
    logic [97:0] quotes [7:0];
    quote_t best_bid;
    quote_t best_ask;
    logic [31:0] spread;
    logic [31:0] mid;
    logic cross_t;

    // Dummy quote generator
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            quotes <= '{default:0};
        end
        else begin
            for (int i = 0; i < 8; i++) begin
                quotes[i] <= quotes[i] + 1;
            end
        end
    end

    // DUT instantiation
    TOB_Engine dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_data(quotes),
        .best_bid(best_bid),
        .best_ask(best_ask),
        .out_spread(spread),
        .out_mid(mid),
        .out_cross(cross_t)
    );

    // Make the output observable
    assign debug_out = best_bid.price ^ best_ask.price;;

endmodule
