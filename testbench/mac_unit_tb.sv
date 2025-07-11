// mac_unit_tb.sv
`timescale 1ns/1ps
module mac_unit_tb;

//-----------------------------------------------------------------------------
// DUT signals
logic clk   = 0;
logic rst   = 1;               // start in reset
logic vld   = 0;
logic signed [7:0]  alpha = 0, beta = 0;
logic signed [31:0] gamma;
logic of, d;

//-----------------------------------------------------------------------------
// 10 ns‑period clock
always #5 clk = ~clk;

//-----------------------------------------------------------------------------
// DUT instantiation
mac_unit DUT (
    .clk      (clk),
    .reset    (rst),
    .valid    (vld),
    .A        (alpha),
    .B        (beta),
    .y        (gamma),
    .overflow (of),
    .done     (d)
);

//-----------------------------------------------------------------------------
// Events & flags
event pos_of_event, neg_of_event;
bit   pos_of_seen = 0, neg_of_seen = 0;

//-----------------------------------------------------------------------------
// Overflow monitors
// Use the value that actually caused the overflow: DUT.reg_acc_in
always_ff @(posedge clk) begin
    if (of && DUT.reg_acc_in[31] == 1'b0 && !pos_of_seen)
        -> pos_of_event;                        // positive overflow
    if (of && DUT.reg_acc_in[31] == 1'b1 && !neg_of_seen)
        -> neg_of_event;                        // negative overflow
end

//-----------------------------------------------------------------------------
// Stimulus: continually feed operands that will generate both overflows
initial begin
    // release reset
    repeat (2) @(posedge clk);
    rst = 0;

    forever begin
        apply_mac( 8'sd127 ,  8'sd127 );   // drives toward +2 147 483 647
        apply_mac(-8'sd128 ,  8'sd127 );   // drives toward −2 147 483 648
    end
end

//-----------------------------------------------------------------------------
// On first (positive) overflow
initial begin
    @(pos_of_event);
    pos_of_seen = 1;
    $display("\n*** POSITIVE overflow detected at %0t, acc_in = %0d ***",
             $time, DUT.reg_acc_in);
    // single‑cycle reset pulse
    rst = 1; @(posedge clk); rst = 0;
    $display("*** Reset released — searching for negative overflow ***\n");
end

//-----------------------------------------------------------------------------
// On first (negative) overflow → finish
initial begin
    @(neg_of_event);
    neg_of_seen = 1;
    $display("\n*** NEGATIVE overflow detected at %0t, acc_in = %0d ***",
             $time, DUT.reg_acc_in);
    rst = 1; @(posedge clk);
    $display("*** Test complete — stopping simulation ***");
    $finish;
end

//-----------------------------------------------------------------------------
// Task: single MAC transaction
task automatic apply_mac (input signed [7:0] a, input signed [7:0] b);
    alpha <= a;
    beta  <= b;
    vld   <= 1;
    @(posedge clk);
    vld   <= 0;
endtask

endmodule
