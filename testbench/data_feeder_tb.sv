// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// This SystemVerilog testbench verifies a `data_feeder` module by feeding two 56-bit bursts using a reset pulse to load data, 
// then sequentially enabling output shifts across 7 clock cycles. Each byte(8bit) is displayed after every second clock for clarity using a reusable `shift_7_bytes()` task.
// 
// Author:
// Muhammad Waleed Akram (2023-EE-165)
// 
// Date:


`timescale 1ns/1ps

module data_feeder_tb;

  logic clk = 0;
  logic reset = 0;
  logic enable = 0;
  logic [55:0] data_in;
  logic [7:0] data_out;


  always #5 clk = ~clk;


  data_feeder DUT (
    .clk(clk),
    .data_in(data_in),
    .enable(enable),
    .reset(reset),
    .data_out(data_out)
  );

  // Shift 7 times with enable = 1
  task automatic shift_7_bytes();
    for (int i = 0; i < 7; i++) begin
      enable <= 1;
      @(posedge clk);
      enable <= 0;
      $display("Time %0t | Byte %0d: data_out = 0x%0h", $time, i+1, data_out);
      @(posedge clk);  // gap for clarity(2nd clk cycle)
    end
  endtask

  // Feed a burst
  task automatic feed_burst(input [55:0] values, input string label);
    begin
      $display("\n %s ", label);

      // Reset HIGH for 1 cycle to load data
      data_in <= values;
      @(posedge clk);
      reset <= 1;
      @(posedge clk);
      reset <= 0;

      // Shift bytes
      shift_7_bytes();
    end
  endtask

  initial begin
    //for gtkwave
    $dumpfile("data_feeder.vcd");   // VCD file name
    $dumpvars(0, data_feeder_tb);   // dump everything under the TB

    // Feed first 56-bit burst
    feed_burst(56'h11223344556677, "Burst 1");

    // Wait 2-3 clocks before next reset
    repeat (3) @(posedge clk);

    // Feed second 56-bit burst
    feed_burst(56'hA1B2C3D4E5F607, "Burst 2");

    $display("\n== All data fed. Test complete. ==");
    $finish;
  end

endmodule
