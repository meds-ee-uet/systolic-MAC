`timescale 1ns/1ps

module systolic_top_tb;

    logic clk;
    logic reset;
    logic valid_in;
    logic [63:0] data_in;
    logic src_valid;
    logic src_ready;
    logic [63:0] final_data_out;
    //logic done_matrix_mult;

    systolic dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .data_in(data_in),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .final_data_out(final_data_out)
        //.done_matrix_mult(done_matrix_mult)
    );

    always #5 clk = ~clk; // Clock: 10ns period

    initial begin
        clk = 0;
        reset = 1;
        valid_in = 0;
        data_in = 64'd0;
        src_valid = 0;
        src_ready = 0;

        // Reset the DUT
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Indicate start of valid input
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
       
        // First 64-bit chunk
        data_in = {
            8'd1, 8'd2, 8'd3, 8'd4,
            8'd1, 8'd5, 8'd9, 8'd13
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second 64-bit chunk
        data_in = {
            8'd5, 8'd6, 8'd7, 8'd8,
            8'd2, 8'd6, 8'd10, 8'd14
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third 64-bit chunk
        data_in = {
            8'd9, 8'd10, 8'd11, 8'd12,
            8'd3, 8'd7, 8'd11, 8'd15
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth 64-bit chunk
        data_in = {
            8'd13, 8'd14, 8'd15, 8'd16,
            8'd4, 8'd8, 8'd12, 8'd16
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

 
 
        for (int i = 0; i < 16; i++) begin
          
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk); // Give valid data time to propagate
            $display("T=%0t | Chunk %0d = %h", $time, i, final_data_out);
            src_ready = 0;
        end

        $display("== All chunks received ==");
        #50;
        $finish;
    end

endmodule