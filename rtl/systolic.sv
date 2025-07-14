`timescale 1ns/1ps

module systolic(
    input logic clk,
    input logic reset,
    input logic valid,
    input logic signed [127:0] matrix_A,
    input logic signed [127:0] matrix_B,
    output logic signed [511:0] y,
    output logic overflow_flag,
    output logic done,
    output logic valid_out
);

    pe pe_inst (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .A_in(A_in),
        .B_in(B_in),
        .y_out(y_out),
        .A_out(A_out),
        .B_out(B_out),
        .overflow(overflow),
        .done(done),
        .valid_out(valid_out)
    );
endmodule