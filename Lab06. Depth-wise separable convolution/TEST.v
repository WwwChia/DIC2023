//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Lab06: Logic Synthesis                              //
//------------------------------------------------------//
`timescale 1ns/1ps

`include "Convolution.v"

module TEST ;

parameter CYCLE_TIME = 0.37;

reg [4:0] IN_NUM_1 [99:0];
reg [4:0] IN_NUM_2 [99:0];
reg [4:0] IN_NUM_3 [99:0];
reg [4:0]IN_DATA_1;     //use to put input data
reg [4:0]IN_DATA_2;     //use to put input data
reg [4:0]IN_DATA_3;     //use to put input data

reg signed [7:0]IN_KERNEL_NUM[23:0];
reg [31:0]OUT_NUM[87:0];      ///change 4:0 -> output num
reg CLK,RESET;

reg signed [7:0]KERNEL;
reg IN_VALID ,KERNEL_VALID;
reg [10:0]count_in_1, count_in_2, count_in_3;
reg [10:0]count_out,count_kernel ;
reg [10:0]out_valid_cnt;
wire [31:0] OUT_DATA ;
wire OUT_VALID ;
integer  error_cnt, cycle_cnt, mode;


always #(CYCLE_TIME / 2.0 ) CLK = ~CLK;

Convolution convolution(.CLK(CLK),.RESET(RESET),.IN_DATA_1(IN_DATA_1), .IN_DATA_2(IN_DATA_2), .IN_DATA_3(IN_DATA_3),.IN_VALID(IN_VALID), .KERNEL_VALID(KERNEL_VALID), .KERNEL(KERNEL),.OUT_DATA(OUT_DATA),.OUT_VALID(OUT_VALID));

initial begin
   
	$fsdbDumpfile("Convolution.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;

	$readmemh("./weight_1.dat", IN_NUM_1);
	$readmemh("./weight_2.dat", IN_NUM_2);
	$readmemh("./weight_3.dat", IN_NUM_3);  
	$readmemh("./answer.dat", OUT_NUM);
	$readmemh("./kernel.dat", IN_KERNEL_NUM);
   
	CLK = 0 ;
	count_in_1 = 0 ;
	count_in_2 = 0 ;
	count_in_3 = 0 ;
	count_out = 0 ;
	count_kernel = 0 ;
	IN_VALID = 0 ;
	error_cnt=0;
	KERNEL_VALID = 0;
	mode=1;
	RESET = 1 ;
	#(CYCLE_TIME *2 ) RESET = 0;
	$display( "\n\n================RESULT   1================\n" ) ;  


	#(100)  $readmemh("./weight_1_2.dat", IN_NUM_1);
	$readmemh("./weight_2_2.dat", IN_NUM_2);
	$readmemh("./weight_3_2.dat", IN_NUM_3); 
	$readmemh("./answer_2.dat", OUT_NUM); 
	$readmemh("./kernel_2.dat", IN_KERNEL_NUM);
	count_in_1 = 0 ;
	count_in_2 = 0 ;
	count_in_3 = 0 ; 
	count_out = 0 ;
	count_kernel = 0 ;
	KERNEL_VALID = 0;


	mode=2;RESET = 1 ;
	#(CYCLE_TIME *2.5 ) RESET = 0;
	$display( "\n\n================RESULT   2================\n" ) ;  
   
	#(100)
   
     
	if(mode==1)begin
		if(error_cnt == 0 && out_valid_cnt==89)$display("\n\n================Successful!!!================\n\n") ;  
		else if (out_valid_cnt<89)begin
			$display("\n\n================ERROR!!!================\n\n") ;
			$display("================NOT ENOUGH ANSWER!!!================\n\n") ;		
		end
	end
	else if(mode==2)begin
		if(error_cnt == 0 && out_valid_cnt==89)$display("\n\n================Successful!!!================\n\n") ; 
		else if (out_valid_cnt<89)begin
			$display("\n\n================ERROR!!!================\n\n") ;
			$display("================NOT ENOUGH ANSWER!!!================\n\n") ;		
		end
	/*else if(out_valid)*/
	
	end
   $finish ;
end

// cycle_cnt   //count to 5 clock for RESET 
always@( posedge CLK or posedge RESET)  begin
  if(RESET) cycle_cnt <= 0;
  else  cycle_cnt <= cycle_cnt + 1 ;
end

// count_in_1   //stop at 100
always@( negedge CLK ) begin
	if(RESET)count_in_1<=0;
	else if ( count_in_1 < 100 && cycle_cnt >= 6) count_in_1 <= count_in_1 + 1 ;
	else  count_in_1 <= count_in_1 ;
  
end

// count_in_2  //stop at 100
always@( negedge CLK ) begin
	if(RESET)count_in_2<=0;
	else if ( count_in_2 < 100 && cycle_cnt >= 6) count_in_2 <= count_in_2 + 1 ;
	else  count_in_2 <= count_in_2 ;
end

// count_in_3  //stop at 100
always@( negedge CLK ) begin
	if(RESET)count_in_3<=0;
	else if ( count_in_3 < 100 && cycle_cnt >= 6) count_in_3 <= count_in_3 + 1 ;
	else  count_in_3 <= count_in_3 ;
end

// count_out
always@( posedge CLK ) begin
	if (RESET)count_out<=0;
	else if ( OUT_VALID  ) count_out <= count_out + 1 ;  
    else  count_out <= count_out ;
end

// count_kernel  //count to 24 clock
always@( negedge CLK) begin
	if(RESET)count_kernel<=0;
	else if(count_kernel<24 && cycle_cnt>=6) count_kernel<=count_kernel +1;
	else count_kernel<=count_kernel;
end

// IN_VALID   //stop after 100 clock
always@(posedge CLK )  begin
	if(RESET)IN_VALID<=0;
	else if ( cycle_cnt >= 5 && count_in_1 < 100) IN_VALID <= 1 ;
	else  IN_VALID <= 0 ;
  
end


// KERNEL_VALID  //stop after 7*3 depth_kernel and 3 point_kernel output=>24 clock
always@(negedge CLK) begin
	if(RESET)KERNEL_VALID<=0;
	else if (cycle_cnt >= 6 && count_kernel <24)KERNEL_VALID<=1;
	else KERNEL_VALID<=0;

end

// IN_DATA_1   //give weight1 ,stop after 100 weight output
always@(negedge CLK ) begin
	if(RESET)IN_DATA_1<=0;
	else if ( cycle_cnt >= 6 && count_in_1 < 100 ) IN_DATA_1 <= IN_NUM_1[count_in_1] ;
	else  IN_DATA_1 <= 0 ;
end

// IN_DATA_2   //give weight2 ,stop after 100 weight output
always@(negedge CLK ) begin
	if(RESET)IN_DATA_2<=0;
	else if ( cycle_cnt >= 6 && count_in_2 < 100 ) IN_DATA_2 <= IN_NUM_2[count_in_2] ;
	else  IN_DATA_2 <= 0 ;
end

// IN_DATA_3   //give weight3 ,stop after 100 weight output
always@(negedge CLK ) begin
	if(RESET)IN_DATA_3<=0;
	else if ( cycle_cnt >= 6 && count_in_3 < 100 ) IN_DATA_3 <= IN_NUM_3[count_in_3] ;
	else  IN_DATA_3 <= 0 ;
  
end

// KERNEL    //give kernel
always@(negedge CLK ) begin
	if(RESET)KERNEL<=0;
	else if( cycle_cnt>=6 && count_kernel <24 ) KERNEL<=  IN_KERNEL_NUM[count_kernel];
	else KERNEL<=0;
end


//out_valid_cnt
always@(posedge CLK or RESET)begin
	if(RESET)out_valid_cnt<=1;
	else if(OUT_VALID)out_valid_cnt<=out_valid_cnt+1;

end

always@( posedge CLK )  begin
  if ( OUT_VALID )  begin
	if ( OUT_NUM[count_out] !== OUT_DATA ) begin
		$display("\n      ********ERROR OCCUR********     ");
        $display("#%d  correct_answer :%d, out:%d",out_valid_cnt , OUT_NUM[count_out], OUT_DATA ) ;
		$display("\n\n================FAIL!!!================\n\n") ;
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8Oo::::ooOOO8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o:   ..::..       .:o88@@@@@@@@@@@8OOoo:::..::oooOO8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.   :8@@@@@@@@@@@@Oo..                   ..:.:..      .:O8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.  .8@@@@@@@@@@@@@@@@@@@@@@88888888888@@@@@@@@@@@@@@@@@8.    :O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:. .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.   :8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O  O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.   :o@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o  8@@@@@@@@@@@@@8@@@@@@@@8o::o8@@@@@8ooO88@@@@@@@@@@@@@@@@@@@@@@@@8:.  .:ooO8@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o  :@@@@@@@@@@O      :@@@O   ..  :O@@@:       :@@@@OoO8@@@@@@@@@@@@@@@@Oo...     ..:o@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  :8@@@@@@@@@:  .@@88@@@8:  o@@o  :@@@. 0@@@.  O@@@      .O8@@@@@@@@@@@@@@@@@@8OOo.    O8@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  o@@@@@@@@@@O.      :8@8:  o@@O. .@@8  000o  .8@@O  O8O:  .@@o .O@@@@@@@@@@@@@@@@@@@o.  .o@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@. :8@@@@@@@@@@@@@@@:  .o8:  o@@o. .@@O  ::  .O@@@O.  o0o.  :@@O. :8@8::8@@@@@@@@@@@@@@@8O  .:8@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  o8@@@@@@@@@@@OO@@8.  o@8   ''  .O@@o  O@:  :O@@:  ::   .8@@@O. .:   .8@@@@@@@@@@@@@@@@@@O   8@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@. .O@@@@@@@@@@O      .8@@@@Oo::oO@@@@O  8@8:  :@8  :@O. :O@@@@8:   .o@@@@@@@@@@@@@@@@@@@@@@o  :8@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8:  8@@@@@@@@@@@@8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o:8@8:  :@@@@:  .O@@@@@@@@@@@@@@@@@@@@@@@@8:  o@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:  .8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@OoO@@@O  :8@@@@@@@@@@@@@@@@@@@@@@@@@@8o  8@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.   o8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@88@@@@@@@@@@@@@@@@@@@8::@@@@@88@@@@@@@@@@@@@@@@@@@@@@@  :8@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O.  .:8@@@@@@@@@@@@@@@@@@@88OOoo::....:O88@@@@@@@@@@@@@@@@@@@@8o .8@@@@@@@@@@@@@@@@@@@@@@:  o@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o.   ..:o8888888OO::.      ....:o:..     oO@@@@@@@@@@@@@@@@8O..@@ooO@@@@@@@@@@@@@@@@@@O. :@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Oo::.          ..:OO@@@@@@@@@@@@@@@@O:  .o@@@@@@@@@@@@@@@@@@@O   8@@@@@@@@@@@@@@@@@. .O@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8O   .8@@@@@@@@@@@@@@@@@@@@@O  O@@@@@@@@@@@@@. o8@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O    .O@@@@@@@@@@@@@@@@@@8..8@@@@@@@@@@@@@. .O@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O:           ..:O88@888@@@@@@@@@@@@@@@@@@@@@@@O  O@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o.                          ..:oO@@@@@@@@@@@@@@@o  @@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                      .o@@8O::.    o8@@@@@@@@@@@O  8@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o                         :O@@@@@@@o.  :O8@@@@@@@@8  o8@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@88OO888@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8888OOOOO8@@8888@@@@@O.                          .@@@@@@@@@:.  :@@@@@@@@@. .O@");
		$display("@@@@@@@@@@@@@@@@@@@@8o:           O8@@@@@@@@@@@@@@@@@@@8OO:.                     .::                            :8@@@@@@@@@.  .O@@@@@@@o. o@");
		$display("@@@@@@@@@@@@@@@@@@.                 o8@@@@@@@@@@@O:.         .::oOOO8Oo:..::::..                                 o@@@@@@@@@@8:  8@@@@@@o. o@");
		$display("@@@@@@@@@@@@@@@@:                    .@@@@@Oo.        .:OO@@@@@@@@@@@@@@@@@@@@@@@@@o.                            O@@@@@@@@@@@@  o8@@@@@O. o@");
		$display("@@@@@@@@@@@@@@:                       o88.     ..O88@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@888O.                     .8@@@@@@@@@@@@  o8@@@@@: .O@");
		$display("@@@@@@@@@@@@O:                             :o8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:                  .8@@@@@@@@@@@8o  8@@@@@O  O@@");
		$display("@@@@@@@@@@@O.                            :8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o.              :8@@@@@@@@@@8.  .O@@@@o.  :@@@");
		$display("@@@@@@@@@@@:                          :O8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O:          .o@@@@@@@@@8o   .o@@@8:.  .@@@@@");
		$display("@@@@@@@@@@@.                        O8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O.    .o8@@@@@@@@@@O  :O@@8o:   .O@@@@@@@");
		$display("@@@@@@@@@@@.                      :O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O:   o8@@@@@@@@8           oO@@@@@@@@@@");
		$display("@@@@@@@@@@@:                     o@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.   .@@@@@@@O.      .:o8@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@8o                   8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o   :@@@@O     o8@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@8.               .O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:   .@@@8..:8@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@8:            .o@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O.  :8@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@8O.        8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   :@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@8o   o@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o   O@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@O   O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O   :@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@8   :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:   8@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@8o  :8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:..   .:o@@@@@@@@@@@@@@@@@@8.  O@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@8o  :8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O.         .:@@@@@@@@@@@@@@@@@:  :O@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@O.  o@@@@@@@@@@@@@@@@@@@@@@8OOO8@@@@@@@@@@@@@@@@@@@@@@@@@@@8.             .@@@@@@@@@@@@@@@@.  .O@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@o.  .@@@@@@@@@@@@@@@@@@@8:.       :8@@@@@@@@@@@@@@@@@@@@@@@@8.               o8@@@@@@@@@@@@@o. .:@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@o.  :@@@@@@@@@@@@@@@@@O            .@@@@@@@@@@@@@@@@@@@@@@@@@:                .8@@@@@@@@@@@@O.  :@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@O.  .@@@@@@@@@@@@@@@@:             .8@@@@@@@@@@@@@@@@@@@@@@@@O:                o@@@@@@@@@@@@O:  .@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@O.  .@@@@@@@@@@@@@@8:               8@@@@@@@@@@@@@@@@@@@@@@@@@@.               o@@@@@@@@@@@@O:  .@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@O.  .@@@@@@@@@@@@@o.                8@@@@@@@@@@@@@@@@@@@@@@@@@@8o             .8@@@@@@@@@@@@O.  .@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@8:  .@@@@@@@@@@@@@                 :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8:.        O8@@@@@@@@@@@@@@o.  :@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@o   8@@@@@@@@@@@@.               :8@@@@@@@@@          :8@@@@@@@@@@@8OoooO@@@@@@@@@@@@@@@@@@.  .o@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@88O:   O@@@@@@@@@@@@O:             .@@@@@@@@O             .8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8   :8@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@O:.       :O8@@@@@@@@@@8o           :O@@@@@@@8:             :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8:       :o@@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@o              ..:8@@@@@@@@@8o:::.:O8@@@@@@@@@@@8.           :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O:.             o@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@8o                   :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:.     .o@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8                  o8@@@@@@@@@@@@@@@");
		$display("8OOOooooOOoo:.                    :OOOOOOOOOO8888OOOOOOOOOOOoo:ooOOOo: .OOOOOOOOOO888OOooOO888OOOOOooO8:                   .:OOOOOOOOOOO88@@");
		$display("            .                                                                                                                               ");
		$display("@@@@@@@@@@@@@@8o                 .8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8                    :8@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@8O.             o8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8o                 .@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@::.       :O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O..         .:8@@@@@@@@@@@@@@@@@@");
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@88O8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@88@@@@@@@@@@@@@@@@@@@@@@@@@@");
		error_cnt<=error_cnt+1;
        $finish ;   
      end
      else 
        $display("#%d  correct_answer :%d, out:%d",out_valid_cnt,  OUT_NUM[count_out], OUT_DATA ) ;
       
  end
end

always@(posedge CLK) 
begin
  if(cycle_cnt > 43 && count_out < 88)
  begin
    if(!OUT_VALID)
	begin
	  $display ("\n //// Error: Your first output must smaller than 15 clock cycles. //// \n " );
	  $finish; 
	end
  end
end

endmodule

