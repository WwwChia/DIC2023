//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Exam: CHIP                                    //
//------------------------------------------------------//
`timescale 1ns/1ps

//cadence translate_off
`include "/usr/chipware/CW_fp_i2flt.v"
`include "/usr/chipware/CW_fp_div_seq.v"
//cadence translate_on

module CHIP(clk, rst_n, enable, a, b, ready, out);
input clk, rst_n, enable;
input [15:0] a, b;
output reg ready;
output reg [7:0] out;

reg [15:0] a_mem, b_mem;
wire [31:0] fp_a, fp_b;
wire [31:0] fp_z;
reg start;
reg [1:0] counter;
reg out_finish;

CW_fp_i2flt #(.isize(16)) U0(.a(a_mem), .rnd(3'b000), .z(fp_a), .status());
CW_fp_i2flt #(.isize(16)) U1(.a(b_mem), .rnd(3'b000), .z(fp_b), .status());

CW_fp_div_seq #(.num_cyc(7)) U2(.a(fp_a), .b(fp_b), .rnd(3'b000), .clk(clk), .rst_n(rst_n), .start(start), .z(fp_z), .status(), .complete(valid));

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
    else if(valid && !out_finish) begin
        case(counter)
            0: out <= fp_z[7:0];
            1: out <= fp_z[15:8];
            2: out <= fp_z[23:16];
            3: out <= fp_z[31:24];
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ready <= 0;
        out_finish <= 0;
    end 
    else if(valid && !ready && !out_finish)
    	ready <= 1;
    else if(ready && (counter==0)) begin
        ready <= 0;
        out_finish <= 1;
    end 
    else if(out_finish && enable) begin
        ready <= 0;
        out_finish <= 0;    
    end    
end
endmodule
  
