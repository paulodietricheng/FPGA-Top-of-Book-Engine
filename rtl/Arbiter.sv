`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2026 12:24:44 PM
// Design Name: 
// Module Name: Arbiter
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

module Arbiter#(
    parameter int N = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  quote_t in_quote [N-1:0],
    input  score_t in_score [N-1:0],
    output quote_t winner_quote
);

    localparam STAGES = $clog2(N);

    // Input Registers (Stage 0)
    quote_t q_reg [N-1:0];
    score_t s_reg [N-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q_reg <= '{default:'0};
            s_reg <= '{default:'0};
        end else begin
            for (int i = 0; i < N; i++) begin
                q_reg[i] <= in_quote[i];
                s_reg[i] <= in_score[i];
            end
        end
    end

    // Tree stages
    quote_t q [0:STAGES][0:N-1];
    score_t s [0:STAGES][0:N-1];

    // Stage 0 connections
    for (genvar i = 0; i < N; i++) begin
        assign q[0][i] = q_reg[i];
        assign s[0][i] = s_reg[i];
    end

    generate
        for (genvar k = 0; k < STAGES; k++) begin : GEN_TREE
            for (genvar i = 0; i < (N >> k); i += 2) begin : GEN_NODE

                Module_Arbiter U_ARB (
                    .in_score_A (s[k][i]),
                    .in_quote_A (q[k][i]),
                    .in_score_B (s[k][i+1]),
                    .in_quote_B (q[k][i+1]),
                    .winner_score (s[k+1][i>>1]),
                    .winner_quote (q[k+1][i>>1])
                );

            end
        end
    endgenerate

    // Final Output Register
    quote_t winner_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            winner_reg <= '0;
        else
            winner_reg <= q[STAGES][0];
    end

    assign winner_quote = winner_reg;

endmodule
