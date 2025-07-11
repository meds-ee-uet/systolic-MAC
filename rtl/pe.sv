timescale 1ns/1ps

module pe{
    input logic clk,
    input logic reset,
    input logic valid,
    input logic signed [7:0] A_in,
    input logic signed [7:0] B_in,
    output logic signed [31:0] y_out,
    output logic [7:0] A_out,
    output logic [7:0] B_out,
    output logic overflow,
    output logic done,
    output logic valid_out
};

    logic signed [31:0] y;
    logic en_y;
    mac_unit mac_unit_inst (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .A(A_in),
        .B(B_in),
        .y(y),
        .overflow(overflow),
        .done(done)
    );

    reg_def reg_A (
        .x(A_in),
        .enable(done),
        .clk(clk),
        .clear(reset),
        .y(A_out)
    );

    reg_def reg_B (
        .x(B_in),
        .enable(done),
        .clk(clk),
        .clear(reset),
        .y(B_out)
    );

    count counter(
        .clk(clk),
        .global_reset(reset),
        .done(done),
        .en_y(en_y)
    );

    reg_def reg_y(
        .x(y),
        .enable(en_y),
        .clk(clk),
        .clear(reset),
        .y(y_out)
    );

    reg_def delay_reg#(.WIDTH(1))(
        .x(en_y),
        .enable(1'b1),
        .clk(clk),
        .clear(reset|valid_out),
        .y(valid_out)
    );

endmodule