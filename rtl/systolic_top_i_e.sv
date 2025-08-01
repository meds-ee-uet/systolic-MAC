module counter_controlled (
    input  logic clk,
    input  logic rst,             // Active-high, posedge reset
    input  logic enable,          // Enable signal
    output logic count_done
);

    logic [1:0] count;
    logic increment_allowed; // Flag to allow incrementing the count
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            increment_allowed <= 0;
            count_done <= 0;
        end else begin
            count_done <= 0; // Default: no done signal

            if (enable) begin
                if (!increment_allowed) begin
                    // First enable: only allow increment from next cycle
                    increment_allowed <= 1;
                end else begin
                    if (count < 3) begin
                        count <= count + 1;
                        if (count + 1 == 3) begin
                            count_done <= 1;
                            count <= 0;                // Reset counter
                            increment_allowed <= 0;    // Reset increment allowed
                        end
                    end
                end
            end
        end
    end

endmodule


module systolic_top (
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift,
    input  logic        src_ready,
    input  logic        done_matrix_mult, // for dest_valid (it goes to reg_def and then from ther we'll get dest_valid basically after one clk cycle)
    input  logic [511:0] systolic_output,
    output logic [63:0]  final_data_out,
    output logidc      sh_count_done,
    output logic         tx_two_done
);

    // Intermediate wires
    logic [511:0] buffer_to_feeder;
    logic [63:0]  feeder_to_rv;
    logic         en_data_Tx;
    logic         dest_valid; //

    // Buffer Register: 512-bit
    reg_def #(.WIDTH(512)) buffer (
        .x(systolic_output),
        .enable(load),
        .clk(clk),
        .clear(reset),
        .y(buffer_to_feeder)
    );

    // Data Feeder: Shifts 512-bit to 64-bit
    data_feeder #(
        .in_width(512),
        .out_width(64)
    ) feeder_i_e (
        .clk(clk),
        .data_in(buffer_to_feeder),
        .shift(shift),
        .reset(res_i_e),
        .load(load),
        .data_out(feeder_to_rv)
    );

    counter_controlled sh_counter_i_e (
        .clk(clk),
        .rst(reset),
        .enable(shift),
        .count_done(sh_count_done)
    );
    // RV Protocol
    rv_protocol rv_two (
        .clk(clk),
        .reset(reset),
        .valid(dest_valid),
        .ready(src_ready),
        .data_in(feeder_to_rv),
        .data_out(final_data_out),
        .en_data_Tx(en_data_Tx),
        .tx_done(tx_two_done)
    );

endmodule
