`timescale 1ns/1ps

module output_datapath_tb;

  // DUT signals
  logic clk = 0;
  logic reset = 0;
  logic load_out = 0;
  logic shift = 0;
  logic src_ready = 0;
  logic [511:0] systolic_output = 0;
  logic dest_valid = 0;
  logic [63:0] final_data_out;
  logic sh_count_done;
  logic tx_two_done;
 // logic done_matrix_mult ;

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  // Instantiate DUT
  output_datapath dut (
    .clk(clk),
    .reset(reset),
    .load_out(load_out),
    .shift(shift),
    .src_ready(src_ready),
  //  .done_matrix_mult(done_matrix_mult),
    .systolic_output(systolic_output),
    .dest_valid(dest_valid),
    .final_data_out(final_data_out),
    .sh_count_done(sh_count_done),
    .tx_two_done(tx_two_done)
  );

  // Helper tasks
  task reset_dut();
    reset <= 1;
    @(posedge clk);
    reset <= 0;
    @(posedge clk);
  endtask

  task load_out_data(input [511:0] data);
    systolic_output <= data;
    @(posedge clk);
    load_out <= 1;
    @(posedge clk);
    load_out <= 0;
    @(posedge clk);
  endtask

  task transfer_64bit_block(input int index);
    $display("=== Transferring chunk %0d ===", index);
    shift <= 1;
    @(posedge clk);
    shift <= 0;
    @(posedge clk);
    dest_valid <= 1;
    @(posedge clk);
    src_ready <= 1;
    @(posedge clk);
    dest_valid <= 0;
    src_ready <= 0;
    @(posedge clk);
    $display("T=%0t | Chunk %0d out = %h |  tx_two_done = %b", 
              $time, index, final_data_out,  tx_two_done);
  endtask

  task observe_64bit_block(input int index);
    $display("=== Observing chunk %0d (before any shift) ===", index);
    dest_valid <= 1;
    @(posedge clk);
    src_ready <= 1;
    @(posedge clk);
    dest_valid <= 0;
    src_ready <= 0;
    @(posedge clk);
    $display("T=%0t | Chunk %0d out = %h | tx_two_done = %b",
              $time, index, final_data_out,  tx_two_done);
  endtask

  // Main test
  initial begin
    logic [511:0] test_data = 512'hDEADBEEFCAFEBABE_1122334455667788_99AABBCCDDEEF00D_123456789ABCDEF0_13579BDFDEADBEEF_2468ACE0FEDCBA98_0FEDCBA987654321_1122334455667788;

    reset_dut();
    @(posedge clk);

    load_out_data(test_data);

    $display("T=%0t: buffer_to_feeder = %h", $time, dut.buffer_to_feeder);

    $monitor("T=%0t: feeder_to_rv = %h | count = %0d | sh_count_done = %b ", 
              $time, dut.feeder_to_rv, dut.sh_counter_output_datapath.count, dut.sh_count_done);

    @(posedge clk); // Let load_out settle
    @(posedge clk); // Wait one extra cycle so first output appears next cycle// 
    observe_64bit_block(0);

    for (int i = 1; i < 8; i++) begin
      transfer_64bit_block(i);
    end

    if (sh_count_done)
      $display("sh_count_done asserted as expected.");
    else
      $display("ERROR: sh_count_done not asserted after 7 shifts.");

    $display("\n== Test complete ==");
    #50;
    $finish;
  end

endmodule
