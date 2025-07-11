module counter(
    input logic clk,
    input logic reset,
    input logic done,
    output logic en_y
);
    logic [2:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            en_y <= 1'b0;
            count <= 3'b0;
        end else if (done) begin
            if (count == 3'b111) begin
                en_y <= 1'b1;
                count <= 3'b0;
            end else begin
                en_y <= 1'b0;
                count <= count + 3'b1;
            end
        end else begin
            en_y <= 1'b0;
        end
    end

endmodule

