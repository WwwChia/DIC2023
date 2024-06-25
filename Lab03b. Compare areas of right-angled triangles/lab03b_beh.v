//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

module lab03b_beh(a, b, c, d, e, f, out, max);
input   [8:0] a, b, c, d, e, f; 
output [16:0] out;
output [8:0] max;	

wire [16:0] out1, out2;
//assign #5 out = (a*b)/2;

assign out1 = (a * b)/2;
assign out2 = (d * e)/2;

assign out = (out1 > out2)?  out1 : out2;
assign max = (out1 > out2)?  c : f;


endmodule
