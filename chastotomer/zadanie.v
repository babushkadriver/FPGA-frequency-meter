module zadanie(clk, led0, led1, input_clk, segments, segments_bit);

	input wire clk, input_clk; //clk - тактирующая частота, input_clk - входная частота на внешний порт
	output wire led0, led1; //2 светодиода
	output reg [7:0]segments; //включение сегментов семисегментного индикатора
	output reg [7:0]segments_bit; //выбор цифры 8-значного сегмисегментного индикатора(динамическая индикация)
	reg led; //регистр переключения светодиодов
	reg [2:0]discharge_flag; //флаг переключения цифры семисегментного индикатора(по заданой частоте counter_tic_max)
	reg [3:0]code; //цифра 0 (секунды(от 0 до 9))
	reg [3:0]code1; //цифра 1 (десятки секунд(от 0 до 5))
	reg [3:0]code2; //цифра 2 (минуты(от 0 до 9))
	reg [3:0]code3; //цифра 3 (десятки минут(от 0 до 5))
	reg [3:0]code4; //цифра 4 (часы(от 0 до 9(до 4 после 20 часов)))
	reg [3:0]code5; //цифра 5 (десятки часов(от 0 до 2))
	reg [3:0]code6; //цифра 5 (десятки часов(от 0 до 2))
	reg [3:0]code7; //цифра 5 (десятки часов(от 0 до 2))
	reg [3:0]ed_ext_clk; 
	reg [3:0]des_ext_clk; 
	reg [3:0]sot_ext_clk; 
	reg [3:0]tis_ext_clk; 
	reg [3:0]dtis_ext_clk;  
	reg [3:0]stis_ext_clk;
	reg [3:0]mill_ext_clk;  
	reg [3:0]dmill_ext_clk; 	
	reg reset;
	
	initial segments <= 8'b11111111;
	initial segments_bit <= 8'b11111111;
	initial led <= 1'b0;
	initial code <= 4'd0;
	initial code1 <= 4'd0;
	initial code2 <= 4'd0;
	initial code3 <= 4'd0;
	initial code4 <= 4'd0;
	initial code5 <= 4'd0;
	initial code6 <= 4'd0;
	initial code7 <= 4'd0;
	initial ed_ext_clk  <= 4'd0;
	initial des_ext_clk  <= 4'd0;
	initial sot_ext_clk  <= 4'd0;
	initial tis_ext_clk  <= 4'd0;
	initial dtis_ext_clk  <= 4'd0;
	initial stis_ext_clk  <= 4'd0;
	initial mill_ext_clk  <= 4'd0;
	initial dmill_ext_clk  <= 4'd0;
	initial discharge_flag <= 3'd0;
	
	reg [25:0] counter; //счетчик тактовой частоты
	reg [18:0] counter_tic; //счетчик для динамической индикации семисегментного индикатора
	reg [26:0] counter_input_clk; //счетчик входящей частоты через внешний порт
	reg [26:0] input_frequency; //значение входящей частоты
	reg [26:0] counter_seconds; //подсчёт секунд
	initial counter <= 26'd0;
	initial counter_seconds <= 26'd0;
	initial counter_input_clk <= 27'd0;
	initial input_frequency <= 27'd0;

	always @(posedge input_clk or posedge reset) //счетчик частоты через внешний порт
		begin
		if(reset)
		begin
			ed_ext_clk  <= 4'd0;
			des_ext_clk  <= 4'd0;
			sot_ext_clk  <= 4'd0;
			tis_ext_clk  <= 4'd0;
			dtis_ext_clk  <= 4'd0;
			stis_ext_clk  <= 4'd0;
			mill_ext_clk  <= 4'd0;
			dmill_ext_clk  <= 4'd0;
		end
		else begin
			counter_input_clk <= counter_input_clk + 1'b1;
			ed_ext_clk <= ed_ext_clk + 1'b1;
			if(ed_ext_clk == 4'd9)
			begin
				ed_ext_clk <= 1'b0;
				des_ext_clk <= des_ext_clk + 1'b1;
				if(des_ext_clk == 4'd9)
				begin
					des_ext_clk <= 1'b0;
					sot_ext_clk  <= sot_ext_clk  + 1'b1;
					if(sot_ext_clk  == 4'd9)
					begin
						sot_ext_clk  <= 1'b0;
						tis_ext_clk <= tis_ext_clk + 1'b1;
						if(tis_ext_clk == 4'd9)
						begin
							tis_ext_clk <= 1'b0;
							dtis_ext_clk <= dtis_ext_clk + 1'b1;
							if(dtis_ext_clk == 4'd9)
							begin
								dtis_ext_clk <= 1'b0;
								stis_ext_clk <= stis_ext_clk + 1'b1;
								if(stis_ext_clk == 4'd9)
								begin
									stis_ext_clk <= 1'b0;
									mill_ext_clk <= mill_ext_clk + 1'b1;
									if(mill_ext_clk == 4'd9)
									begin
										mill_ext_clk <= 1'b0;
										if(dmill_ext_clk < 4'd9)
											dmill_ext_clk <= dmill_ext_clk + 1'b1;
										else 
										begin
											ed_ext_clk  <= 4'd9;
											des_ext_clk  <= 4'd9;
											sot_ext_clk  <= 4'd9;
											tis_ext_clk  <= 4'd9;
											dtis_ext_clk  <= 4'd9;
											stis_ext_clk  <= 4'd9;
											mill_ext_clk  <= 4'd9;
											dmill_ext_clk  <= 4'd9;
										end
									end
								end
							end
						end
					end
				end
			end	
		end
	end
	
	always @(posedge clk)
	begin
	
		if(counter_tic == 17'd65536) begin //включение первой цифры с частотой 95 Гц(50 МГц / 87381 Гц / 6)
			segments_bit <= 8'b11111110;
			discharge_flag = 3'b000; //флаг обновления первой цифры
		end
		if(counter_tic == 18'd131072) begin
			segments_bit <= 8'b11111101;
			discharge_flag = 3'b001; //флаг обновления второй цифры
		end
		if(counter_tic == 18'd196608) begin
			segments_bit <= 8'b11111011;
			discharge_flag = 3'b010;
		end
		if(counter_tic == 19'd262144) begin
			segments_bit <= 8'b11110111;
			discharge_flag = 3'b011;
		end
		if(counter_tic == 19'd327680) begin
			segments_bit <= 8'b11101111;
			discharge_flag = 3'b100;
		end
		if(counter_tic == 19'd393216) begin
			segments_bit <= 8'b11011111;
			discharge_flag = 3'b101;
		end
		if(counter_tic == 19'd458752) begin
			segments_bit <= 8'b10111111;
			discharge_flag = 3'b110;
		end
		if(counter_tic == 19'd524287) begin
			segments_bit <= 8'b01111111;
			discharge_flag = 3'b111;
			counter_tic <= 19'd0; //обнуление счётчика динамической индикации
		end
		counter_tic <= counter_tic + 1'b1; //инкрементация счётчика динамической индикации
		
		reset <= 1'b0;
		if(counter == 26'd50000000) //счётчик временного промежутка в 1 секунду
		begin
			input_frequency <= counter_input_clk; //значение внешней частоты
			counter_input_clk <= 0; //обнуление счётчика внешней частоты
			counter <= 26'd0; //обнуление счётчика тактирующей частоты(при достижении 1 секунды)
			counter_seconds <= counter_seconds + 1'b1; //инкрементация счётчика секунд
			led <= ~led; //изменение состояния светодиодов с выкл на вкл, и наоборот
			code <= ed_ext_clk;
			code1 <= des_ext_clk;
			code2 <= sot_ext_clk;
			code3 <= tis_ext_clk;
			code4 <= dtis_ext_clk;
			code5 <= stis_ext_clk;
			code6 <= mill_ext_clk;
			code7 <= dmill_ext_clk;
			reset <= 1'b1;
			end	
		else begin
			counter <= counter + 1'b1; //инкрементация счётчика тактовой частоты
		end
	end

	assign led0 = led;
	assign led1 = ~led;
	

	
	/*always @* //анимация
	begin
		case(code)
		4'd0: begin segments = 8'b00000011; segments_bit = 8'b01111111; end
		4'd1: begin segments = 8'b10011111; segments_bit = 8'b10111111; end
		4'd2: begin segments = 8'b00100101; segments_bit = 8'b11011111; end
		4'd3: begin segments = 8'b00001101; segments_bit = 8'b11101111; end
		4'd4: begin segments = 8'b10011001; segments_bit = 8'b11110111; end
		4'd5: begin segments = 8'b01001001; segments_bit = 8'b11111011; end
		4'd6: begin segments = 8'b01000001; segments_bit = 8'b11111101; end
		4'd7: begin segments = 8'b00011111; segments_bit = 8'b11111110; end
		4'd8: begin segments = 8'b00000001; segments_bit = 8'b01111111; end
		4'd9: begin segments = 8'b00001001; segments_bit = 8'b10111111; end
		4'd10: begin segments = 8'b00010001; segments_bit = 8'b11011111; end
		4'd11: begin segments = 8'b11000001; segments_bit = 8'b11101111; end
		4'd12: begin segments = 8'b01100011; segments_bit = 8'b11110111; end
		4'd13: begin segments = 8'b10000101; segments_bit = 8'b11111011; end
		4'd14: begin segments = 8'b00100001; segments_bit = 8'b11111101; end
		4'd15: begin segments = 8'b01110001; segments_bit = 8'b11111110; end
		endcase
	end*/
	
always @*
	begin
		if(discharge_flag == 3'b000) begin //обновление первой цифры часов по флагу discharge_flag
		case(code) //в зависимости от значения code выводится символ цифры по таблице сегментов
		4'd0: begin segments = 8'b00000011; end //цифра 0
		4'd1: begin segments = 8'b10011111; end //цифра 1
		4'd2: begin segments = 8'b00100101; end //цифра 2
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end //цифра A(не используется в часах)
		4'd11: begin segments = 8'b11000001; end //цифра b
		4'd12: begin segments = 8'b01100011; end //цифра C
		4'd13: begin segments = 8'b10000101; end //цифра d
		4'd14: begin segments = 8'b00100001; end //цифра e
		4'd15: begin segments = 8'b01110001; end //цифра F
		endcase
		end
		
		if(discharge_flag == 3'b001) begin
		case(code1)
		4'd0: begin segments = 8'b00000011; end
		4'd1: begin segments = 8'b10011111; end
		4'd2: begin segments = 8'b00100101; end
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end
		4'd11: begin segments = 8'b11000001; end
		4'd12: begin segments = 8'b01100011; end
		4'd13: begin segments = 8'b10000101; end
		4'd14: begin segments = 8'b00100001; end
		4'd15: begin segments = 8'b01110001; end
		endcase
		end

		if(discharge_flag == 3'b010) begin
		case(code2)
		4'd0: begin segments = 8'b00000011; end
		4'd1: begin segments = 8'b10011111; end
		4'd2: begin segments = 8'b00100101; end
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end
		4'd11: begin segments = 8'b11000001; end
		4'd12: begin segments = 8'b01100011; end
		4'd13: begin segments = 8'b10000101; end
		4'd14: begin segments = 8'b00100001; end
		4'd15: begin segments = 8'b01110001; end
		endcase
		end
		
		if(discharge_flag == 3'b011) begin
		case(code3)
		4'd0: begin segments = 8'b00000010; end
		4'd1: begin segments = 8'b10011110; end
		4'd2: begin segments = 8'b00100100; end
		4'd3: begin segments = 8'b00001100; end
		4'd4: begin segments = 8'b10011000; end
		4'd5: begin segments = 8'b01001000; end
		4'd6: begin segments = 8'b01000000; end
		4'd7: begin segments = 8'b00011110; end
		4'd8: begin segments = 8'b00000000; end
		4'd9: begin segments = 8'b00001000; end
		4'd10: begin segments = 8'b00010000; end
		4'd11: begin segments = 8'b11000000; end
		4'd12: begin segments = 8'b01100010; end
		4'd13: begin segments = 8'b10000100; end
		4'd14: begin segments = 8'b00100000; end
		4'd15: begin segments = 8'b01110000; end
		endcase
		end
		
		if(discharge_flag == 3'b100) begin
		case(code4)
		4'd0: begin segments = 8'b00000011; end
		4'd1: begin segments = 8'b10011111; end
		4'd2: begin segments = 8'b00100101; end
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end
		4'd11: begin segments = 8'b11000001; end
		4'd12: begin segments = 8'b01100011; end
		4'd13: begin segments = 8'b10000101; end
		4'd14: begin segments = 8'b00100001; end
		4'd15: begin segments = 8'b01110001; end
		endcase
		end
		
		if(discharge_flag == 3'b101) begin
		case(code5)
		4'd0: begin segments = 8'b00000011; end
		4'd1: begin segments = 8'b10011111; end
		4'd2: begin segments = 8'b00100101; end
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end
		4'd11: begin segments = 8'b11000001; end
		4'd12: begin segments = 8'b01100011; end
		4'd13: begin segments = 8'b10000101; end
		4'd14: begin segments = 8'b00100001; end
		4'd15: begin segments = 8'b01110001; end
		endcase
		end
		
		if(discharge_flag == 3'b110) begin
		case(code6)
		4'd0: begin segments = 8'b00000010; end
		4'd1: begin segments = 8'b10011110; end
		4'd2: begin segments = 8'b00100100; end
		4'd3: begin segments = 8'b00001100; end
		4'd4: begin segments = 8'b10011000; end
		4'd5: begin segments = 8'b01001000; end
		4'd6: begin segments = 8'b01000000; end
		4'd7: begin segments = 8'b00011110; end
		4'd8: begin segments = 8'b00000000; end
		4'd9: begin segments = 8'b00001000; end
		4'd10: begin segments = 8'b00010000; end
		4'd11: begin segments = 8'b11000000; end
		4'd12: begin segments = 8'b01100010; end
		4'd13: begin segments = 8'b10000100; end
		4'd14: begin segments = 8'b00100000; end
		4'd15: begin segments = 8'b01110000; end
		endcase
		end
		
		if(discharge_flag == 3'b111) begin
		case(code7)
		4'd0: begin segments = 8'b00000011; end
		4'd1: begin segments = 8'b10011111; end
		4'd2: begin segments = 8'b00100101; end
		4'd3: begin segments = 8'b00001101; end
		4'd4: begin segments = 8'b10011001; end
		4'd5: begin segments = 8'b01001001; end
		4'd6: begin segments = 8'b01000001; end
		4'd7: begin segments = 8'b00011111; end
		4'd8: begin segments = 8'b00000001; end
		4'd9: begin segments = 8'b00001001; end
		4'd10: begin segments = 8'b00010001; end
		4'd11: begin segments = 8'b11000001; end
		4'd12: begin segments = 8'b01100011; end
		4'd13: begin segments = 8'b10000101; end
		4'd14: begin segments = 8'b00100001; end
		4'd15: begin segments = 8'b01110001; end
		endcase
		end

	end
	
	
	endmodule

		
		
		
		
		
		
		
		