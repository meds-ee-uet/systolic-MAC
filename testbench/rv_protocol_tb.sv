`timescale 1ns / 1ps

module tb_rv_protocol;

    logic clk;
    logic reset;
    logic valid;
    logic ready;
    logic [63:0] data_in;
    logic [63:0] data_out;
    logic en_data_Tx;

    // Instantiate DUT
    rv_protocol dut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .ready(ready),
        .data_in(data_in),
        .data_out(data_out),
        .en_data_Tx(en_data_Tx)
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

        clk = 0;
        reset = 1;
        valid = 0;
        ready = 0;
        data_in = 64'h0;

        wait_cycle;
        reset = 0;
        wait_cycle;

        // Step 1: Valid asserted first
        data_in = 64'hDEADBEEFCAFEBABE;
        valid = 1;
        $display("T=%0t: VALID asserted, data_in = %h", $time, data_in);
        wait_cycle;

        // Step 2: Ready asserted → handshake will occur
        ready = 1;
        $display("T=%0t: READY asserted", $time);
      

        // Observe en_data_Tx and expect data_out in next cycle
        $display("T=%0t: Handshake should have occurred → en_data_Tx = %b", $time, en_data_Tx);
        wait_cycle;

        // Check if data_out has appeared
        $display("T=%0t: data_out = %h (should match data_in)", $time, data_out);

        // Clean-up
        valid = 0;
        ready = 0;
        wait_cycle;

        $display("T=%0t: Test complete.", $time);
        #300;
        $finish;
    end

endmodule
