/*`timescale 1ns / 1ps

module scoring(
    input wire clk,
    input wire rst,
    // Assume the current_arrow is provided externally (from the display module)
    input wire [1:0] current_arrow,  
    // User button inputs (assumed active-high and externally debounced)
    input wire btn_left,
    input wire btn_right,
    input wire btn_up,
    input wire btn_down,
    
    // Output score (8-bit counter, can be expanded if needed)
    output reg [7:0] score
);

    // Registers to hold previous state of each button for edge detection.
    reg btn_left_prev, btn_right_prev, btn_up_prev, btn_down_prev;
    
    // Edge detection and score update
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset score and button history on reset
            score         <= 8'd0;
            btn_left_prev <= 1'b0;
            btn_right_prev<= 1'b0;
            btn_up_prev   <= 1'b0;
            btn_down_prev <= 1'b0;
        end else begin
            // Detect a rising edge on the left button.
            if (btn_left && !btn_left_prev) begin
                // According to our mapping, a left arrow is represented as 2'd3.
                if (current_arrow == 2'd3)
                    score <= score + 1;
            end
            // Detect a rising edge on the right button.
            if (btn_right && !btn_right_prev) begin
                // Right arrow is 2'd2.
                if (current_arrow == 2'd2)
                    score <= score + 1;
            end
            // Detect a rising edge on the up button.
            if (btn_up && !btn_up_prev) begin
                // Up arrow is 2'd1.
                if (current_arrow == 2'd1)
                    score <= score + 1;
            end
            // Detect a rising edge on the down button.
            if (btn_down && !btn_down_prev) begin
                // Down arrow is 2'd0.
                if (current_arrow == 2'd0)
                    score <= score + 1;
            end
            
            // Update previous states of each button.
            btn_left_prev  <= btn_left;
            btn_right_prev <= btn_right;
            btn_up_prev    <= btn_up;
            btn_down_prev  <= btn_down;
        end
    end

endmodule
*/

`timescale 1ns / 1ps

module scoring(
    input wire clk,
    input wire rst,
    input wire [1:0] current_arrow,  
    input wire btn_left,
    input wire btn_right,
    input wire btn_up,
    input wire btn_down,
    input wire [15:0] led,  // Added input to check LED status
    output reg [7:0] score
);

    // Registers to hold previous state of each button for edge detection.
    reg btn_left_prev, btn_right_prev, btn_up_prev, btn_down_prev;

    // Function to check if scoring is allowed
    function score_allowed;
        input [15:0] led_state;
        begin
            score_allowed = led_state[14] | led_state[15] | led_state[16]; // Check if any of these LEDs are ON
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            score         <= 8'd0;
            btn_left_prev <= 1'b0;
            btn_right_prev<= 1'b0;
            btn_up_prev   <= 1'b0;
            btn_down_prev <= 1'b0;
        end else begin
            if (score_allowed(led)) begin // Only update if LEDs 14, 15, or 16 are ON
                if (btn_left && !btn_left_prev && current_arrow == 2'd3)
                    score <= score + 1;
                if (btn_right && !btn_right_prev && current_arrow == 2'd2)
                    score <= score + 1;
                if (btn_up && !btn_up_prev && current_arrow == 2'd1)
                    score <= score + 1;
                if (btn_down && !btn_down_prev && current_arrow == 2'd0)
                    score <= score + 1;
            end

            // Update previous states of each button
            btn_left_prev  <= btn_left;
            btn_right_prev <= btn_right;
            btn_up_prev    <= btn_up;
            btn_down_prev  <= btn_down;
        end
    end

endmodule

