`timescale 1ns/1ps


enum logic [1:0] {
    IDLE,
    FEED,
    LOAD,
    PROCESSING,
    DONE
} state;

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
    logic [55:0] A_r [4];
    logic [55:0] B_c [4];
    logic en_fr [4];
    logic en_fc [4];
    logic [7:0] A_r_out [4];
    logic [7:0] B_c_out [4];
    logic done [0:3][0:3];
    logic valid_out [0:3][0:3];



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
    genvar i;

    generate
        for (i = 0; i < 4; i++) begin : gen_A_rows
            data_feeder fri (
                .clk(clk),
                .data_in (A_r[i]),
                .enable  (en_fr[i]),
                .reset   (reset),
                .data_out(A_r_out[i])
            );
        end

        for (i = 0; i < 4; i++) begin : gen_B_cols
            data_feeder fci (
                .clk(clk),
                .data_in (B_c[i]),
                .enable  (en_fc[i]),
                .reset   (reset),
                .data_out(B_c_out[i])
            );
        end
    endgenerate

    //systolic array
    logic [7:0] A_bus [0:3][0:4];  // [row][col] — extra col for left injection
    logic [7:0] B_bus [0:4][0:3];  // [row][col] — extra row for top injection

    always_comb begin
    for (int i = 0; i < 4; i++) begin
        A_bus[i][0] = A_r_out[i];  // data feeder output for A row
    end
    for (int j = 0; j < 4; j++) begin
        B_bus[0][j] = B_c_out[j];  // data feeder output for B column
    end
    end

    logic [32:0] C_bus [0:3][0:3];  // PE partial sums, or whatever size you want

    genvar m, n;
    generate
    for (m = 0; m < 4; m++) begin : ROW
        for (n = 0; n < 4; n++) begin : COL
        PE PEij (
            .clk(clk),
            .reset(reset),
            .A_in(A_bus[i][j]),
            .B_in(B_bus[i][j]),
            .A_out(A_bus[i][j+1]),   // pass A right
            .B_out(B_bus[i+1][j]),   // pass B down
            .y_out(C_bus[i][j]),
            .done(done[i][j]),
            .valid_out(valid_out[i][j])
        );
        end
    end
    endgenerate

    assign y_out = {
        C_bus[0][0], C_bus[0][1], C_bus[0][2], C_bus[0][3],
        C_bus[1][0], C_bus[1][1], C_bus[1][2], C_bus[1][3],
        C_bus[2][0], C_bus[2][1], C_bus[2][2], C_bus[2][3],
        C_bus[3][0], C_bus[3][1], C_bus[3][2], C_bus[3][3]
    };

    assign done_matrix_mult = valid_out[0][0] & valid_out[0][1] & valid_out[0][2] & valid_out[0][3] &
                              valid_out[1][0] & valid_out[1][1] & valid_out[1][2] & valid_out[1][3] &
                              valid_out[2][0] & valid_out[2][1] & valid_out[2][2] & valid_out[2][3] &
                              valid_out[3][0] & valid_out[3][1] & valid_out[3][2] & valid_out[3][3];



endmodule