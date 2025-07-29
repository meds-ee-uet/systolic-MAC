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


typedef enum logic [2:0] {
    IDLE,
    FEED,
    LOAD,
    PROCESSING,
    DONE
} state_type;

module systolic(
    input logic clk,
    input logic reset,
    input logic valid_in,
    input logic [127:0] matrix_A,
    input logic [127:0] matrix_B,
    output logic [511:0] y,
    output logic done_matrix_mult
);
    logic [55:0] A_r [4];
    logic [55:0] B_c [4];
    logic sh_fr [4];
    logic sh_fc [4];
    logic load_fc[4];
    logic load_fr[4];
    logic signed [7:0] A_r_out [4];
    logic signed [7:0] B_c_out [4];
    logic done [0:3][0:3];
    logic valid_out [0:3][0:3];

    state_type state, next_state;

    //decoding input matrices
    assign A_r[0]= {matrix_A[127:96],24'b0};
    assign A_r[1]= {8'b0,matrix_A[95:64],16'b0};
    assign A_r[2]= {16'b0,matrix_A[63:32],8'b0};
    assign A_r[3]= {24'b0,matrix_A[31:0]};

    assign B_c[0]= {matrix_B[127:120], matrix_B[95:88], matrix_B[63:56], matrix_B[31:24],24'b0};
    assign B_c[1]= {8'b0,matrix_B[119:112], matrix_B[87:80], matrix_B[55:48], matrix_B[23:16],16'b0};
    assign B_c[2]= {16'b0,matrix_B[111:104], matrix_B[79:72], matrix_B[47:40], matrix_B[15:8],8'b0};
    assign B_c[3]= {24'b0,matrix_B[103:96], matrix_B[71:64], matrix_B[39:32], matrix_B[7:0]};
    
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

    logic signed [31:0] C_bus [0:3][0:3];  // PE partial sums, or whatever size you want

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
            .y_out(C_bus[m][n]),
            .done(done[m][n]),
            .valid_out(valid_out[m][n])
        );
        end
    end
    endgenerate

    assign y = {
        C_bus[0][0], C_bus[0][1], C_bus[0][2], C_bus[0][3],
        C_bus[1][0], C_bus[1][1], C_bus[1][2], C_bus[1][3],
        C_bus[2][0], C_bus[2][1], C_bus[2][2], C_bus[2][3],
        C_bus[3][0], C_bus[3][1], C_bus[3][2], C_bus[3][3]
    };


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
                
                for(int x=0;x<4;x++)begin
                    sh_fr[x]=1'b0;
                    sh_fc[x]=1'b0;
                    load_fr[x]=1'b0;
                    load_fc[x]=1'b0;
                    for(int y=0;y<4;y++)begin
                        valid[x][y]=1'b0;
                    end
                end

                if(valid_in)begin
                    for (int j=0;j<4;j++)begin                        
                        load_fr[j]=1'b1;
                        load_fc[j]=1'b1;
                    end
                    next_state = FEED;
                    done_matrix_mult=0;
                end
                
                else begin  
                    next_state = IDLE;
                    done_matrix_mult=(done_matrix_mult==1)?1:0;
                end
            
            end
            
            FEED:begin

                for(int x=0;x<4;x++)begin
                    sh_fr[x]=1'b0;
                    sh_fc[x]=1'b0;
                    load_fr[x]=1'b0;
                    load_fc[x]=1'b0;
                    for(int y=0;y<4;y++)begin
                        valid[x][y]=1'b1;
                    end
                end
                next_state=PROCESSING;
                done_matrix_mult=0;

            end
            
            LOAD:begin

                for(int x=0;x<4;x++)begin
                    sh_fr[x]=1'b0;
                    sh_fc[x]=1'b0;
                    load_fr[x]=1'b0;
                    load_fc[x]=1'b0;
                    for(int y=0;y<4;y++)begin
                        valid[x][y]=1'b0;
                    end
                end
                next_state = PROCESSING;
                done_matrix_mult=0;

            end

            PROCESSING:begin

                if(valid_out_flag)
                    begin
                        done_matrix_mult=1;
                        next_state=DONE;
                    end

                else if (~(valid_out_flag)&&(done_flag))
                    begin
                        for(int x=0;x<4;x++)begin
                            sh_fr[x]=1'b1;
                            sh_fc[x]=1'b1;
                            load_fr[x]=1'b0;
                            load_fc[x]=1'b0;
                            for(int y=0;y<4;y++)begin
                                valid[x][y]=1'b0;
                            end
                        next_state = FEED;
                        done_matrix_mult=0;
                    end
                    end
            
                else 

                    begin
                        for(int x=0;x<4;x++)begin
                            sh_fr[x]=1'b0;
                            sh_fc[x]=1'b0;
                            load_fr[x]=1'b0;
                            load_fc[x]=1'b0;
                            for(int y=0;y<4;y++)begin
                                valid[x][y]=1'b0;
                            end
                        end
                            next_state=PROCESSING;
                            done_matrix_mult=0;
                    end    
                
            end

            DONE:begin
                for(int x=0;x<4;x++)begin
                    sh_fr[x]=1'b0;
                    sh_fc[x]=1'b0;
                    load_fr[x]=1'b0;
                    load_fc[x]=1'b0;
                    for(int y=0;y<4;y++)begin
                        valid[x][y]=1'b0;
                    end
                end
                done_matrix_mult=1;
                next_state=IDLE;
            end

            default: begin
                next_state = IDLE;
            end

    endcase
    
    end

endmodule