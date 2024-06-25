//------------------------------------------------------//
//- Digital IC Design 2023                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

module lab03b_beh(a, b, c, out);
input   [7:0] a, b, c; 
output [15:0] out;

assign #5 out = ((a+b)*c)/2;

endmodule
