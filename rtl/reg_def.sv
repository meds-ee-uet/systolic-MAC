// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// Parameterized register with a synchronous reset
//
// Authors: Abdul Muiz(2023-EE-162) & Muhammad Waleed Akram (2023-EE-165)
//
// Date: 

module reg_def #(
    parameter int WIDTH = 8 // Default to 8 bits
)(
    input  logic [WIDTH-1:0] x,
    input  logic             enable,
    input  logic             clk,
    input  logic             clear,
    output logic [WIDTH-1:0] y
);
    always_ff @(posedge clk) begin
        if (clear) begin
            y <= {WIDTH{1'b0}}; // Reset to all zeros
        end else if (enable) begin
            y <= x;  // Register update logic
        end
    end
endmodule


