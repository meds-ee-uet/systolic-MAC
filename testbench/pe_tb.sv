// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// This SystemVerilog testbench verifies a "pe" (Processing Element) module by feeding it 7 signed input pairs with a "valid" handshake,
// and waits for a `done` signal to log outputs including `y_out`, `A_out`, `B_out`, and `valid_out`. It includes waveform dumping and 
// uses arrays to manage input data sequences cleanly.
// 
// Author:
// Muhammad Waleed Akram (2023-EE-165) & Abdul Muiz (2023-EE-162)
// 
// Date:


`timescale 1ns/1ps

module pe_tb;

  // DUT inputs
  reg clk;
  reg reset;
  reg valid;
  reg signed [7:0] A_in, B_in;

  // DUT outputs
  wire signed [31:0] y_out;
  wire [7:0] A_out, B_out;
  //wire overflow;
  wire done;
  wire valid_out;

  // Instantiate DUT
  pe dut (
    .clk(clk),
    .reset(reset),
    .valid(valid),
    .A_in(A_in),
    .B_in(B_in),
    .y_out(y_out),
    .A_out(A_out),
    .B_out(B_out),
    //.overflow(overflow),
    .done(done),
    .valid_out(valid_out)
  );

  // Clock generation
  always #5 clk = ~clk; // 100MHz

  integer i;

  reg signed [7:0] A_vals [0:6];
  reg signed [7:0] B_vals [0:6];

  initial begin
    // Initialize clock
    clk = 0;

    // Initialize input vectors
    A_vals[0] = 7'd10;
    A_vals[1] = -7'd20;
    A_vals[2] = 7'd30;
    A_vals[3] = -7'd40;
    A_vals[4] = 7'd50;
    A_vals[5] = -7'd60;
    A_vals[6] = 7'd70;

    B_vals[0] = 7'd2;
    B_vals[1] = 7'd3;
    B_vals[2] = -7'd4;
    B_vals[3] = 7'd5;
    B_vals[4] = -7'd6;
    B_vals[5] = 7'd7;
    B_vals[6] = -7'd8;

    // Initialize inputs
    reset = 1;
    valid = 0;
    A_in = 0;
    B_in = 0;

    // Hold reset
    #20;
    reset = 0;

    // Feed 7 inputs
    for (i = 0; i < 7; i = i + 1) begin
      @(posedge clk);
      A_in = A_vals[i];
      B_in = B_vals[i];
      valid = 1;

      @(posedge clk);
      valid = 0;

      // Wait for done to go high
      wait (done == 1);

      $display("[%0t] A_in=%0d B_in=%0d -> y_out=%0d A_out=%0d B_out=%0d  valid_out=%b",
               $time, A_in, B_in, y_out, A_out, B_out,  valid_out);

      // Wait for done to drop back to 0
      @(posedge clk);
      wait (done == 0);
      #100;
    end

    $display("All inputs done");
    $stop;
  end


initial begin
    //for gtkwave
    $dumpfile("pe.vcd");   // VCD file name
    $dumpvars(0, pe_tb);   // dump everything under the TB

end

endmodule
