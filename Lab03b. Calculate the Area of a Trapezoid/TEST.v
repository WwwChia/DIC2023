//------------------------------------------------------//
//- Digital IC Design 2023                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

`define CYCLE 50

//`include "lab03b.vp"
`include "lab03b.v"
`include "lab03b_beh.v"

module TEST;

reg         clk, rst;
reg   [7:0] a,b,c;
wire [15:0] out, correct_out;
integer     simulation_cycle;
integer     err_num;

lab03b_beh lab03b_beh(.a(a), .b(b), .c(c), .out(correct_out));

lab03b     lab03b(.a(a), .b(b), .c(c), .out(out));

always #(`CYCLE/2.0) clk = ~clk;

//random generate a,b :1-255(8bit)
always@(posedge clk or posedge rst) begin
	if(rst)
  		{a,b,c} <= 8'b0;
  	
	else begin	
		a <= 1+ {$random} % 254; //0-255
    	b <= 1+ {$random} % 254;
		c <= 1+ {$random} % 254;	
  	end
end

initial begin

	$fsdbDumpfile("lab03b.fsdb");
	$fsdbDumpvars;

	err_num = 0;
	simulation_cycle = 0;
	clk=0;	rst=1;
	#6 rst=0;

	repeat (30) @(posedge clk);

	$display ();
	$display ("------------------------------------");
	$display ("TOTAL ERRORS  = %d", err_num);
	
	if(err_num != 0) begin
        $display ();
      	$display ("TOTAL ERRORS = %d", err_num);
     	$display ();
      	$display ("/////////////");
      	$display ("// Fail !! //");
      	$display ("/////////////");
      	$display ();
   	end
	
	else begin
      	$display ();
      	$display ("///////////////////");
      	$display ("// Successful !! //");
      	$display ("///////////////////");
      	$display ();
   	end
	
 	$finish;
end

always@(posedge clk)
	simulation_cycle <= simulation_cycle + 1;
   
always@(posedge clk) begin
	if((correct_out !== out) && rst == 0) begin
      err_num = err_num + 1;
      $display ();
      $display ("ERROR at cycle = %d", simulation_cycle);
      $display ("  => CORRECT OUT_DATA = %d", correct_out);
      $display ("  => YOUR OUT_DATA    = %d", out);
      $display ();      
   end
end

endmodule