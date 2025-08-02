`timescale 1ns / 1ps

module tb_rv_protocol;

    logic clk;
    logic reset;
    logic valid;
    logic ready;
    logic [63:0] data_in;
    logic [63:0] data_out;
    logic tx_done;

    // Instantiate DUT
    rv_protocol dut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .ready(ready),
        .data_in(data_in),
        .data_out(data_out),
        .tx_done(tx_done)
    );

    // Clock generator: 10ns period
    always #5 clk = ~clk;

    // Helper task to wait 1 clk cycle
    task wait_cycle;
        @(posedge clk);
    endtask

    initial begin
        $dumpfile("rv_protocol.vcd");
        $dumpvars(0, tb_rv_protocol);

        // Initialize
        clk = 0;
        reset = 1;
        valid = 0;
        ready = 0;
        data_in = 64'h0;

        wait_cycle;
        reset = 0;
        wait_cycle;

        // Step 1: VALID asserted first (no handshake yet)
        data_in = 64'hDEADBEEFCAFEBABE;
        valid = 1;
        $display("T=%0t: VALID asserted, data_in = %h", $time, data_in);
        wait_cycle;

        // Step 2: READY asserted → handshake occurs
        ready = 1;
        $display("T=%0t: READY asserted", $time);
        wait_cycle;

        // Step 3: Observe tx_done and data_out
        $display("T=%0t: tx_done = %b", $time, tx_done);
        wait_cycle;

        // Expect data_out and tx_done
        $display("T=%0t: data_out = %h (should match data_in)", $time, data_out);
        $display("T=%0t: tx_done = %b (should be 1)", $time, tx_done);
        wait_cycle;

        // Clean-up
        valid = 0;
        ready = 0;
        wait_cycle;

        $display("T=%0t: Test complete.", $time);
        #100;
        $finish;
    end

endmodule
