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
	
	initial segments <= 8'b11111111;
	initial segments_bit <= 8'b11111111;
	initial led <= 1'b0;
	initial code <= 4'd0;
	initial code1 <= 4'd0;
	initial code2 <= 4'd0;
	initial code3 <= 4'd0;
	initial code4 <= 4'd0;
	initial code5 <= 4'd0;
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

	always @(posedge input_clk) //счетчик частоты через внешний порт
		begin
			counter_input_clk <= counter_input_clk + 1'b1;
		end
	
	always @(posedge clk)
	begin
	
		if(counter_tic == 17'd87381) begin //включение первой цифры с частотой 95 Гц(50 МГц / 87381 Гц / 6)
			segments_bit <= 8'b11111110;
			discharge_flag = 3'b000; //флаг обновления первой цифры
		end
		if(counter_tic == 18'd174762) begin
			segments_bit <= 8'b11111101;
			discharge_flag = 3'b001; //флаг обновления второй цифры
		end
		if(counter_tic == 18'd262143) begin
			segments_bit <= 8'b11111011;
			discharge_flag = 3'b010;
		end
		if(counter_tic == 19'd349524) begin
			segments_bit <= 8'b11110111;
			discharge_flag = 3'b011;
		end
		if(counter_tic == 19'd436905) begin
			segments_bit <= 8'b11101111;
			discharge_flag = 3'b100;
		end
		if(counter_tic == 19'd524286) begin
			segments_bit <= 8'b11011111;
			discharge_flag = 3'b101;
			counter_tic <= 19'd0; //обнуление счётчика динамической индикации
		end
		counter_tic <= counter_tic + 1'b1; //инкрементация счётчика динамической индикации
		
		if(counter == 26'd50000000) //счётчик временного промежутка в 1 секунду
		begin
			input_frequency <= counter_input_clk; //значение внешней частоты
			counter_input_clk <= 0; //обнуление счётчика внешней частоты
			counter <= 26'd0; //обнуление счётчика тактирующей частоты(при достижении 1 секунды)
			counter_seconds <= counter_seconds + 1'b1; //инкрементация счётчика секунд
			led <= ~led; //изменение состояния светодиодов с выкл на вкл, и наоборот
			if(code < 4'd9) //счёт секунд
				code <= code + 1'b1;
			else begin
				code <= 1'b0; //обнуление секунд, если значение достигает 9
				if(code1 < 4'd5) //счёт десятков секунд
					code1 <= code1 + 1'b1;
				else begin
					code1 <= 1'b0; //обнуление десятков секунд, если значение достигает 5
					if(code2 < 4'd9)
						code2 <= code2 + 1'b1;
					else begin
						code2 <= 1'b0;
						if(code3 < 4'd5)
							code3 <= code3 + 1'b1;
						else begin
							code3 <= 1'b0;
							if((code4 < 4'd9) && (code5 < 4'd3))
								code4 <= code4 + 1'b1;
							else begin
								code4 <= 1'b0;
								if(code5 < 4'd3)
									code5 <= code5 + 1'b1;
								else	
									code5 <= 1'b0;
								end
							end
						end
					end
				end
			end	
		else 
			counter <= counter + 1'b1; //инкрементация счётчика тактовой частоты
		if((code4 == 4'd4) && (code5 == 4'd2)) //если на часах 24:00:00 - обнулить часы
		begin	
			code <= 1'b0;
			code1 <= 1'b0;
			code2 <= 1'b0;
			code3 <= 1'b0;
			code4 <= 1'b0;
			code5 <= 1'b0;
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
		
		if(discharge_flag == 3'b011) begin
		case(code3)
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
		
		if(discharge_flag == 3'b100) begin
		case(code4)
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

	end
	
	
	endmodule

		
		
		
		
		
		
		
		