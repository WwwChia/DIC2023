//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Exam: CHIP                                    //
//------------------------------------------------------//
`timescale 1ns/1ps
`include "CHIP.v"

module TEST;

parameter CYCLE = 0.54;
parameter SIM_CYCLE = 1000;

reg         clk, rst_n;
reg  [15:0] a, b; 
reg         enable;
wire        ready;
wire  [7:0] your_out; 
wire [31:0] correct_out;

reg [31:0] Z1, Z2;
reg [31:0] err_count;

wire [31:0] A, B;
wire [63:0] answer_a, answer_b, answer_z;
real        real_a, real_b, real_z;

integer sim_time;

CW_fp_i2flt #(.isize(16)) U0(.a(a), .rnd(3'b000), .z(A), .status());
CW_fp_i2flt #(.isize(16)) U1(.a(b), .rnd(3'b000), .z(B), .status());

CHIP CHIP(.clk(clk), .rst_n(rst_n), .enable(enable), .a(a), .b(b), .ready(ready), .out(your_out));
REF_DESIGN REF_DESIGN(.clk(clk), .rst_n(rst_n), .enable(enable), .a(a), .b(b), .ready(), .out(correct_out));

fp32_to_fp64 U2(.fp32(A), .fp64(answer_a)); 
fp32_to_fp64 U3(.fp32(B), .fp64(answer_b)); 
fp32_to_fp64 U4(.fp32(Z2), .fp64(answer_z));              

always #(CYCLE/2.0) clk = ~clk;

initial begin
$fsdbDumpfile("CHIP.fsdb");
$fsdbDumpvars;

clk = 0; 
rst_n = 1; 
enable = 0;
a = 0; b = 0; Z1 = 0; Z2 = 0;
err_count = 0;

@(negedge clk) rst_n = 0;
@(negedge clk) rst_n = 1;

// Random test pattern generation
repeat (SIM_CYCLE) begin
    @(negedge clk);

	sim_time = $time;
	a = $random(sim_time) & 16'hFFFF;  // 16-bit mask
	b = $random(sim_time) & 16'hFFFF;  // 16-bit mask

	enable = 1;
    
	@(negedge clk);
	enable = 0;  // Enable only for one cycle
	fp_check;
end

if(err_count != 0) begin
 	$display("\n\n**********************");
  	$display("Simulation Fail       ");
  	$display("**********************\n\n"); 
end 

else begin
  	$display("\n\n**********************");
  	$display("Simulation OK         ");
  	$display("**********************\n\n"); 
end

#10 $finish;
end

always@(answer_a or answer_b or answer_z) begin
    real_a = $bitstoreal(answer_a);
    real_b = $bitstoreal(answer_b);
    real_z = $bitstoreal(answer_z);
end

//--TASK----------------------------------------------------------//
task fp_check;
real checkA, checkB, checkZ;  
reg [7:0] IN_Z1 [0:3];
reg [7:0] IN_Z2 [0:3];
integer i;

begin
    @(posedge ready) begin
        for(i=0; i<=3; i=i+1) begin
        	@(negedge clk) IN_Z1[i] = your_out;
        end
    end 
	
    Z1 = {IN_Z1[3], IN_Z1[2], IN_Z1[1], IN_Z1[0]};
    Z2 = correct_out;
	
    @(negedge clk);
    // Display Debug Information
    fp_show; 

    if(Z1 != Z2) begin  // If answer is wrong
    	err_count = err_count + 1;
        $display("Error at %t", $time);
    end
end
endtask
//----------------------------------------------------------------//

//--TASK----------------------------------------------------------//
task fp_show;
begin 
    $display("\n");
    $display("********************************************************************");
    $display("(%+f) / (%+f) = %+f", $bitstoreal(answer_a), $bitstoreal(answer_b), $bitstoreal(answer_z));
    $display("------------------- Your Result------------------------------------");
    $display("Your Result    = %b_%b_%b", Z1[31], Z1[30:23], Z1[22:0]);
    $display("------------------- Correct Result---------------------------------");
    $display("Correct Result = %b_%b_%b", Z2[31], Z2[30:23], Z2[22:0]);
    $display("********************************************************************");
end 
endtask 
//----------------------------------------------------------------//
endmodule

module fp32_to_fp64(
input wire [31:0] fp32,  
output wire [63:0] fp64  
);
wire sign = fp32[31];               
wire [7:0] exponent_fp32 = fp32[30:23];  
wire [22:0] mantissa_fp32 = fp32[22:0]; 

wire [10:0] exponent_fp64;
wire [51:0] mantissa_fp64;

assign exponent_fp64 = exponent_fp32 + (1023 - 127);
assign mantissa_fp64 = mantissa_fp32 << (52 - 23);
assign fp64 = {sign, exponent_fp64, mantissa_fp64};
endmodule

//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Exam: REF_DESIGN                              //
//------------------------------------------------------//
module REF_DESIGN(clk, rst_n, enable, a, b, ready, out);
input clk, rst_n, enable;
input [15:0] a, b;
output reg ready;
output reg [31:0] out;

//pragma protect
//pragma protect begin
reg [15:0] a_mem, b_mem;
wire [31:0] fp_a, fp_b;
wire [31:0] fp_z;
reg start;
reg [1:0] counter;

CW_fp_i2flt #(.isize(16)) U0(.a(a_mem), .rnd(3'b000), .z(fp_a), .status());
CW_fp_i2flt #(.isize(16)) U1(.a(b_mem), .rnd(3'b000), .z(fp_b), .status());

CW_fp_div_seq #(.num_cyc(5)) U2(.a(fp_a), .b(fp_b), .rnd(3'b000), .clk(clk), .rst_n(rst_n), .start(start), .z(fp_z), .status(), .complete(valid));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start <= 0;
    else if(enable)
        start <= 1;
	else
		start <= 0;    
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a_mem <= 0;
        b_mem <= 0;
    end
    else if(enable) begin
		a_mem <= a;
		b_mem <= b;
    end    
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        counter <= 0;
	else if(enable)
		counter <= 0;
    else if(valid)
        counter <= counter + 1;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out <= 0;
    else if(valid) begin
        out <= fp_z;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ready <= 0;
    else if(valid)
    	ready <= 1;
    else 
	    ready <= 0;    
end
//pragma protect end

endmodule
