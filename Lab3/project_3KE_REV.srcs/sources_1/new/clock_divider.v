// Submodule for a pulse-type clock divider (output is high for one clk cycle at the divider period)
module clk_divider_pulse #(
    parameter DIV_COUNT = 100_000_000  // Divider threshold
)(
    input  clk,
    input  rst,
    output reg clk_div
);
    // Calculate required counter width using $clog2 (SystemVerilog)
    reg [$clog2(DIV_COUNT)-1:0] counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_div <= 0;
        end else if (counter == DIV_COUNT - 1) begin
            counter <= 0;
            clk_div <= 1;    // Generate one-cycle pulse
        end else begin
            counter <= counter + 1;
            clk_div <= 0;
        end
    end
endmodule

// Submodule for a toggle-type clock divider (output toggles its state at the divider period)
module clk_divider_toggle #(
    parameter DIV_COUNT = 100_000_000  // Divider threshold
)(
    input  clk,
    input  rst,
    output reg clk_div
);
    reg [$clog2(DIV_COUNT)-1:0] counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_div <= 0;
        end else if (counter == DIV_COUNT - 1) begin
            counter <= 0;
            clk_div <= ~clk_div;  // Toggle output
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

// Top-level module instantiating the divider submodules
module clock_divider(
    input  clk_100MHz,  // 100 MHz clock input
    input  rst,
    output clk_1Hz,     // 1 Hz pulse output
    output clk_2Hz,     // 2 Hz pulse output
    output clk_fast,    // Fast pulse for display multiplexing
    output clk_blink    // Toggling clock for blinking display in adjustment mode
);
    // Main divider constant and frequency parameters
    parameter MAIN_DIV         = 100_000_000;
    parameter FAST_CLOCK_FREQ  = 500;  // Choose between 50-700 Hz for display refresh
    parameter BLINK_CLOCK_FREQ = 4;    // At least 1 Hz and not 2 Hz for blink rate

    // Instantiate 1 Hz pulse divider (100 MHz divided by MAIN_DIV)
    clk_divider_pulse #(
        .DIV_COUNT(MAIN_DIV)
    ) div1Hz (
        .clk(clk_100MHz),
        .rst(rst),
        .clk_div(clk_1Hz)
    );

    // Instantiate 2 Hz pulse divider (100 MHz divided by MAIN_DIV/2)
    clk_divider_pulse #(
        .DIV_COUNT(MAIN_DIV / 2)
    ) div2Hz (
        .clk(clk_100MHz),
        .rst(rst),
        .clk_div(clk_2Hz)
    );

    // Instantiate fast clock pulse divider for display multiplexing
    clk_divider_pulse #(
        .DIV_COUNT(MAIN_DIV / FAST_CLOCK_FREQ)
    ) divFast (
        .clk(clk_100MHz),
        .rst(rst),
        .clk_div(clk_fast)
    );

    // Instantiate blinking clock divider as a toggling output
    clk_divider_toggle #(
        .DIV_COUNT(MAIN_DIV / BLINK_CLOCK_FREQ)
    ) divBlink (
        .clk(clk_100MHz),
        .rst(rst),
        .clk_div(clk_blink)
    );
    
endmodule
