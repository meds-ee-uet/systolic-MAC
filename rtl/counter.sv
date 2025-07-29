// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
// Counter that keeps count of the done signals from a mac-unit
//
// Authors: Abdul Muiz(2023-EE-162) & Muhammad Waleed Akram (2023-EE-165)
// 
// Date:

module counter(
    input logic clk,
    input logic reset,
    input logic done,
    output logic en_y
);
    logic [3:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 4'b0;
        end else if (done) begin
            if (count == 4'd14) begin
                count <= 4'b0;
            end else begin
                count <= count + 4'b1;
            end
        end else begin
            if (count == 4'd14) begin
                count <= 4'b0; // Reset count if it reaches 7
            end else begin
                count <= count; // Maintain current count
            end
        end
    end
    
    always_comb begin
        if (reset) begin
            en_y = 1'b0; // Disable output when reset
        end else begin
            en_y = (count == 4'd14) ? 1'b1 : 1'b0; // Enable when count reaches 7
        end
    end


endmodule

