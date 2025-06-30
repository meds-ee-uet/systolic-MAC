`timescale 1ns/1ps

module mac_int_fsm (
    input  logic         clk,
    input  logic         reset,
    input  logic         valid,
    input  logic signed [15:0] A,
    input  logic signed [15:0] B,
    output logic signed [31:0] y,
    output logic         done
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        DONE
    } state_t;

    state_t state, next_state;

    logic signed [31:0] mult;

    // Combinational multiplier
    always_comb begin
        mult = A * B;
    end

    // State transition logic
    always_comb begin
        next_state = state;  // Default
        case (state)
            IDLE:        if (valid) begin 
                next_state = PROCESSING;
                done=0;
            end
            PROCESSING:  begin
                next_state = DONE;
                done=0;
            end
            DONE: begin 
                next_state = IDLE;
                done=1;
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
            y    <= 32'b0;
            // done <= 1'b0;
        end
        else begin
            // done <= 1'b0; // default

            case (state)
            	IDLE:begin 
            	   y<=y;
            	   //done<=done;
            	end 
                PROCESSING: begin
                    y <= y + mult;
                    //done<=1;
                end
                // DONE: begin
                //    // done <= 1'b0;
                // end
            endcase
        end
    end

endmodule

