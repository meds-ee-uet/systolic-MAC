`timescale 1ns/1ps


module mac_int_fsm_tb();

//initializing test signals:
logic clk;
logic rst;
logic vld;
logic [15:0]alpha;
logic [15:0]beta;
logic [31:0]gamma;
logic d;
// module mac_int_fsm (
//     input  logic         clk,
//     input  logic         reset,
//     input  logic         valid,
//     input  logic signed [15:0] A,
//     input  logic signed [15:0] B,
//     output logic signed [31:0] y,
//     output logic         done
// );

//clock generation
always #5 clk = ~clk;

mac_int_fsm DUT(
    .clk(clk),
    .reset(rst),
    .valid(vld),
    .A(alpha),
    .B(beta),
    .y(gamma),
    .done(d)
);

//test
initial begin
    clk = 0;
    rst = 1;
    #10
    rst = 0;
    alpha=16'd30;
    beta=16'd40;
    vld=1;
    #10 vld=0;
    #30
    alpha=16'd10;
    beta=16'd16;
    vld=1;
    #10 vld=0;
    #30 alpha=16'd50;
    beta=16'd25;
    vld=1;
    #10 vld=0;
    #30 alpha=16'd100;
    beta=16'd23;
    vld=1;
    #10 vld=0;
    #30 alpha=16'd100;
    beta=16'd24;
    vld=1;
    #10 vld=0;
    #50 rst=1;
    #5 rst=0;
    $stop;
end 


endmodule