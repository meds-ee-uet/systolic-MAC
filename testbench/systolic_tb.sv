`timescale 1ns/1ps

module systolic_tb;

    logic clk = 0;
    logic reset = 1;
    logic valid_in = 0;
    logic [127:0] matrix_A;
    logic [127:0] matrix_B;
    logic [511:0] y;
    logic done_matrix_mult;

    always #5 clk = ~clk;

    systolic DUT (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .matrix_A(matrix_A),
        .matrix_B(matrix_B),
        .y(y),
        .done_matrix_mult(done_matrix_mult)
    );

    // Example: input 4x4 matrix of 8-bit elements, row-major
    // A = [  1  2  3  4;
    //         5  6  7  8;
    //         9 10 11 12;
    //        13 14 15 16 ]
    //
    // Flattened row-major: 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

    initial begin
        $dumpfile("systolic.vcd");
        $dumpvars(0, systolic_tb);

        // Format input matrices manually
        // E.g. bytes for A: [1][2][3][4][5][6][7][8][9][10][11][12][13][14][15][16]
        matrix_A = {
            8'd1, 8'd2, 8'd3, 8'd4,
            8'd5, 8'd6, 8'd7, 8'd8,
            8'd9, 8'd10, 8'd11, 8'd12,
            8'd13, 8'd14, 8'd15, 8'd16
        };

        // Same for B:
        matrix_B = {
            8'd1, 8'd2, 8'd3, 8'd4,
            8'd5, 8'd6, 8'd7, 8'd8,
            8'd9, 8'd10, 8'd11, 8'd12,
            8'd13, 8'd14, 8'd15, 8'd16
        };

        // Reset and start
        reset <= 1;
        @(posedge clk);
        reset <= 0;

        valid_in <= 1;
        @(posedge clk);
        valid_in <= 0;

        wait(done_matrix_mult);

        $display("Matrix multiplication done.");
        $display("Raw hex y = %h", y);

        // Unpack y into 16 partial sums (32 bits each)
        for (int i = 0; i < 16; i++) begin
            $display("y[%0d] = %0d", i, y[511 - i*32 -: 32]);
        end

        $finish;
    end

endmodule
