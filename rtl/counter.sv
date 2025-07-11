module counter(
    input logic clk,
    input logic reset,
    input logic done,
    output logic en_y
);
    logic [2:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 3'b0;
        end else if (done) begin
            if (count == 3'b111) begin
                count <= 3'b0;
            end else begin
                count <= count + 3'b1;
            end
        end else begin
            if (count == 3'b111) begin
                count <= 3'b0; // Reset count if it reaches 7
            end else begin
                count <= count; // Maintain current count
            end
        end
    end
    
    always_comb begin
        if (reset) begin
            en_y = 1'b0; // Disable output when reset
        end else begin
            en_y = (count == 3'b111) ? 1'b1 : 1'b0; // Enable when count reaches 7
        end
    end


endmodule

