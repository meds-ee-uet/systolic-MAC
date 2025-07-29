// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// Implements a ready/valid handshake interface that transfers data_in to data_out when both valid and ready
// are high, enabling en_data_Tx for one cycle.
//
// Authors: Muhammad Waleed Akram (2023-EE-165) & Abdul Muiz (2023-EE-162)
//
// Date:


module ready_valid_interface (
    input  logic         clk,
    input  logic         reset,
    input  logic         valid,
    input  logic         ready,
    input  logic [63:0]  data_in,
    output logic [63:0]  data_out,
    output logic         en_data_Tx
);

    // FSM state encoding
    typedef enum logic [1:0] {
        IDLE,
        TRANSFERRING
    } state_t;

    state_t state, next_state;

    // Register for data_out
    reg_def #(.WIDTH(64)) rv_reg(
        .x(data_in),
        .enable(en_data_Tx),
        .clk(clk),
        .clear(reset),
        .y(data_out)
    );

    // FSM: State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM: Next State Logic
    always_comb begin
        case (state)
            IDLE: begin
                if (valid && ready) begin
                    en_data_Tx = 1'b1;
                    next_state = TRANSFERRING;
                end 
                else begin
                    next_state = IDLE;
                end
            
            end

            TRANSFERRING: begin
                en_data_Tx = 1'b0;
                next_state = IDLE;  // Single cycle transfer
            end
            default:begin
                next_state=IDLE;
            end
        endcase
    end

endmodule

