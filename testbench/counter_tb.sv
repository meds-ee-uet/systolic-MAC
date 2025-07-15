`timescale 1ns/1ps
module counter_tb;


  // DUT signals
  logic clk = 0;
  logic rst = 1;      // start in reset
  logic done = 0;
  logic en_y;

  // 10 ns clock
  always #5 clk = ~clk;


  // Instantiate the DUT
  counter DUT (
    .clk   (clk),
    .reset (rst),
    .done  (done),
    .en_y  (en_y)
  );



  // generate one‑cycle ‘done’ pulse
  task automatic pulse_done;
    done <= 1;
    @(posedge clk);
    done <= 0;
  endtask



  initial begin
    // VCD for GTKWave
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);

    // Hold reset for two clocks
    repeat(2)   @(posedge clk);  
    rst = 0;

    // FIRST TIME
    $display("\n AT FIRST TIME");

    pulse_done();   
    pulse_done();   
    pulse_done();   
    pulse_done();   
    pulse_done();   
    pulse_done();   
    pulse_done();   


    // Check en_y
    if (en_y !== 1)
      $error("en_y did not assert at end of first time!");
    else
      $display(" en_y asserted correctly after 7 pulses (2nd time)");


    // Gap before next burst
    repeat(2)    @(posedge clk);  

    //SECOND TIME
    $display("\n AT SECOND TIME");

    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   
    pulse_done(); @(posedge clk);   



    // Check en_y
    if (en_y !== 1)
      $error("en_y did not assert at end of second time!");
    else
      $display(" en_y asserted correctly after 7 pulses (2nd time)");

    // All done
    $display("\nAll tests PASSED");
    $finish;
  end

endmodule
