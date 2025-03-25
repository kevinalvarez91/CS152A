module stopwatch (
    input         clk,        // 100 MHz master clock
    input         btnC,       // Pause button (center)
    input         btnR,       // Asynchronous reset button (right)
    input  [15:0] sw,         // 16 slide switches (using bits 0 and 1 for SEL and ADJ)
    output [6:0]  seg,        // 7-segment LED display
    output [3:0]  an          // 4-digit anode signals
);

   // ---------------------------------------------------------------------------
   // 7-Segment BCD Lookup Table: Encoded for digits 0-9 (stored in reverse order)
   // ---------------------------------------------------------------------------
   localparam [79:0] BCD_CODES = {
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

   // ---------------------------------------------------------------------------
   // Asynchronous Reset Logic
   // ---------------------------------------------------------------------------
   reg  [1:0]  arst_ff;       // Reset synchronizer flip-flops
   wire        arst_sync;     // Synchronized reset signal
   wire        rst;           // Active-high reset

   assign arst_sync = btnR;
   assign rst       = arst_ff[0];

   always @(posedge clk or posedge arst_sync) begin
      if (arst_sync)
         arst_ff <= 2'b11;
      else
         arst_ff <= {1'b0, arst_ff[1]};
   end

   // ---------------------------------------------------------------------------
   // Digit Scanning and 7-Segment Conversion
   // ---------------------------------------------------------------------------
   reg  [1:0] position;       // 2-bit counter for scanning 4 digits
   reg  [6:0] seg_reg;        // Internal register for segment outputs
   reg  [3:0] an_reg;         // Internal register for anode control

   wire [15:0] time_bcd;      // 16-bit BCD time (4 digits × 4 bits)
   wire [3:0]  current_digit; // Selected 4-bit digit value

   // Cycle through each digit position at a fast clock rate
   // (clk_fast is generated in the clock divider module)
   wire clk_fast, clk_1Hz, clk_2Hz, clk_blink;
   always @(posedge clk) begin
      if (rst)
         position <= 2'd0;
      else if (clk_fast)
         position <= position + 1;
   end

   // Extract the appropriate digit from time_bcd using shifting
   assign current_digit = time_bcd >> {position, 2'b00};

   // Drive the anode and segment outputs (active-low)
   always @(posedge clk) begin
      an_reg  <= ~(4'b0001 << position);
      seg_reg <= ~(BCD_CODES >> {current_digit, 3'b000});
   end

   assign an  = an_reg;
   assign seg = seg_reg;

   // ---------------------------------------------------------------------------
   // Slide Switch Handling for Adjust and Select Modes
   // ---------------------------------------------------------------------------
   reg ADJ, SEL;
   always @(posedge clk) begin
      ADJ <= ~rst & sw[1];
      SEL <= ~rst & sw[0];
   end

   // ---------------------------------------------------------------------------
   // Pause Button Debounce and Toggle Logic
   // ---------------------------------------------------------------------------
   reg         pause;       // Pause state
   reg         btnC_valid;  // Validated (debounced) pause button pulse
   reg  [2:0]  btnC_shift;  // Shift register for debouncing btnC
   reg         clk_fast_d;  // Delayed version of clk_fast

   // Shift in the btnC signal at the fast clock rate for debouncing
   always @(posedge clk) begin
      if (rst)
         btnC_shift <= 3'b000;
      else if (clk_fast)
         btnC_shift <= {btnC, btnC_shift[2:1]};
   end

   // Create a delayed version of clk_fast
   always @(posedge clk)
      clk_fast_d <= clk_fast;

   // Generate a debounced button pulse (btnC_valid goes high on a falling edge)
   always @(posedge clk) begin
      if (rst)
         btnC_valid <= 1'b0;
      else
         btnC_valid <= ~btnC_shift[0] & btnC_shift[1] & clk_fast_d;
   end

   // Toggle the pause state on a valid btnC press
   always @(posedge clk) begin
      if (rst || btnC_valid)
         pause <= ~rst & ~pause;
   end

   // ---------------------------------------------------------------------------
   // Module Instantiations: Counter and Clock Divider
   // ---------------------------------------------------------------------------
   counter counter_inst (
      .time_bcd  (time_bcd),
      .clk_1Hz   (clk_1Hz),
      .clk_2Hz   (clk_2Hz),
      .clk_fast  (clk_fast),
      .clk_blink (clk_blink),
      .pause     (pause),
      .ADJ       (ADJ),
      .SEL       (SEL),
      .clk       (clk),
      .rst       (rst)
   );

   clock_divider clock_div_inst (
      .clk_1Hz      (clk_1Hz),
      .clk_2Hz      (clk_2Hz),
      .clk_fast     (clk_fast),
      .clk_blink    (clk_blink),
      .clk_100MHz   (clk),
      .rst          (rst)
   );

endmodule
