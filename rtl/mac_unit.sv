// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module implements a Multiply-Accumulate (MAC) unit . Takes A and B as inputs (each of 8bits) multiply them and then accumulates the 
// result in a 32-bit accumulator.4 states required for it and we used Moore FSM to implement it which has already been added in the docs.
//
// Authors: Muhammad Waleed Akram (2023-EE-165) & Abdul Muiz (2023-EE-162)
//
// Date:

`timescale 1ns/1ps

//8 bit signed multiplier, with 16 bit intermediate, with 32 bit accumulator
module mac_unit (
    input  logic         clk,
    input  logic         reset,
    input  logic         valid,
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,
    output logic signed [31:0] y,
    // output logic overflow,
    output logic         done
);
    logic enA, enB,enAcc, rsA, rsB, rsAcc;
    logic signed [7:0] reg_A_out, reg_B_out;
    logic signed [31:0] reg_acc_out, reg_acc_in;

    //registers declarations:
    //reg A
    reg_def reg_A (
    .x(A),
    .enable(enA),
    .clk(clk),
    .clear(rsA),
    .y(reg_A_out)
);
    //reg B
    reg_def reg_B (
    .x(B),
    .enable(enB),
    .clk(clk),
    .clear(rsB),
    .y(reg_B_out)
);
    //accumulator reg
    reg_def #(.WIDTH(32)) reg_Acc (
    .x(reg_acc_in),
    .enable(enAcc),
    .clk(clk),
    .clear(rsAcc),
    .y(reg_acc_out)
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        PROCESSING,
        DONE
    } state_t;

    state_t state, next_state;
    logic signed [15:0] mult;
   
    //State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    //Next state logic
    always_comb begin
        // Defaults values
        next_state = state;
        enA = 0;
        enB = 0;
        enAcc = 0;
        done = 0;
        reg_acc_in = reg_acc_out;  
        // Reset multiplication done flag
        if(reset) begin
            rsA = 1'b1;
            rsB = 1'b1; 
            rsAcc = 1'b1;
            mult = 16'b0;   
        end
        else begin
            rsA = 1'b0;
            rsB = 1'b0;
            rsAcc = 1'b0;
        end
        case (state)
            IDLE: begin
                done = 0; // Default done state
                if (valid) begin
                    next_state = LOAD;
                end
            end

            LOAD: begin
                // Enable loading A and B only
                enA = 1;
                enB = 1;
                next_state=PROCESSING;
            end

            PROCESSING: begin
                // Do mult + accumulation
                mult = reg_A_out * reg_B_out;
                reg_acc_in = reg_acc_out + mult;
                enAcc = 1;
                next_state = DONE;
            end

            DONE: begin
                done = 1;
                next_state = IDLE;
            end
            default: next_state=IDLE;
        endcase
    end


    // Output logic
    assign y = reg_acc_out; // Output the accumulated value
endmodule

