`timescale 1ns/1ps

module tb_systolic_top_i_e;

    logic clk;
    logic reset;
    logic valid;
    logic ready;
    logic [63:0] data_in;
    logic tx_done;
    logic [63:0] data_out;

    // Instantiate DUT
    systolic_top dut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .ready(ready),
        .data_in(data_in),
        .tx_done(tx_done),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    task wait_cycle;
        @(posedge clk);
    endtask

    initial begin
        $dumpfile("systolic_top_i_e.vcd");
        $dumpvars(0, tb_systolic_top_i_e);

        clk = 0;
        reset = 1;
        valid = 0;
        ready = 0;
        data_in = 64'd0;

        wait_cycle;
        reset = 0;
        wait_cycle;

        // Feed input data (if any needed for systolic array)
        // Let's assume we give it one input (you can replicate this)
        valid = 1;
        ready = 1;
        data_in = 64'hCAFEBABEDEADBEEF;  // Example data
        $display("T=%0t: Sending data to DUT", $time);
        wait_cycle;

        // Deassert inputs (don't care after 1 cycle)
        valid = 0;
        ready = 0;
        data_in = 64'd0;
        wait_cycle;

        // Assume systolic_output appears after a few cycles
        repeat (5) wait_cycle;

        // --- Phase 1: systolic_output ready ---
        $display("T=%0t: Systolic output is ready (assumed)", $time);
        // Output should be loaded into buffer in next cycle
        wait_cycle;

        $display("T=%0t: Loading buffer_to_feeder", $time);
        wait_cycle;

        $display("T=%0t: Shifting buffer", $time);
        wait_cycle;

        $display("T=%0t: feeder_to_rv begins to send data_out", $time);
        // We expect chunks of 64-bit output now
        repeat (5) begin
            wait_cycle;
            $display("T=%0t: TX: data_out = %h | tx_done = %b", $time, data_out, tx_done);
        end

        $display("T=%0t: Simulation complete", $time);
        #100;
        $finish;
    end

endmodule
