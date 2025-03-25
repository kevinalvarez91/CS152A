module counter(
    input clk,
    input rst,
    input clk_1Hz,
    input clk_2Hz,
    input clk_fast,
    input clk_blink,
    input pause,
    input ADJ,
    input SEL,
    output [15:0] time_bcd
);

    // Internal registers for BCD seconds and minutes
    reg [7:0] seconds;
    reg [7:0] minutes;

    // Combine minutes and seconds to form the BCD time
    // Blinking effect: when ADJ is active and clk_blink pulses,
    // force either the minutes (when SEL is 0) or seconds (when SEL is 1) nibble to 4'hF.
    wire [15:0] base_time = {minutes, seconds};
    wire [15:0] blink_mask = { {8{~SEL}}, {8{SEL}} };
    assign time_bcd = base_time | ({16{ADJ && clk_blink}} & blink_mask);

    // Function: Increment seconds in BCD (00 to 59)
    function [7:0] inc_seconds(input [7:0] sec);
        reg [3:0] ones, tens;
        begin
            ones = sec[3:0];
            tens = sec[7:4];
            if (ones < 4'd9)
                ones = ones + 1;
            else begin
                ones = 4'd0;
                if (tens < 4'd5)
                    tens = tens + 1;
                else
                    tens = 4'd0;
            end
            inc_seconds = {tens, ones};
        end
    endfunction

    // Function: Increment minutes in BCD (allows minutes to accumulate)
    function [7:0] inc_minutes(input [7:0] min);
        reg [3:0] ones, tens;
        begin
            ones = min[3:0];
            tens = min[7:4];
            if (ones < 4'd9)
                ones = ones + 1;
            else begin
                ones = 4'd0;
                tens = tens + 1;
            end
            inc_minutes = {tens, ones};
        end
    endfunction

    // Update seconds:
    // In normal mode (not paused or in adjustment) the seconds increment on a 1 Hz pulse.
    // In adjustment mode (ADJ high) with SEL high, use a 2 Hz pulse.
    always @(posedge clk) begin
        if (rst)
            seconds <= 8'd0;
        else if ((!pause && !ADJ && clk_1Hz) || (ADJ && SEL && clk_2Hz))
            seconds <= inc_seconds(seconds);
    end

    // Update minutes:
    // In normal mode, minutes increment when seconds roll over (from 59 to 00) at a 1 Hz pulse.
    // In adjustment mode (ADJ high) with SEL low, use a 2 Hz pulse.
    always @(posedge clk) begin
        if (rst)
            minutes <= 8'd0;
        else if (((!pause && !ADJ && clk_1Hz) && (seconds == 8'h59)) || (ADJ && !SEL && clk_2Hz))
            minutes <= inc_minutes(minutes);
    end

endmodule
