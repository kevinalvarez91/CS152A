//Floating_point
module floating_point(
input wire[11:0] D, // 12-bit input
output reg[2:0] E,  // 3-bit Exponent out
output reg[3:0] F,   // 4-bit Floating point out
output reg S          // 1-bit Sign Out 
    );
    reg [3:0] significand;
    reg [3:0] leading_zeros;
    reg [3:0] exponent;
    reg [11:0] in;
    reg sign;
    integer i;
    reg fifthBit;
    reg found_first_nonzero_bit;
    
    always @(*) begin
    leading_zeros = 0;
    significand = 0;
    sign = D[11];
    S = sign; //Updating the S output to reflect sign
    found_first_nonzero_bit = 0;
    
    
    if(sign == 0) begin
	in = {1'b0, D[10:0]};
    end else begin
	in = {1'b0, ~D[10:0]}+1;
    end

    for (i = 11; i>= 0; i = i - 1) begin
        if (in[i] == 1'b0 && !found_first_nonzero_bit) begin
        	leading_zeros = leading_zeros + 1;
        end else if(in[i] == 1'b1 && !found_first_nonzero_bit) begin
            found_first_nonzero_bit = 1;
            significand = (in << leading_zeros) >> 8;
          //significand = in >> leading_zeros; 
          //significand = significand[7:4];
          //significand = (in << leading_zeros) >> 4;
        end
     end

     if (leading_zeros == 12) begin
        	significand = 0;
     end

    case (leading_zeros)
    4'd1: begin
        exponent = 4'd7; 
        fifthBit = in[6];
    end
    4'd2: begin
        exponent = 4'd6;
        fifthBit = in[5];
    end
    4'd3: begin
        exponent = 4'd5;
        fifthBit = in[4];
    end
    4'd4: begin
        exponent = 4'd4;
        fifthBit = in[3];
    end
    4'd5: begin
        exponent = 4'd3;
        fifthBit = in[2];
    end
    4'd6: begin
        exponent = 4'd2;
        fifthBit = in[1];
    end
    4'd7: begin
        exponent = 4'd1;
        fifthBit = in[0];
    end
    default: begin
        exponent = 4'd0;
        fifthBit = 1'b0;
    end
endcase
//Rounding
if(fifthBit == 1'b1) begin
	if(significand == 4'b1111) begin
		if(exponent != 3'b111) begin
			significand = 4'b1000;
			exponent = exponent + 1;
		end
	end else begin
		significand = significand + 1;
	end
end
//Assign outputs
	F = significand;
	E = exponent;
end 

endmodule
