//------------------------------------------------------//
//- Digital IC Design 2023                              //
//-                                                     //
//- Lab06: Logic Synthesis                              //
//------------------------------------------------------//
`timescale 1ns/10ps

`include "MBF.v"

module TEST ;


parameter CYCLE_TIME = 5.0;
parameter OUTPUT_NUMBER = 41; 
parameter INPUT_BITS = 13; 
parameter OUTPUT_BITS = 13; 
parameter LATENCY_CYCLE = 5; 
reg CLK, RESET ,IN_VALID;


reg [INPUT_BITS-1:0] IN_NUM [0:199],OUT_NUM[0:199],OUT_LOW[0:199];
reg [INPUT_BITS-1:0] IN_DATA;
reg [9:0] cnt,cnt_output,cnt_input;
reg [9:0] cnt_error_x,cnt_error_y,data_cnt;
reg [OUTPUT_BITS-1:0] high_ans_correct,low_ans_correct;
reg [OUTPUT_BITS-1:0] YOU_X_DATA,YOU_Y_DATA;
reg flag;
reg [2:0] data_number;
wire [OUTPUT_BITS-1:0] X_DATA,Y_DATA;
wire OUT_VALID;

MBF  MBF(.CLK(CLK), .RESET(RESET), .IN_VALID(IN_VALID), .IN_DATA(IN_DATA),
         .X_DATA(X_DATA), .Y_DATA(Y_DATA), .OUT_VALID(OUT_VALID));

always #(CYCLE_TIME/2.0) CLK = ~CLK;


initial 
begin
	$fsdbDumpfile("MBF.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;

	$readmemb("data.dat", IN_NUM);
	$readmemb("high_answer.dat", OUT_NUM);
	$readmemb("low_answer.dat", OUT_LOW);

	cnt_input = 0;
	cnt_output = 0;
	data_number = 0;
	data_cnt = 0;
	cnt = 0;
        IN_DATA = 13'd0;
	IN_VALID = 0;
	flag = 1'd0;
	cnt_error_x = 6'd0;
	cnt_error_y = 6'd0;
	CLK = 0;
	RESET = 1;
	high_ans_correct= 12'd0;
	low_ans_correct = 12'd0;


	$display ("  ###################################################################     ###################################################################");
	$display ("  ###                                                             ###     ###                                                             ###");
	$display ("  ###               High pass filter result !!!!                  ###     ###                 Low pass filter result !!!!                 ###");
	$display ("  ###                                                             ###     ###                                                             ###");
	$display ("  ###################################################################     ###################################################################");
	#(CYCLE_TIME *1 ) RESET = 0;
	IN_VALID = 1;
	//#(1000) 
	//$finish ;
end

always@(negedge CLK) 
begin
	if(flag && ((cnt_output == OUTPUT_NUMBER) || (cnt_output == OUTPUT_NUMBER*2) || (cnt_output == OUTPUT_NUMBER*3)))
		data_cnt <= 5'd0;
	else
		data_cnt <= data_cnt + 5'd1;
end

always@(negedge CLK) 
begin
	if(IN_VALID) 
		IN_DATA <= IN_NUM[cnt_input];

end


always@(negedge CLK) 
begin
	if(IN_VALID) 
		cnt_input <= cnt_input + 1;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		high_ans_correct<= OUT_NUM[cnt_output];
	
end


always@(negedge CLK) 
begin
	if(OUT_VALID) 
		low_ans_correct <= OUT_LOW[cnt_output];
	
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		cnt_output <= cnt_output + 1;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		YOU_X_DATA <= X_DATA;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		YOU_Y_DATA <= Y_DATA;
end



always@(negedge CLK) 
begin
	if (data_cnt < 30) IN_VALID <= 1;
	else IN_VALID <= 0; 
end

always@(negedge CLK) 
begin
	if (((cnt_output == OUTPUT_NUMBER) || (cnt_output == OUTPUT_NUMBER*2) || (cnt_output == OUTPUT_NUMBER*3)) && flag) RESET <= 1;
	else RESET <= 0; 
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		flag <= 1;
	else
		flag <=0;
end

always@(negedge CLK) 
begin
	if (((cnt_output == OUTPUT_NUMBER) || (cnt_output == OUTPUT_NUMBER*2) || (cnt_output == OUTPUT_NUMBER*2)) && flag) 
		data_number = data_number+1; 
end

always@(negedge CLK) 
begin
	if(cnt_output == 0 && data_cnt >=LATENCY_CYCLE) 
	begin
		$display ("\n //// Error: Your first output must smaller than 5 clock cycles. //// \n " );
		#(CYCLE_TIME) $finish;   
	end
end



always@(negedge CLK) 
begin
	if(flag)
	begin
		if((high_ans_correct!== YOU_X_DATA) && (low_ans_correct !== YOU_Y_DATA))
		begin
			cnt_error_x <= cnt_error_x + 1;
			cnt_error_y <= cnt_error_y + 1;
			$display ("  Error   : pattern ",cnt_output," correct answer : ", high_ans_correct,"  your answer : ", YOU_X_DATA ," # ",
					  "	 Error   : pattern ",cnt_output," correct answer : ", low_ans_correct ,"  your answer : ", YOU_Y_DATA );
		end

		else if((high_ans_correct== YOU_X_DATA) && (low_ans_correct !== YOU_Y_DATA))
		begin
			cnt_error_y <= cnt_error_y + 1;
			$display ("  Correct : pattern ",cnt_output," correct answer : ", high_ans_correct,"  your answer : ", YOU_X_DATA ," # ",
					  "	 Error   : pattern ",cnt_output," correct answer : ", low_ans_correct ,"  your answer : ", YOU_Y_DATA );
		end

		else if((high_ans_correct!== YOU_X_DATA) && (low_ans_correct == YOU_Y_DATA))
		begin
			cnt_error_x <= cnt_error_x + 1;
			$display ("  Error   : pattern ",cnt_output," correct answer : ", high_ans_correct,"  your answer : ", YOU_X_DATA ," # ",
					  "	 Correct : pattern ",cnt_output," correct answer : ", low_ans_correct ,"  your answer : ", YOU_Y_DATA );
		end

		else
		begin
			$display ("  Correct : pattern ",cnt_output," correct answer : ", high_ans_correct,"  your answer : ", YOU_X_DATA ," # ", 
					  "	 Correct : pattern ",cnt_output," correct answer : ", low_ans_correct ,"  your answer : ", YOU_Y_DATA );
		end
	end
end


always @(negedge CLK) 
begin
	if(cnt_output == OUTPUT_NUMBER*3 && cnt_error_x == 0 && cnt_error_y == 0)
	begin 
			$display ();
			$display ("  ################################################     /\\     /\\ ");
			$display ("  ####    Congratulations   Successful !!    #####    /  \\   /  \\");
			$display ("  ################################################               ");	
			$display ("                                                         \\___/   ");		
			$display ();
			#(CYCLE_TIME) $finish;      
	
	end
	else if(cnt_output == OUTPUT_NUMBER*3 && cnt_error_x > 0)
	begin 
		$display ();
		$display ("  ################################################   \\/   \\/");	
		$display ("  #####              Error !!!!              #####   /\\   /\\");
		$display ("  ################################################     ___ ");	
		$display (" your High pass filter has ",cnt_error_x, " errors ");	
		$display (" your Low  pass filter has ",cnt_error_y, " errors ");	
		$display ();
		#(CYCLE_TIME) $finish;      
	end    
end


always@(negedge CLK) 
begin
	cnt <= cnt + 1;
end

endmodule