`timescale 1ns/1ps

//8 bit signed multiplier, with 16 bit intermediate, with 32 bit accumulator
module mac_unit (
    input  logic         clk,
    input  logic         reset,
    input  logic         valid,
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,
    output logic signed [31:0] y,
    // output logic overflow,
    output logic         done
);
    logic enA, enB,enAcc, rsA, rsB, rsAcc;
    logic signed [7:0] reg_A_out, reg_B_out;
    logic signed [31:0] reg_acc_out, reg_acc_in;

    //registers declarations:
    //reg A
    reg_def reg_A (
    .x(A),
    .enable(enA),
    .clk(clk),
    .clear(rsA),
    .y(reg_A_out)
);
    //reg B
    reg_def reg_B (
    .x(B),
    .enable(enB),
    .clk(clk),
    .clear(rsB),
    .y(reg_B_out)
);
    //accumulator reg
    reg_def #(.WIDTH(32)) reg_Acc (
    .x(reg_acc_in),
    .enable(enAcc),
    .clk(clk),
    .clear(rsAcc),
    .y(reg_acc_out)
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        PROCESSING,
        DONE
    } state_t;

    state_t state, next_state;

    logic signed [15:0] mult;

    logic mult_done;

    // Combinational multiplier
    // always_comb begin
    //     mult = reg_A_out * reg_B_out;
    // end

    // State transition logic
    always_comb begin
        // Defaults for safety
        next_state = state;
        enA = 0;
        enB = 0;
        enAcc = 0;
        done = 0;

        case (state)
            IDLE: begin
                if (valid) begin
                    next_state = LOAD;
                end
            end

            LOAD: begin
                // Enable loading A and B only
                enA = 1;
                enB = 1;
                if (mult_done) begin
                    next_state = PROCESSING;
                end
                else begin
                    next_state = LOAD; // Stay in LOAD until multiplication is done
                end
            end

            PROCESSING: begin
                // Do mult + accumulation
                enAcc = 1;
                next_state = DONE;
            end

            DONE: begin
                done = 1;
                enAcc = 1; // Enable accumulator to hold the result
                next_state = IDLE;
            end
        endcase
    end


    // Sequential state update
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output and accumulation logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rsA <= 1'b1; // Reset A register
            rsB <= 1'b1; // Reset B register
            rsAcc <= 1'b1; // Reset accumulator register
            reg_acc_in <= 32'd0;
            // done <= 1'b0;
        end
        else begin
            // done <= 1'b0; // default
            rsA <= 1'b0; // Clear reset for A register
            rsB <= 1'b0; // Clear reset for B register
            rsAcc <= 1'b0; // Clear reset for accumulator register
            // reg_acc_in <= reg_acc_in; // Initialize accumulator input
            case (state)
                LOAD:begin
                    mult <= reg_A_out * reg_B_out; // Perform multiplication
                    mult_done<=1'b1; // Indicate multiplication is done
                end

                PROCESSING: begin
                    reg_acc_in <= reg_acc_out + mult;
                end
            endcase
        end
    end
    // assign overflow = (~(reg_acc_out[31] ^ mult[15]) && (mult[15] ^ reg_acc_in[31])) ? 1'b1 : 1'b0; // Check for overflow condition
    assign y = reg_acc_out; // Output the accumulated value
endmodule

