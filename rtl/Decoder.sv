`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paulo Dietrich
// 
// Create Date: 02/13/2026 03:24:59 PM
// Module Name: Decoder
// Project Name: Mini_Trading_Pipeline
// Description: 
// Revision: 0
// 
//////////////////////////////////////////////////////////////////////////////////

import Data_Structures::*;

module Decoder #(
    parameter int RAW_DATA_W = 98,
    parameter int PRICE_W = 32,
    parameter int TIMESTAMP_W = 32,
    parameter int SIZE_W = 32,
    parameter int LANE_W = 3
    )(
        input logic clk,
        input logic rst_n,
        
        // Upstream
        input logic [RAW_DATA_W-1:0] in_data,
        input logic [LANE_W-1:0] lane_id,
        
        // Downstream
        output quote_t out_quote
    );
    localparam VALID_BIT = RAW_DATA_W - 1;
    localparam SIDE_BIT = VALID_BIT - 1;
    localparam PRICE_START = SIDE_BIT - 1;
    localparam PRICE_END = PRICE_START - (PRICE_W-1);
    localparam TIME_START = (PRICE_END - 1);
    localparam TIME_END = TIME_START - (TIMESTAMP_W - 1);
    localparam SIZE_START = TIME_END - 1;
    localparam SIZE_END = SIZE_START - (SIZE_W - 1);
    localparam LANE_START = SIZE_END - 1;

    // Register to hold decoded fields
    quote_t reg_quote;

    // Decoding
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_quote <= '0;
        end else begin
            reg_quote.valid <= in_data[VALID_BIT];
            reg_quote.side <= in_data[SIDE_BIT];
            reg_quote.price <= in_data[PRICE_START:PRICE_END];
            reg_quote.timestamp <= in_data[TIME_START:TIME_END];
            reg_quote.size <= in_data[SIZE_START:SIZE_END];
            reg_quote.lane_id <= lane_id;
        end
    end

    // Outputs
    assign out_quote = reg_quote;
    
endmodule

