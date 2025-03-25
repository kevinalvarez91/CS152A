`timescale 1ns / 1ps

module display(
    input  wire clk,         // Clock input
    input  wire rst,         // Reset input
    input  wire switch,      // When low, blank display and freeze updates
    input  wire [7:0] score, // Score input (to be displayed on left 2 digits)
    output reg [6:0] seg,    // 7-segment display (active low)
    output reg [3:0] an,     // 4-digit anode signals (active low)
    output reg [1:0] current_arrow  // Exposed current arrow for scoring
);

    // 7-seg codes:
    // Order: [111:104]=Left arrow, [103:96]=Right arrow, [95:88]=Up arrow, [87:80]=Down arrow,
    // followed by digits 9,8,7,6,5,4,3,2,1,0.
    localparam [111:0] BCD_CODES = {
        8'b0000_0110,   // Left arrow
        8'b0011_0000,   // Right arrow
        8'b0000_0001,   // Up arrow
        8'b0000_1000,   // Down arrow
        8'b0110_1111,   // 9
        8'b0111_1111,   // 8
        8'b0000_0111,   // 7
        8'b0111_1101,   // 6
        8'b0110_1101,   // 5
        8'b0110_0110,   // 4
        8'b0100_1111,   // 3
        8'b0101_1011,   // 2
        8'b0000_0110,   // 1
        8'b0011_1111    // 0
    };

    // LFSR for pseudo-random arrow generation
    reg [7:0] lfsr;
    // Internal register for the next arrow value
    reg [1:0] next_arrow;
    
    // Counters for arrow update and for display scanning
    reg [31:0] arrow_refresh_counter;
    parameter ARROW_CLOCK_FREQ = 170000000;  // ~1-second update at 100MHz clock

    reg [15:0] scan_divider;
    reg [1:0] scan_digit; // cycles from 0 to 3 for 4-digit multiplexing
    parameter SCAN_DIVIDER_MAX = 5000;  // adjust for refresh rate and brightness

    // Score conversion: for score values assumed to be less than 100.
    // Compute tens and ones digits.
    wire [3:0] score_tens;
    wire [3:0] score_ones;
    assign score_tens = score / 10;
    assign score_ones = score - (score_tens * 10);

    // Function to get 7-seg pattern for a decimal digit (0-9)
    function [7:0] get_digit;
        input [3:0] digit;
        begin
            case(digit)
                4'd0: get_digit = BCD_CODES[7:0];
                4'd1: get_digit = BCD_CODES[15:8];
                4'd2: get_digit = BCD_CODES[23:16];
                4'd3: get_digit = BCD_CODES[31:24];
                4'd4: get_digit = BCD_CODES[39:32];
                4'd5: get_digit = BCD_CODES[47:40];
                4'd6: get_digit = BCD_CODES[55:48];
                4'd7: get_digit = BCD_CODES[63:56];
                4'd8: get_digit = BCD_CODES[71:64];
                4'd9: get_digit = BCD_CODES[79:72];
                default: get_digit = 8'b1111_1111;
            endcase
        end
    endfunction

    // Function to get 7-seg pattern for an arrow, based on a 2-bit code
    function [7:0] get_arrow;
        input [1:0] arrow;
        begin
            case(arrow)
                2'd0: get_arrow = BCD_CODES[87:80];    // Down arrow
                2'd1: get_arrow = BCD_CODES[95:88];    // Up arrow
                2'd2: get_arrow = BCD_CODES[103:96];   // Right arrow
                2'd3: get_arrow = BCD_CODES[111:104];  // Left arrow
                default: get_arrow = 8'b1111_1111;
            endcase
        end
    endfunction

    // Update LFSR for arrow generation
    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr <= 8'hA5;  // Non-zero seed
        else if (lfsr == 8'b00000000)  // Prevent stuck zero state
            lfsr <= 8'hA5;
        else
            lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[6] ^ lfsr[5] ^ lfsr[4]};
    end

    // Arrow update logic: update current_arrow and next_arrow periodically.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_arrow <= lfsr[1:0];
            next_arrow <= lfsr[3:2];
            arrow_refresh_counter <= 0;
        end else begin
            if (arrow_refresh_counter >= ARROW_CLOCK_FREQ - 1) begin
                arrow_refresh_counter <= 0;
                if (switch) begin
                    current_arrow <= next_arrow;
                    next_arrow <= lfsr[1:0] % 4;
                end
            end else begin
                arrow_refresh_counter <= arrow_refresh_counter + 1;
            end
        end
    end

    // 4-digit scanning logic: cycles through digits 0 to 3.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_divider <= 0;
            scan_digit <= 0;
        end else begin
            if (scan_divider >= SCAN_DIVIDER_MAX) begin
                scan_divider <= 0;
                scan_digit <= scan_digit + 1;
            end else begin
                scan_divider <= scan_divider + 1;
            end
        end
    end

    // Multiplexing logic: drive the seg and an signals based on the current scan_digit.
    always @(*) begin
        // Default blank
        seg = 7'b111_1111;
        an  = 4'b1111;
        if (!switch) begin
            // If switch is off, blank the display.
            seg = 7'b111_1111;
            an  = 4'b1111;
        end else begin
            case (scan_digit)
                2'd3: begin
                    // Digit 3 (leftmost): display score tens digit.
                    seg = ~get_digit(score_tens);
                    an  = 4'b0111;  // Activate digit 3 (bit3 low)
                end
                2'd2: begin
                    // Digit 2: display score ones digit.
                    seg = ~get_digit(score_ones);
                    an  = 4'b1011;  // Activate digit 2
                end
                2'd1: begin
                    // Digit 1: display current arrow.
                    seg = ~get_arrow(current_arrow);
                    an  = 4'b1101;  // Activate digit 1
                end
                2'd0: begin
                    // Digit 0 (rightmost): display next arrow.
                    seg = ~get_arrow(next_arrow);
                    an  = 4'b1110;  // Activate digit 0
                end
                default: begin
                    seg = 7'b111_1111;
                    an  = 4'b1111;
                end
            endcase
        end
    end

endmodule
