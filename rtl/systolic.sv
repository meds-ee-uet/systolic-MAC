// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// The top module for the 4x4 systolic array. 5 state mealy FSM has been implemented for it. It is to compute 4x4 matrix-multiplication.
//
// Authors: Abdul Muiz(2023-EE-162) & Muhammad Waleed Akram (2023-EE-165)
//
// Date: 

`timescale 1ns/1ps


typedef enum logic [3:0] {
    IDLE,
    RECEIVE,
    IN_COUNT,
    LOAD_IN,
    FEED,
    PROCESSING,
    DONE,
    LOAD_OUT,
    TRANSFER,
    SHIFT_COUNT
} state_type;

module systolic(
    input logic clk,
    input logic reset,
    input logic valid_in,
    input logic [63:0] data_in,
    input logic src_valid,
    input logic src_ready,
    output logic [63:0]  final_data_out,
    output logic done_matrix_mult
);
    logic [55:0] A_r [4];
    logic [55:0] B_c [4];
    logic [511:0] y;
    logic sh_fr [4];
    logic sh_fc [4];
    logic load_fc[4];
    logic load_fr[4];
    logic signed [7:0] A_r_out [4];
    logic signed [7:0] B_c_out [4];
    logic done [0:3][0:3];
    logic valid_out [0:3][0:3];
    logic dest_ready,next_col,next_row,load_in_done,tx_one_done;//input_datapath signals
    logic load_out,dest_valid,shift,tx_two_done,sh_count_done;//output_datapath signals

    state_type state, next_state;

    input_datapath input_dp (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .src_valid(src_valid),
        .dest_ready(dest_ready),
        .next_row(next_row),
        .next_col(next_col),
        .load_in_done(load_in_done),
        .tx_one_done(tx_one_done),
        .B_c1(B_c[0]),
        .B_c2(B_c[1]),
        .B_c3(B_c[2]),
        .B_c4(B_c[3]),
        .A_r1(A_r[0]),
        .A_r2(A_r[1]),
        .A_r3(A_r[2]),
        .A_r4(A_r[3])
    );
    
    // Instantiate data feeders for each row of A and column of B

    generate
        genvar i;
        for (i = 0; i < 4; i=i+1) begin : gen_A_rows
            data_feeder fri (
                .clk(clk),
                .data_in (A_r[i]),
                .shift  (sh_fr[i]),
                .load(load_fr[i]),
                .reset   (reset),
                .data_out(A_r_out[i])
            );
        end

        for (i = 0; i < 4; i=i+1) begin : gen_B_cols
            data_feeder fci (
                .clk(clk),
                .data_in (B_c[i]),
                .shift  (sh_fc[i]),
                .load(load_fc[i]),
                .reset   (reset),
                .data_out(B_c_out[i])
            );
        end
    endgenerate

    //systolic array
    logic signed [7:0] A_bus [0:3][0:4];  // [row][col] — extra col for left injection
    logic signed [7:0] B_bus [0:4][0:3];  // [row][col] — extra row for top injection
    logic valid[0:3][0:3];

    always_comb begin
    for (int i = 0; i < 4; i++) begin
        A_bus[i][0] = A_r_out[i];  // data feeder output for A row
    end
    for (int j = 0; j < 4; j++) begin
        B_bus[0][j] = B_c_out[j];  // data feeder output for B column
    end
    end

    logic signed [31:0] y_o [0:3][0:3];  // PE partial sums, or whatever size you want

    generate
    genvar m, n;
    for (m = 0; m < 4; m=m+1) begin : ROW
        for (n = 0; n < 4; n=n+1) begin : COL
        pe PEij (
            .clk(clk),
            .reset(reset),
            .valid(valid[m][n]),
            .A_in(A_bus[m][n]),
            .B_in(B_bus[m][n]),
            .A_out(A_bus[m][n+1]),   // pass A right
            .B_out(B_bus[m+1][n]),   // pass B down
            .y_out(y_o[m][n]),
            .done(done[m][n]),
            .valid_out(valid_out[m][n])
        );
        end
    end
    endgenerate

    assign y = {
        y_o[0][0], y_o[0][1], y_o[0][2], y_o[0][3],
        y_o[1][0], y_o[1][1], y_o[1][2], y_o[1][3],
        y_o[2][0], y_o[2][1], y_o[2][2], y_o[2][3],
        y_o[3][0], y_o[3][1], y_o[3][2], y_o[3][3]
    };
    // Output datapath
    output_datapath output_dp (
        .clk(clk),
        .reset(reset),
        .load_out(load_out),
        .shift(shift),
        .src_ready(src_ready),
        .systolic_output(y),
        .dest_valid(dest_valid),
        .final_data_out(final_data_out),
        .sh_count_done(sh_count_done),
        .tx_two_done(tx_two_done)
    );




    //state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    //flags
    logic valid_out_flag;
    logic done_flag;

    //next state and output logic
    always_comb begin
        dest_ready=1'b0;
        dest_valid=1'b0;
        shift=1'b0;
        done_matrix_mult=1'b0;
        sh_count_done=1'b0;
        for(int x=0;x<4;x++)begin
            sh_fr[x]=1'b0;
            sh_fc[x]=1'b0;
            load_fr[x]=1'b0;
            load_fc[x]=1'b0;
            for(int y=0;y<4;y++)begin
                valid[x][y]=1'b0;
            end
        end
        next_col=1'b0;
        next_row=1'b0;

        valid_out_flag = valid_out[0][0] && valid_out[0][1] && valid_out[0][2] && valid_out[0][3] &&
                    valid_out[1][0] && valid_out[1][1] && valid_out[1][2] && valid_out[1][3] &&
                    valid_out[2][0] && valid_out[2][1] && valid_out[2][2] && valid_out[2][3] &&
                    valid_out[3][0] && valid_out[3][1] && valid_out[3][2] && valid_out[3][3];
        done_flag = done[0][0] && done[0][1] && done[0][2] && done[0][3] &&
                    done[1][0] && done[1][1] && done[1][2] && done[1][3] &&
                    done[2][0] && done[2][1] && done[2][2] && done[2][3] &&
                    done[3][0] && done[3][1] && done[3][2] && done[3][3];
        case(state)
            
            IDLE:begin

                if(valid_in)begin
                    next_state = RECEIVE;
                    dest_ready=1'b1;
                end
                
                else begin  
                    next_state = IDLE;
                    done_matrix_mult=(done_matrix_mult==1)?1:0;
                end
            
            end

            RECEIVE:begin    
    
                if(tx_one_done)begin
                    next_state=IN_COUNT;
                end
                
                else begin
                    dest_ready=1'b1;
                    next_state=RECEIVE;
                end
            
            end

            IN_COUNT:begin
                if (load_in_done)begin
                    for(int x=0;x<4;x++)begin
                        load_fr[x]=1'b1;
                        load_fc[x]=1'b1;    
                    end
                    next_state=FEED;
                end
                else next_state=LOAD_IN;
            end

            LOAD_IN:begin
                
                next_col=1'b1;
                next_row=1'b1;
                next_state=RECEIVE;

            end

            FEED:begin
                for(int x=0;x<4;x++)begin
                    for(int y=0;y<4;y++)begin
                        valid[x][y]=1'b1;
                    end
                end
                next_state=PROCESSING;
                done_matrix_mult=0;

            end

            PROCESSING:begin

                if(valid_out_flag)
                    begin
                        next_state=DONE;
                    end

                else if (~(valid_out_flag)&&(done_flag))
                    begin
                        for(int x=0;x<4;x++)begin
                            sh_fr[x]=1'b1;
                            sh_fc[x]=1'b1;
                        end
                        next_state = FEED;
                    end
            
                else 
                    begin
                        next_state=PROCESSING;
                    end    
                
            end

            DONE:begin
                load_out=1'b1;
                next_state=LOAD_OUT;
            end

            LOAD_OUT:begin
                dest_valid=1'b1;
                next_state=TRANSFER;
            end

            TRANSFER:begin
                dest_valid=1'b1;
                if(tx_two_done)begin
                    dest_valid=1'b0;
                    shift=1'b1;
                    next_state=SHIFT_COUNT;
                end
            end

            SHIFT_COUNT:begin
                dest_valid=1'b1;
                next_state=TRANSFER;
                if(sh_count_done)begin
                    done_matrix_mult=1'b1;
                end
            end
            default: begin
                next_state = IDLE;
            end

    endcase
    
    end

endmodule