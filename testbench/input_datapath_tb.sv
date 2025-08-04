`timescale 1ns / 1ps

module input_datapath_tb;

  // Clock and reset
  logic clk;
  logic reset;

  // Inputs to DUT
  logic [63:0] data_in;
  logic src_valid;
  logic dest_ready;
  logic next_row;
  logic next_col;

  // Outputs from DUT
  logic [55:0] data_out[2:0];
  logic load_done;
  logic tx_one_done;
  logic [55:0]B_c1, B_c2, B_c3, B_c4;
  logic [55:0]A_r1, A_r2, A_r3, A_r4;

  // Instantiate DUT
  input_datapath dut (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .src_valid(src_valid),
    .dest_ready(dest_ready),
    .next_row(next_row),
    .next_col(next_col),
    .data_out(data_out),
    .load_done(load_done),
    .tx_one_done(tx_one_done),
    .B_c1(B_c1), .B_c2(B_c2), .B_c3(B_c3), .B_c4(B_c4),
    .A_r1(A_r1), .A_r2(A_r2), .A_r3(A_r3), .A_r4(A_r4)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  // Helper task to wait one clock cycle
  task wait_cycle;
    @(posedge clk);
  endtask

  initial begin

    // Initialize
    clk = 0;
    reset = 1;
    src_valid = 0;
    dest_ready = 0;
    next_row = 0;
    next_col = 0;
    data_in = 64'h0;

    wait_cycle;
    reset = 0;
    wait_cycle;

    // Send data
    data_in = 64'hA1B2C3D4_E5F60708;  // 32-bit row = A1B2C3D4, 32-bit col = E5F60708
    src_valid = 1;
    wait_cycle;

    dest_ready = 1;
    wait_cycle;

    $display("T=%0t: Handshake done, tx_one_done=%b", $time, tx_one_done);
    $display("          protocol_out (row_data) = %h", dut.protocol_out[63:32]);
    $display("          protocol_out (col_data) = %h", dut.protocol_out[31:0]);

    // Deassert inputs
    src_valid = 0;
    dest_ready = 0;
    wait_cycle;

    

    // Trigger counters for 4 rows and 4 columns
    repeat (4) begin
      next_row = 1;
      next_col = 1;
      wait_cycle;
      next_row = 0;
      next_col = 0;
      wait_cycle;

      $display("T=%0t: row_count=%0d, col_count=%0d", $time, dut.row_count, dut.col_count);
    end

    // Wait for load_done signal
    wait (load_done == 1);
    $display("T=%0t: load_done = %b", $time, load_done);

    // Display final outputs
    $display("A_r1 = %h", A_r1);
    $display("A_r2 = %h", A_r2);
    $display("A_r3 = %h", A_r3);
    $display("A_r4 = %h", A_r4);
    $display("B_c1 = %h", B_c1);
    $display("B_c2 = %h", B_c2);
    $display("B_c3 = %h", B_c3);
    $display("B_c4 = %h", B_c4);

    #100;
    $finish;
  end

endmodule
