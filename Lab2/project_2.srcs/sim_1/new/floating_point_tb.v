//Test_bench 
module t_b;
    // Declare testbench signals
    reg [11:0] D;            // 12-bit input to the DUT
    wire [2:0] E;		//3-bit Exponent out
    wire [3:0] F;		//4-bit Floating point out
    wire S;		//1-bit Sign out 
    // Instantiate the Device Under Test (DUT)
    floating_point dut (
        .D(D),
        .E(E), 
        .F(F),
        .S(S) 
    );

// Monitor Output <-- this is only for ensuring the output is correctly running ->
initial begin
	 $monitor("Time: %0t | D: %b | S: %b | E: %d | F: %b", $time, D, S, E, F);
end

// Test stimulus
initial begin

	//Test Case 1: Positive number
	D = 12'b0100_0000_0000; #100; 

	//Test Case 2: Positive number with rounding
	D = 12'b0011_1111_1111; #100; // Wait for some time
	
	
//Test Case 3: Negative number
	D = 12'b1100_0000_0000; #100;
	
	//Test Case 4: Max negative number
	D = 12'b1111_1111_1111; #100; 

	//Test Case 5: Positive small number
	D = 12'b000_0000_1111; #100; 

	//Test Case 6: Random positive number
	D = 12'b0011_1010_1100; #100; 


	//Finish simulation
	#500;
$finish;
end 
endmodule 
