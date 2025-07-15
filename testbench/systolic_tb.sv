`timescale 1ns/1ps

module systolic_tb;

    logic clk = 0;
    logic reset = 1;
    logic valid_in = 0;
    logic [127:0] matrix_A;
    logic [127:0] matrix_B;
    logic [511:0] y;
    logic done;
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
    
    initial begin
        //for gtkwave
        $dumpfile("systolic.vcd");   // VCD file name
        $dumpvars(0, systolic_tb);   // dump everything under the TB
    
        // Initialize matrices
        matrix_A = 128'h112233445566778899AABBCCDDEEFF00;
        matrix_B = 128'h00112233445566778899AABBCCDDEEFF;
    
        // Reset the system
        reset <= 1;
        @(posedge clk);
        reset <= 0;
    
        // Start processing
        valid_in <= 1;
        @(posedge clk);
        
        // Wait for processing to complete
        wait(done_matrix_mult);
        
        // Display results
        $display("Matrix multiplication done. Result: y = %h", y);
        
        $finish; // End simulation
    end

endmodule