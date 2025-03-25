module ddr_led_timing(
    input wire clk,
    input wire rst,
    input wire switch,
    output reg [15:0] led
);

    parameter DELAY_COUNT = 10000000;
    
    reg [31:0] counter;
    reg [4:0] current_led;
    
    // Always block for reset and counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers asynchronously when rst is high
            counter <= 0;
            current_led <= 0;
            led <= 0;
        end else if (switch) begin
            // Normal operation logic
            if (counter < DELAY_COUNT) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                if (current_led < 16) begin
                    led[current_led] <= 1'b1;
                    current_led <= current_led + 1;
                end
                
                if (current_led >= 16) begin
                    led <= 0;
                    current_led <= 0;
                end
            end
        end else begin
            // When switch is off, reset the counters and LED
            counter <= 0;
            current_led <= 0;
            led <= 0;
        end
    end
endmodule

