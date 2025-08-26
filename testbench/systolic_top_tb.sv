`timescale 1ps/1ps

module systolic_top_tb;

    logic clk;
    logic reset;
    logic valid_in;
    logic [63:0] data_in;
    logic src_valid;
    logic src_ready;
    logic [63:0] final_data_out;
    logic signed [31:0] el1;
    logic signed [31:0] el2;

    assign el2 = final_data_out[31:0];
    assign el1 = final_data_out[63:32];
    logic done_matrix_mult;

    systolic dut (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .data_in(data_in),
        .src_valid(src_valid),
        .src_ready(src_ready),
        .final_data_out(final_data_out),
        .done_matrix_mult(done_matrix_mult)
    );

    always #167 clk = ~clk; // Clock: 10ns period

    initial begin
        clk = 0;
        reset = 1;
        valid_in = 0;
        data_in = 64'd0;
        src_valid = 0;
        src_ready = 0;

        // ------------------------
        // FIRST RUN (positive integers)
        // ------------------------
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First 64-bit chunk
        data_in = {
            8'd1,  8'd2,  8'd3,  8'd4,
            8'd1,  8'd5,  8'd9,  8'd13
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            8'd5,  8'd6,  8'd7,  8'd8,
            8'd2,  8'd6,  8'd10, 8'd14
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd9,  8'd10, 8'd11, 8'd12,
            8'd3,  8'd7,  8'd11, 8'd15
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            8'd13, 8'd14, 8'd15, 8'd16,
            8'd4,  8'd8,  8'd12, 8'd16
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

      
        // Read outputs
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
        end
        $display("== Run 1 complete ==");

        final_data_out = 0;

        repeat(10) @(posedge clk); // Wait for a few cycles before starting the next run


        // ------------------------
        // SECOND RUN (with negative integers too) & NO RESET
        // ------------------------
        $display("\n== Starting Run 2 with negative integers ==");
        @(posedge clk);
        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First chunk
        data_in = {
            8'd23,  8'd54,  -8'd65,  8'd32,
            8'd23,  -8'd73,  8'd92,  8'd1
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            -8'd73,  8'd37,  -8'd37,  8'd37,
            8'd54, -8'd37,  8'd61, 8'd2
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd92,  -8'd61, 8'd31, 8'd30,
            8'd65,  8'd37, 8'd31, -8'd3
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            -8'd1, -8'd2, 8'd3, 8'd9,
            8'd32,  8'd37,  -8'd30, 8'd9
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Read outputs for second run
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
        end

        $display("== Run 2 complete ==");


        final_data_out = 0;

        repeat(10) @(posedge clk); // Wait for a few cycles before starting the next run


        //third example
        $display("\n== Starting Run 3 with negative integers ==");
        @(posedge clk);
        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First chunk
        data_in = {
            8'd23,  8'd54,  -8'd65,  8'd32,
            8'd23,  -8'd73,  8'd92,  8'd1
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            -8'd73,  8'd37,  -8'd37,  8'd37,
            8'd59, -8'd37,  8'd61, 8'd2
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd92,  8'd68, 8'd31, 8'd30,
            8'd65,  8'd37, 8'd31, -8'd3
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            -8'd1, -8'd2, 8'd3, 8'd9,
            8'd32,  8'd37,  -8'd30, 8'd9
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Read outputs for second run
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
        end

        $display("== Run 3 complete ==");

        final_data_out = 0;


        repeat(10) @(posedge clk); // Wait for a few cycles before starting the next run


        //fourth example
        $display("\n== Starting Run 4 with negative integers ==");
        @(posedge clk);
        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First chunk
        data_in = {
            8'd23,  8'd54,  -8'd65,  8'd32,
            8'd23,  -8'd73,  8'd92,  8'd1
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            -8'd73,  8'd37,  -8'd37,  8'd37,
            8'd54, -8'd37,  8'd61, 8'd2
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd92,  -8'd61, -8'd56, 8'd30,
            8'd65,  8'd37, 8'd31, -8'd3
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            -8'd1, -8'd2, 8'd3, 8'd9,
            8'd9,  8'd37,  -8'd30, 8'd9
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Read outputs for second run
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
        end

        $display("== Run 4 complete ==");

        final_data_out = 0;


        repeat(10) @(posedge clk); // Wait for a few cycles before starting the next run


        //fifth example
         $display("\n== Starting Run 5 with negative integers ==");
        @(posedge clk);
        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First chunk
        data_in = {
            8'd23,  8'd54,  -8'd65,  8'd32,
            8'd23,  -8'd73,  8'd92,  8'd1
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            -8'd16,  8'd37,  8'd39,  8'd37,
            8'd54, -8'd37,  8'd61, 8'd2
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd92,  -8'd61, 8'd31, 8'd30,
            8'd65,  8'd56, 8'd31, -8'd3
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            -8'd1, -8'd2, 8'd3, 8'd9,
            8'd32,  8'd37,  -8'd30, 8'd9
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Read outputs for second run
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
                 
        end

        $display("== Run 5 complete ==");

        final_data_out = 0;

        repeat(10) @(posedge clk); // Wait for a few cycles before starting the next run


        //sixth example
         $display("\n== Starting Run 6 with negative integers ==");
        @(posedge clk);
        valid_in = 1;
        @(posedge clk);
        valid_in = #1 0;

        // First chunk
        data_in = {
            8'd25,  8'd54,  -8'd65,  8'd32,
            8'd23,  -8'd73,  8'd92,  8'd1
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Second chunk
        data_in = {
            -8'd73,  8'd37,  -8'd37,  8'd37,
            8'd54, -8'd37,  8'd61, 8'd2
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Third chunk
        data_in = {
            8'd92,  -8'd61, 8'd31, 8'd30,
            8'd65,  8'd37, 8'd31, -8'd3
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Fourth chunk
        data_in = {
            8'd1, -8'd2, 8'd3, 8'd9,
            8'd32,  8'd65,  -8'd30, 8'd9
        };
        @(posedge clk);
        src_valid = 1;
        @(posedge clk);
        src_valid = 0;
        repeat(3) @(posedge clk);

        // Read outputs for second run
        for (int i = 0; i < 16; i++) begin
            src_ready = 1;
            wait(final_data_out);
            @(posedge clk);
            if (i < 4) begin
                for (int j = 0; j < 4; j++) begin
                    $display(" Element at row # %0d and column # %0d = %0d",  
                            i+1, j+1, dut.y_o[i][j]);
                    end
                end
            src_ready = 0;
        end

        $display("== Run 6 complete ==");




      #25000000;
        $finish;
    end

endmodule