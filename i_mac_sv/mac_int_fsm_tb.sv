`timescale 1ns/1ps


module mac_int_fsm_tb();

//initializing test signals:
logic clk;
logic rst;
logic vld;
logic signed [15:0]alpha;
logic signed [15:0]beta;
logic signed [31:0]gamma;
logic d;

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
    alpha = 0;
    beta = 0;
    gamma = 0;
    d = 0;
    vld=0;
    //positive case tests:
    #10
    rst = 0;
    alpha=16'd30;
    beta=16'd40;
    vld=1;//will last for one whole clock cycle
    #10 vld=0;
    #100
    alpha=16'd10;
    beta=16'd16;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd50;
    beta=16'd25;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd100;
    beta=16'd23;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd100;
    beta=16'd24;
    vld=1;
    #10 vld=0;

    //negative case tests:
    #100 alpha=16'd100;
    beta=-16'd2;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd11;
    beta=-16'd11;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd7;
    beta=16'd2;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd40;
    beta=-16'd50;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd111;
    beta=-16'd2;
    vld=1;

    //edge cases tests(overflow  )
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=-16'd32768;
    vld=1;

    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;


    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;
    #10 vld=0;
    #100 alpha=-16'd32768;
    beta=16'd32767;
    vld=1;
    #10 vld=0;
    #100 alpha=16'd32767;
    beta=-16'd32768;
    vld=1;


    #10 vld=0;
    #100 rst=1;
    #10 rst=0;
    $stop;
end 


endmodule