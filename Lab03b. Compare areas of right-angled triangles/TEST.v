//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/1ps

`define CYCLE 100

//`include "lab03b.vp"
`include "lab03b.v"
`include "lab03b_beh.v"

module TEST;

reg         clk, rst;
reg   [8:0] a,b,c,d,e,f;
wire [16:0] out, correct_out;
wire [8:0] max, correct_max;
integer     simulation_cycle;
integer     err_num;
reg [8:0] input_data[0:3964];
reg [10:0] index;

lab03b_beh lab03b_beh(.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .out(correct_out), .max(correct_max));

lab03b     lab03b(.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .out(out), .max(max));

always #(`CYCLE/2.0) clk = ~clk;

always@(posedge clk or posedge rst)
begin
  if(rst) begin
  	{a,b,c,d,e,f} <= 9'b0;
  end else begin	
    a <= input_data[index]; 
    b <= input_data[index + 1];
	c <= input_data[index + 2];
	d <= input_data[index + 3]; 
    e <= input_data[index + 4];
	f <= input_data[index + 5];
  end
end

always@(posedge clk or posedge rst)
begin
  if(rst) begin
  	index = 11'b0;
  end else if (index < 1194)begin
	index = index + 6;
  end
end

initial begin

	$fsdbDumpfile("lab03b.fsdb");
	$fsdbDumpvars;

	err_num = 0;
	simulation_cycle = 0;
	clk=0;	rst=1;
	#6 rst=0; index=0;
	$readmemb ("input_data.dat",input_data); 	

	repeat (200) @(posedge clk);

	$display ();
	$display ("------------------------------------");
	$display ("TOTAL ERRORS  = %d", err_num);
	
	if(err_num !=0) begin
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
   
always@(negedge clk)
   if ((correct_out !== out) && rst==0)
   begin
      err_num = err_num + 1;
      $display ();
      $display ("ERROR at cycle = %d", simulation_cycle);
      $display ("  => CORRECT OUT_DATA = %d", correct_out);
	  $display ("  => YOUR a    = %d", a);
	  $display ("  => YOUR b    = %d", b);
	  $display ("  => YOUR d    = %d", d);
	  $display ("  => YOUR e    = %d", e);
      $display ("  => YOUR OUT_DATA    = %d", out); 
      $display ("  => CORRECT MAX C = %d", correct_max);
      $display ("  => YOUR MAX C    = %d", max);
      $display ();      
   end

endmodule
