`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 08:46:52 AM
// Design Name: 
// Module Name: Arbiter_PIP
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
module Arbiter_PIP #(
    parameter int N = 8,
    parameter SIDE = 1
    )(
        input logic clk, rst_n,
//        input quote_t in_quote [N-1:0],
        input score_t in_score [N-1:0],
        output quote_t winner_quote
    );

    localparam STAGES = $clog2(N);

    // Stage 0 registers
//    quote_t q_reg [N-1:0];
    score_t s_reg [N-1:0];

    // Tree wires (combinational only)
//    quote_t q [0:STAGES][0:N-1];
    score_t s [0:STAGES][0:N-1];

    // Stage 0 = registered inputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
//            q_reg <= '{default:'0};
            s_reg <= '{default:'0};
        end else begin
            for (int i = 0; i < N; i++) begin
//                q_reg[i] <= in_quote[i];
                s_reg[i] <= in_score[i];
            end
        end
    end

    // Connect stage 0 wires
    for (genvar i = 0; i < N; i++) begin
//        assign q[0][i] = q_reg[i];
        assign s[0][i] = s_reg[i];
    end

    // Tournament tree (pure combinational)
    generate
        for (genvar k = 0; k < STAGES; k++) begin : GEN_TREE
            for (genvar i = 0; i < (N >> k); i += 2) begin : GEN_NODE
                
//                quote_t q_w;
                score_t s_w;
            
                Module_Arbiter U_ARB (
                    .in_score_A(s[k][i]),
//                    .in_quote_A(q[k][i]),
                    .in_score_B(s[k][i+1]),
//                    .in_quote_B(q[k][i+1]),
                    .winner_score(s_w)
//                    .winner_quote(q_w)
                );
                
                always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
//                    q[k+1][i>>1] <= '0;
                    s[k+1][i>>1] <= '0;
                end else begin
//                    q[k+1][i>>1] <= q_w;
                    s[k+1][i>>1] <= s_w;
                end
            end
                
            end
        end
    endgenerate

//    assign winner_quote = q[STAGES][0];
    
    // Quote reconstruction
    quote_t reg_w_quote;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) reg_w_quote <= '0;
        else begin
            reg_w_quote.valid <= s[STAGES][0].valid;
            reg_w_quote.side <= SIDE;
            reg_w_quote.price <= SIDE ? s[STAGES][0].price : ~s[STAGES][0].price;
            reg_w_quote.timestamp <= ~s[STAGES][0].timestamp;
            reg_w_quote.size <= s[STAGES][0].size;
            reg_w_quote.lane_id <= s[STAGES][0].lane_id;
        end
    end
    
    assign winner_quote = reg_w_quote;
endmodule
