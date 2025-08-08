// module counter_controlled (
//     input  logic clk,
//     input  logic rst,             // Active-high, posedge reset
//     input  logic enable,          // Enable signal
//     output logic count_done,
//     output logic [1:0] count
// );
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             count <= 0;
//             count_done <= 0;
//         end else begin
//             count_done <= 0; // Default: no done signal
//             if (enable) begin
//                 if (count < 4) begin
//                     count <= count + 1;
//                     if (count + 1 == 4) begin
//                         count_done <= 1;
//                         count <= 0;
//                     end
//                 end
//             end
//         end
//     end

// endmodule
module input_datapath(
    input logic clk,
    input logic reset,
    input logic [63:0] data_in,
    input logic src_valid,
    input logic dest_ready,
    input logic next_row,
    input logic next_col,
    output logic load_in_done,
    output logic tx_one_done,
    output logic [55:0]B_c1,
    output logic [55:0]B_c2,
    output logic [55:0]B_c3,
    output logic [55:0]B_c4,
    output logic [55:0]A_r1,
    output logic [55:0]A_r2,
    output logic [55:0]A_r3,
    output logic [55:0]A_r4
);

//  genvar 
    logic [63:0] protocol_out;
    logic row_done,col_done;
    logic [1:0] row_count, col_count;
    logic [31:0] A_r[3:0];
    logic [31:0] B_c[3:0];


    rv_protocol rv_one (
        .clk(clk),
        .reset(reset),
        .valid(src_valid),
        .ready(dest_ready),
        .data_in(data_in),
        .data_out(protocol_out),
        .tx_done(tx_one_done)
    );

    //manager circuit
    controlled_counter row_counter (
        .clk(clk),
        .rst(reset),
        .enable(next_row),
        .count_done(row_done),
        .count(row_count)
    );
    controlled_counter col_counter (
        .clk(clk),
        .rst(reset),
        .enable(next_col),
        .count_done(col_done),
        .count(col_count) 
    );

    assign load_in_done = row_done && col_done;

    logic [31:0] row_data;
    logic [31:0] col_data;

    assign row_data = protocol_out[63:32];
    assign col_data = protocol_out[31:0]; // adjust slice as needed

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : A_row_regs
            reg_def #(.WIDTH(32)) A_reg (
                .x(row_data),
                .enable(row_count == i),
                .clk(clk),
                .clear(reset),
                .y(A_r[i])
            );
        end
        for (i = 0; i < 4; i++) begin : B_col_regs
            reg_def #(.WIDTH(32)) B_reg (
                .x(col_data),
                .enable(col_count == i),
                .clk(clk),
                .clear(reset),
                .y(B_c[i])
            );
        end
    endgenerate

    assign A_r1 = {A_r[0],24'b0};
    assign A_r2 = {8'b0,A_r[1],16'b0};
    assign A_r3 = {16'b0,A_r[2],8'b0};
    assign A_r4 = {24'b0,A_r[3]};

    assign B_c1 = {B_c[0],24'b0};
    assign B_c2 = {8'b0,B_c[1],16'b0};
    assign B_c3 = {16'b0,B_c[2],8'b0};
    assign B_c4 = {24'b0,B_c[3]};

endmodule