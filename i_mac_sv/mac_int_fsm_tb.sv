`timescale 1ns/1ps

module mac_int_fsm_tb();

  // Testbench signals
  logic clk;
  logic rst;
  logic vld;
  logic signed [7:0] alpha;
  logic signed [7:0] beta;
  logic signed [15:0] gamma;
  logic of;
  logic d;

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  // DUT instantiation
  mac_int_fsm DUT (
    .clk(clk),
    .reset(rst),
    .valid(vld),
    .A(alpha),
    .B(beta),
    .y(gamma),
    .overflow(of),
    .done(d)
  );

  // Main stimulus
  initial begin
    // Initialize
    clk = 0;
    rst = 1;
    alpha = 0;
    beta = 0;
    gamma = 0;
    vld = 0;

    $monitor("Time=%0t | A=%0d B=%0d mult=%0d acc=%0d overflow=%b done=%b", 
          $time, alpha, beta, DUT.mult, DUT.reg_acc_out, of, d);

    #10 rst = 0;

    // Positive MAC tests
    apply_mac(8'd30, 8'd40);
    apply_mac(8'd10, 8'd8);
    apply_mac(8'd50, 8'd25);
    apply_mac(8'd100, 8'd23);
    apply_mac(8'd100, 8'd24);

    // Negative MAC tests
    apply_mac(8'd100, -8'd2);
    apply_mac(8'd11, -8'd11);
    apply_mac(8'd7, 8'd2);
    apply_mac(8'd40, -8'd50);
    apply_mac(-8'd111, -8'd2);

    // Edge case test: loop until overflow
    $monitor("== Starting Overflow Detection Loop ==");
    fork
      begin
        forever begin
          apply_mac(8'd127, 8'd127);//include - to test for negative overflow
        end
      end
      begin
        wait (of == 1);
        $display("!!! OVERFLOW DETECTED at time %0t, result = %0d !!!", $time, gamma);
        $stop;
      end
    join_any
    disable fork;
  end

  // Task to apply a MAC operation
  task apply_mac(input signed [7:0] a, input signed [7:0] b);
    begin
      #100;
      alpha = a;
      beta  = b;
      vld   = 1;
      #10 vld = 0;
    end
  endtask

endmodule
