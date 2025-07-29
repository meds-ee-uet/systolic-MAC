// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// This SystemVerilog testbench verifies a Multiply-Accumulate (MAC) unit by feeding it a series of 7 signed 8-bit input pairs and observing the cumulative 32-bit output after
// each operation. It uses a done signal for synchronization and generates waveform output for GTKWave analysis.
//
// Author:
// Muhammad Waleed Akram (2023-EE-165) & Abdul Muiz (2023-EE-162)
//
// Date:


`timescale 1ns/1ps

module mac_unit_tb;

  logic clk = 0;
  logic reset;
  logic valid;
  logic signed [7:0] A, B;
  logic signed [31:0] y;
  logic done;

  // Instantiate the DUT
  mac_unit dut (
    .clk(clk),
    .reset(reset),
    .valid(valid),
    .A(A),
    .B(B),
    .y(y),
    .done(done)
  );

  // Clock generation
  always #5 clk = ~clk; // 10ns clock period

  initial begin
    // Initialize
    reset = 1; 
    valid = 0; 
    A = 0; 
    B = 0;
    #15; // hold reset for some time
    reset = 0;

    // 1st pair
    A = 8'd5;
    B = 8'd3;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk); 
    $display("y after 1st: %0d", y);

    // 2nd pair
    A = 8'd4;
    B = -8'd2;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk); 
    $display("y after 2nd: %0d", y);

    // 3rd pair
    A = -8'd6;
    B = 8'd1;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk);
    $display("y after 3rd: %0d", y);

    // 4th pair
    A = 8'd7;
    B = 8'd2;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk);
    $display("y after 4th: %0d", y);

    // 5th pair
    A = -8'd3;
    B = -8'd4;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk);
    $display("y after 5th: %0d", y);

    // 6th pair
    A = 8'd2;
    B = 8'd6;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk);
    $display("y after 6th: %0d", y);

    // 7th pair
    A = -8'd1;
    B = 8'd5;
    valid = 1;
    #10;
    valid = 0;
    wait(done);
    @(posedge clk);
    $display("y after 7th: %0d", y);

    #20;
    $display("MAC operation complete.");
    $finish;
  end

initial begin
    //for gtkwave
    $dumpfile("mac_unit.vcd");   // VCD file name
    $dumpvars(0, mac_unit_tb);   // dump everything under the TB

end

endmodule

