`timescale 1ns / 1ps

module ddr(
    input wire clk,
    input wire rst,
    input wire switch,
    output wire [15:0] led,            // LED output for DDR timing (existing functionality)
    output wire [6:0] seg,
    output wire [3:0] an,
    input wire btn_right, 
    input wire btn_left, 
    input wire btn_up, 
    input wire btn_down            
);

    wire [1:0] current_arrow;
    wire [7:0] score;


    // Instance of the ddr_led_timing module
    ddr_led_timing u1 (
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .led(led)
    );

    // Scoring module instance (assumes your original scoring module)
    scoring u_scoring (
        .clk(clk),
        .rst(rst),
        .current_arrow(current_arrow),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .led(led),
        .score(score)
    );

    // Display module instance
    display u_display (
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .score(score),
        .seg(seg),
        .an(an),
        .current_arrow(current_arrow)
    );



endmodule
