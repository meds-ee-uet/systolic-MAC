`timescale 1ns / 1ps

module systolic_top_tb;

    logic clk;
    logic reset;
    logic load;
    logic shift;
    logic src_ready;
    logic done_matrix_mult;
    logic [511:0] systolic_output;
    logic [63:0] final_data_out;
    logic tx_two_done;

    // Instantiate DUT
    systolic_top dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift(shift),
        .src_ready(src_ready),
        .done_matrix_mult(done_matrix_mult),
        .systolic_output(systolic_output),
        .final_data_out(final_data_out),
        .tx_two_done(tx_two_done)
    );

    // Clock generator: 10ns period
    always #5 clk = ~clk;

    // Task to wait 1 cycle
    task wait_cycle;
        @(posedge clk);
    endtask

    initial begin
        $dumpfile("systolic_top.vcd");
        $dumpvars(0, systolic_top_tb);

        // Initialize
        clk = 0;
        reset = 1;
        load = 0;
        shift = 0;
        src_ready = 0;
        done_matrix_mult = 0;
        systolic_output = 512'h0;

        wait_cycle;
        reset = 0;
        wait_cycle;

        // Step 1: Load 512-bit output into buffer
        systolic_output = 512'hFEDCBA9876543210_0011223344556677_8899AABBCCDDEEFF_DEADBEEFCAFEBABE_0123456789ABCDEF_0001020304050607_1122334455667788_F0F1F2F3F4F5F6F7;
        load = 1;
        wait_cycle;
        load = 0;

        // Step 2: Begin shifting from buffer → feeder
        shift = 1;
        wait_cycle;  // shift 1st 64 bits into feeder_to_rv
        shift = 0;

        // Step 3: Simulate controller finishing → done_matrix_mult goes high
        done_matrix_mult = 1;
        wait_cycle;  // dest_valid is now active (1 cycle delayed)
        done_matrix_mult = 0;

        // Step 4: src_ready high → triggers handshake with rv_protocol
        src_ready = 1;
        wait_cycle;

        // Observe outputs
        $display("T=%0t: final_data_out = %h", $time, final_data_out);
        $display("T=%0t: tx_two_done = %b", $time, tx_two_done);

        wait_cycle;

        // Cleanup
        shift = 0;
        src_ready = 0;

        $display("T=%0t: Test complete.", $time);
        #50;
        $finish;
    end

endmodule
