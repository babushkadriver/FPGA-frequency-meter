module display(
	input wire [3:0]code,
	output reg [6:0]segments);

	initial segments <= 7'b0111111;
	
	always @*
	begin
		case(code)
		4'd0: segments = 7'b0111111;
		4'd1: segments = 7'b0000110;
		4'd2: segments = 7'b1011011;
		4'd3: segments = 7'b1001111;
		4'd4: segments = 7'b1100110;
		4'd5: segments = 7'b1101101;
		4'd6: segments = 7'b1111101;
		4'd7: segments = 7'b0000111;
		4'd8: segments = 7'b1111111;
		4'd9: segments = 7'b1101111;
		4'd10: segments = 7'b1110111;
		4'd11: segments = 7'b1111100;
		4'd12: segments = 7'b0111001;
		4'd13: segments = 7'b1011110;
		4'd14: segments = 7'b1111011;
		4'd15: segments = 7'b1110001;
		endcase
	end
endmodule