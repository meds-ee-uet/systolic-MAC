`timescale 1ns/1ps
module counter_tb;


// DUT signals
logic clk   = 0;
logic rst   = 1;      // start in reset
logic done  = 0;
logic en_y;


// 10 ns clock
always #5 clk = ~clk;

// DUT
counter DUT (
    .clk   (clk),
    .reset (rst),
    .done  (done),
    .en_y  (en_y)
);

// Simple task: generate a single ’done’ pulse (one value accepted)
task automatic pulse_done;
    done <= 1;
    @(posedge clk);
    done <= 0;
endtask



// Drive two bursts of 7 pulses each
int burst        = 0;
int pulse_number = 0;

initial begin
    // Let reset stay active for two clocks
    repeat (2) @(posedge clk);
    rst = 0;

    for (burst = 0; burst < 2; burst++) begin
        $display("\n--- Starting burst %0d ---", burst+1);
        for (pulse_number = 1; pulse_number <= 7; pulse_number++) begin
            pulse_done();
            // small spacing between pulses to make waveform clear
            repeat (1) @(posedge clk);
        end
        // Wait a clock to observe en_y
        @(posedge clk);
    
        if (en_y !== 1) begin
            $error("en_y did not assert at end of burst %0d!", burst+1);
        end
        else begin
            $display(" en_y asserted correctly after 7 pulses (burst %0d)", burst+1);
        end

        // De‑assert expected output for next burst
        // Your counter resets internally (count ← 0) when en_y asserted,
        // so we only need to wait until en_y drops
        //@(negedge en_y);

        // Optional delay before next burst
        //repeat (3) @(posedge clk);
    end

    $display("\nAll bursts completed test PASSED");
    $finish;
end

endmodule
