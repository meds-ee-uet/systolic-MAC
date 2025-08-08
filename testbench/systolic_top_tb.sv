`timescale 1ns/1ps

module systolic_top_tb;

    logic clk;
    logic reset;
    logic valid_in;
    logic [63:0] data_in;
    logic src_valid;
    logic src_ready;
    logic [63:0] final_data_out;
    logic done_matrix_mult;

    systolic dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .data_in(data_in),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .final_data_out(final_data_out),
        .done_matrix_mult(done_matrix_mult)
    );

    always #5 clk = ~clk; // Clock: 10ns period

    initial begin
        clk = 0;
        reset = 1;
        valid_in = 0;
        data_in = 64'h0;
        src_valid = 0;

        // Reset the DUT
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Indicate start of valid input
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
       

        // Send 4 input 64-bit chunks (Matrix A and B)

        // First 64-bit chunk
        data_in = 64'h1234567890ABCDEF;
        @(posedge clk);

        src_valid = 1;

        @(posedge clk);

        src_valid = 0;
        @(posedge clk);
         valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // Send 4 input 64-bit chunks (Matrix A and B)

        // Second 64-bit chunk
        data_in = 64'h8911223344556677;
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);

        src_valid = 0;
        @(posedge clk);
         valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // Send 4 input 64-bit chunks (Matrix A and B)


        // Third 64-bit chunk
        data_in = 64'h8899AABBCCDDEEFF;
        @(posedge clk);

        src_valid = 1;

        @(posedge clk);
        src_valid = 0;
        @(posedge clk);
         valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // Send 4 input 64-bit chunks (Matrix A and B)


        // Fourth 64-bit chunk
        data_in = 64'h1020304050607080;
        @(posedge clk);

        src_valid = 1;
        @(posedge clk);
        // End of input
        src_valid = 0;

        // Wait for processing to complete
        wait(done_matrix_mult == 1);

        $display("Final output: %h", final_data_out);

        #50;
        $finish;
    end

endmodule
