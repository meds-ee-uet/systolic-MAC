module controlled_counter #(parameter int count_width = 1, parameter int count_limit = 4)(
    input  logic clk,
    input  logic rst,             // Active-high, posedge reset
    input  logic enable,          // Enable signal
    output logic count_done,
    output logic [count_width:0] count
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            count_done <= 0;
        end else begin
            count_done <= 0; // Default: no done signal
            if (enable) begin
                if (count < count_limit) begin
                    count <= count + 1;
                    if (count + 1 == count_limit) begin
                        count_done <= 1;
                        count <= 0;
                    end
                end
            end
        end
    end

endmodule