module counter_controlled (
    input  logic clk,
    input  logic rst,             // Active-high, posedge reset
    input  logic enable,          // Enable signal
    output logic count_done
);

    logic [2:0] count;
    logic increment_allowed; // Flag to allow incrementing the count
    always_ff @(posedge clk) begin
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
                    if (count < 7) begin
                        count <= count + 1;
                        if (count + 1 == 7) begin
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


module output_datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift,
    input  logic        src_ready,
    input  logic        done_matrix_mult, // for dest_valid (it goes to reg_def and then from ther we'll get dest_valid basically after one clk cycle)
    input  logic [511:0] systolic_output,
    input   logic         dest_valid,
    output logic [63:0]  final_data_out,
    output logic      sh_count_done,
    output logic         tx_two_done
);

    // Intermediate wires
    logic [511:0] buffer_to_feeder;
    logic [63:0]  feeder_to_rv;
    logic         en_data_Tx;

    // Buffer Register: 512-bit
    reg_def #(.WIDTH(512)) buffer (
        .x(systolic_output),
        .enable(1),
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
        .reset(reset),
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
        .tx_done(tx_two_done)
    );

    

endmodule
