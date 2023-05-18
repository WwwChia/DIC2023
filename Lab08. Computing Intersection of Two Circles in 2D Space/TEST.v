//------------------------------------------------------//
//- Digital IC Design 2023                              //
//-                                                     //
//- Lab08: Low-Power Syntheis                           //
//------------------------------------------------------//
`timescale 1ns/10ps
`define SDFFILE    "SET.sdf"    // Modify your sdf file name here
`define cycle 10.0
`define terminate_cycle 200000 // Modify your terminate cycle here

`include "SET.v"

module TEST;

`define central_pattern "./dat/Central_pattern.dat"
`define radius_pattern "./dat/Radius_pattern.dat"
`define result "./dat/result.dat"

reg clk = 0;
reg rst;
reg en;
reg [15:0] central;
reg [7:0] radius;
reg [7:0]result;
wire busy;
wire valid;
wire [7:0] candidate;

integer err_cnt;

reg [15:0] central_pat_mem [0:63];
reg [7:0]  radius_pat_mem[0:63];
reg [7:0]  expected_mem [0:63];

always #(`cycle/2) clk = ~clk;

SET SET( .clk(clk), .rst(rst), .en(en), .central(central), .radius(radius), .busy(busy), .valid(valid), .candidate(candidate) );


`ifdef SDF
initial $sdf_annotate(`SDFFILE, TEST.SET);
`endif

initial begin
	$fsdbDumpfile("SET.fsdb");
	$fsdbDumpvars;
end

initial begin
	$timeformat(-9, 1, " ns", 1); //Display time in nanoseconds
	$readmemh(`central_pattern, central_pat_mem);
	$readmemh(`radius_pattern, radius_pat_mem);
        $toggle_count("TEST.SET");
        $toggle_count_mode(1);

	$display("--------------------------- [ Simulation START !! ] ---------------------------");
	$readmemh(`result, expected_mem);
/*
	clk=0;rst=0;
        #(`cycle) rst = 1'b1;
        #(`cycle) rst = 1'b0;
	#(1000*`cycle);
 	#(`cycle) $finish;
*/
//	#1 $finish; 

end

integer k;
//integer p;
initial begin
	en = 0;
    	rst = 0;
	err_cnt = 0;

	radius = 0;

# `cycle;     
	rst = 1;
#(`cycle*3);
	rst = 0;
for (k = 0; k<=63; k = k+1) begin
	@(posedge clk);
	//change inputs at strobe point
        #(`cycle/4)	wait(busy == 0);
			en = 1;
			central = central_pat_mem[k];                
      			radius = radius_pat_mem[k];
				result = expected_mem[k];
			#(`cycle) en = 0;
			wait (valid == 1);
          	//Wait for signal output
          	@(posedge clk);
				if (candidate === result)
					$display(" Pattern %d is PASS !", k);
				else begin
					$display(" Pattern %d is FAIL !. Expected candidate = %d, but the Response candidate = %d !! ", k, result, candidate);
					err_cnt = err_cnt + 1;
				end
end
#(`cycle*2); 
     $display("--------------------------- Simulation FINISH !!---------------------------");
     if (err_cnt) begin 
     	$display("============================================================================");
     	$display("\n (T_T) FAIL!! The simulation result is FAIL!!! there were %d errors at all.\n", err_cnt);
	$display("============================================================================");
	end
     else begin 
     	$display("============================================================================");
	$display("\n \\(^o^)/ CONGRATULATIONS!!  The simulation result is PASS!!!\n");
	$display("============================================================================");
	 $toggle_count_report_flat("SET_rtl.tcf", "TEST.SET");
end
$finish;
end


always@(err_cnt) begin
	if (err_cnt == 10) begin
	$display("============================================================================");
     	$display("\n (>_<) FAIL!! The simulation FAIL result is too many ! Please check your code @@ \n");
	$display("============================================================================");
	$finish;
	end
end

initial begin 
	#`terminate_cycle;
	$display("================================================================================================================");
	$display("--------------------------- (/`n`)/ ~#  There was something wrong with your code !! ---------------------------"); 
	$display("--------------------------- The simulation can't finished!!, Please check it !!! ---------------------------"); 
	$display("================================================================================================================");
	$finish;
end

endmodule