`timescale 1ns/1ps

module systolic(
    input logic clk,
    input logic reset,
    input logic valid_in,
    input logic [127:0] matrix_A,
    input logic [127:0] matrix_B,
    output logic [511:0] y,
    output logic done,
    output logic done_matrix_mult
);
    logic [55:0] A_r1, A_r2, A_r3, A_r4, B_c1, B_c2, B_c3, B_c4; 
    logic en_fr1, en_fr2, en_fr3, en_fr4;
    logic en_fc1, en_fc2, en_fc3, en_fc4;

    //decoding input matrices
    A_r1= {matrix_A[127:96],24'b0};
    A_r2= {8'b0,matrix_A[95:64],16'b0};
    A_r3= {16'b0,matrix_A[63:32],8'b0};
    A_r4= {24'b0,matrix_A[31:0]};

    B_c1= {matrix_B[127:120], matrix_B[95:88], matrix_B[63:56], matrix_B[31:24],24'b0};
    B_c2= {8'b0,matrix_B[119:112], matrix_B[87:80], matrix_B[55:48], matrix_B[23:16],16'b0};
    B_c3= {16'b0,matrix_B[111:104], matrix_B[79:72], matrix_B[47:40], matrix_B[15:8],8'b0};
    B_c4= {24'b0,matrix_B[103:96], matrix_B[71:64], matrix_B[39:32], matrix_B[7:0]};
    
    // Instantiate data feeders for each row of A and column of B
    // Instantiate data feeders for each row of A
    data_feeder fr1 (
        .clk(clk),
        .data_in(A_r1),
        .enable(en_fr1),
        .reset(reset),
        .data_out(A_r1)
    );
    data_feeder fr2 (
        .clk(clk),
        .data_in(A_r2),
        .enable(en_fr2),
        .reset(reset),
        .data_out(A_r2)
    );
    data_feeder fr3 (
        .clk(clk),
        .data_in(A_r3),
        .enable(en_fr3),
        .reset(reset),
        .data_out(A_r3)
    );
    data_feeder fr4 (
        .clk(clk),
        .data_in(A_r4),
        .enable(en_fr4),
        .reset(reset),
        .data_out(A_r4)
    );
    
    // Instantiate data feeders for each column of B
    data_feeder fc1 (
        .clk(clk),
        .data_in(B_c1),
        .enable(en_fc1),
        .reset(reset),
        .data_out(B_c1)
    );
    data_feeder fc2 (
        .clk(clk),
        .data_in(B_c2),
        .enable(en_fc2),
        .reset(reset),
        .data_out(B_c2)
    );
    data_feeder fc3 (
        .clk(clk),
        .data_in(B_c3),
        .enable(en_fc3),
        .reset(reset),
        .data_out(B_c3)
    );
    data_feeder fc4 (
        .clk(clk),
        .data_in(B_c4),
        .enable(en_fc4),
        .reset(reset),
        .data_out(B_c4)
    );
    

endmodule