// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// This SystemVerilog testbench verifies the updated "data_feeder" module that loads a 56-bit word using `load`,
// and shifts 8 bits per `enable`. The reusable task `shift_7_bytes()` is used for testing.
//
// Authors:
// Muhammad Waleed Akram (2023-EE-165) & Abdul Muiz (2023-EE-162)
//
// Date:

`timescale 1ns/1ps

module data_feeder_tb;

  logic [55:0] data_to_be_fed;
  logic clk = 0;
  logic reset = 0;
  logic enable = 0;
  logic load = 0;
  logic [55:0] data_in;
  logic signed [7:0] data_out;

  // Clock generation
  always #5 clk = ~clk;

  // DUT instantiation
  data_feeder DUT (
    .clk(clk),
    .data_in(data_in),
    .enable(enable),
    .reset(reset),
    .load(load),
    .data_out(data_out)
  );

  // Task to shift 7 bytes (1 per enable)
  task automatic shift_7_bytes();
    for (int i = 0; i < 7; i++) begin
      enable <= 1;
      @(posedge clk);
      enable <= 0;
      $display("Time %0t | Byte %0d: data_out = 0x%0h", $time, i+1, data_out);
      @(posedge clk);  // for readability
    end
  endtask

  // Task to feed a 56-bit burst using load
  task automatic feed_burst(input [55:0] values, input string label);
    begin
      
      repeat(2) @(posedge clk); // Wait for 2 clock cycles before loading

      $display("\n%s", label);

      // Load data_in using load = 1
      data_in <= values;
      load <= 1;
      @(posedge clk);
      load <= 0;

      // Shift the 7 bytes out
      shift_7_bytes();
    end
  endtask

  initial begin
    // For GTKWave
    $dumpfile("data_feeder.vcd");
    $dumpvars(0, data_feeder_tb);

    // Initial reset to clear the shift register

    assign data_to_be_fed=56'h11223344556677;

    reset <= 1;
    @(posedge clk);
    reset <= 0;


    // Feed Burst 1
    feed_burst(data_to_be_fed, "Burst 1");

    // Wait a few cycles
    repeat (3) @(posedge clk);

    assign data_to_be_fed=56'hA1B2C3D4E5F607;

    reset <= 1;
    @(posedge clk);
    reset <= 0;
    // Feed Burst 2
    feed_burst(data_to_be_fed, "Burst 2");

    $display("\n== All data fed. Test complete. ==");
    $finish;
  end

endmodule
