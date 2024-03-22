//------------------------------------------------------//
//- Digital IC Design 2024                              //
//- Lab03b: Verilog Gate Level                          //
//- @author: Wei Chia Huang                             //
//- Last update: Mar 22 2024                            //
//------------------------------------------------------//
`timescale 1ns/1ps

module lab03b(a, b, c, d, e, f, out, max);
input  [8:0] a, b, c, d, e, f;
output [16:0] out;
output [8:0] max;	

//Examples to instantiate the cells from cell library
//AN2D12BWP16P90 u1( .A1(a), .A2(b), .Z(out));

//** Add your code below this line **//
wire [17:0] out1, out2;
wire [16:0] comp1, comp2;

Mul_unit M1(.a(a), .b(b), .out(out1));
Shift_right S1(.a(out1), .out(comp1));

Mul_unit M2(.a(d), .b(e), .out(out2));
Shift_right S2(.a(out2), .out(comp2));

Comparator Comp(.a1(comp1), .a2(comp2), .b1(c), .b2(f), .out(out), .max(max));
endmodule

module Mul_unit(a, b, out);
input [8:0] a, b;
output [17:0] out;

wire [8:0] c0, c1, c2, c3, c4, c5, c6, c7, c8;
wire [8:0] sum0, sum1, sum2, sum3, sum4, sum5, sum6;

Mul Mul0(.a(a[8:0]), .b(b[0]), .out(c0[8:0]));
Mul Mul1(.a(a[8:0]), .b(b[1]), .out(c1[8:0]));
Mul Mul2(.a(a[8:0]), .b(b[2]), .out(c2[8:0]));
Mul Mul3(.a(a[8:0]), .b(b[3]), .out(c3[8:0]));
Mul Mul4(.a(a[8:0]), .b(b[4]), .out(c4[8:0]));
Mul Mul5(.a(a[8:0]), .b(b[5]), .out(c5[8:0]));
Mul Mul6(.a(a[8:0]), .b(b[6]), .out(c6[8:0]));
Mul Mul7(.a(a[8:0]), .b(b[7]), .out(c7[8:0]));
Mul Mul8(.a(a[8:0]), .b(b[8]), .out(c8[8:0]));

BUFFD1BWP16P90 Buf0(.I(c0[0]), .Z(out[0]));
B9rca Rca0(.a({1'b0,c0[8:1]}), .b(c1[8:0]), .cin(1'b0), .sum(sum0[8:0]), .cout(a0));

BUFFD1BWP16P90 Buf1(.I(sum0[0]), .Z(out[1]));
B9rca Rca1(.a({a0,sum0[8:1]}), .b(c2[8:0]), .cin(1'b0), .sum(sum1[8:0]), .cout(a1));

BUFFD1BWP16P90 Buf2(.I(sum1[0]), .Z(out[2]));
B9rca Rca2(.a({a1,sum1[8:1]}), .b(c3[8:0]), .cin(1'b0), .sum(sum2[8:0]), .cout(a2));

BUFFD1BWP16P90 Buf3(.I(sum2[0]), .Z(out[3]));
B9rca Rca3(.a({a2,sum2[8:1]}), .b(c4[8:0]), .cin(1'b0), .sum(sum3[8:0]), .cout(a3));

BUFFD1BWP16P90 Buf4(.I(sum3[0]), .Z(out[4]));
B9rca Rca4(.a({a3,sum3[8:1]}), .b(c5[8:0]), .cin(1'b0), .sum(sum4[8:0]), .cout(a4));

BUFFD1BWP16P90 Buf5(.I(sum4[0]), .Z(out[5]));
B9rca Rca5(.a({a4,sum4[8:1]}), .b(c6[8:0]), .cin(1'b0), .sum(sum5[8:0]), .cout(a5));

BUFFD1BWP16P90 Buf6(.I(sum5[0]), .Z(out[6]));
B9rca Rca6(.a({a5,sum5[8:1]}), .b(c7[8:0]), .cin(1'b0), .sum(sum6[8:0]), .cout(a6));

BUFFD1BWP16P90 Buf7(.I(sum6[0]), .Z(out[7]));
B9rca Rca7(.a({a6,sum6[8:1]}), .b(c8[8:0]), .cin(1'b0),.sum(out[16:8]),.cout(out[17]));
endmodule

module Shift_right(a, out);
input [17:0] a;
output [16:0] out;

BUFFD1BWP16P90 Buf0(.I(a[1]), .Z(out[0]));
BUFFD1BWP16P90 Buf1(.I(a[2]), .Z(out[1]));
BUFFD1BWP16P90 Buf2(.I(a[3]), .Z(out[2]));
BUFFD1BWP16P90 Buf3(.I(a[4]), .Z(out[3]));
BUFFD1BWP16P90 Buf4(.I(a[5]), .Z(out[4]));
BUFFD1BWP16P90 Buf5(.I(a[6]), .Z(out[5]));
BUFFD1BWP16P90 Buf6(.I(a[7]), .Z(out[6]));
BUFFD1BWP16P90 Buf7(.I(a[8]), .Z(out[7]));
BUFFD1BWP16P90 Buf8(.I(a[9]), .Z(out[8]));
BUFFD1BWP16P90 Buf9(.I(a[10]), .Z(out[9]));
BUFFD1BWP16P90 Buf10(.I(a[11]), .Z(out[10]));
BUFFD1BWP16P90 Buf11(.I(a[12]), .Z(out[11]));
BUFFD1BWP16P90 Buf12(.I(a[13]), .Z(out[12]));
BUFFD1BWP16P90 Buf13(.I(a[14]), .Z(out[13]));
BUFFD1BWP16P90 Buf14(.I(a[15]), .Z(out[14]));
BUFFD1BWP16P90 Buf15(.I(a[16]), .Z(out[15]));
BUFFD1BWP16P90 Buf16(.I(a[17]), .Z(out[16]));
endmodule

module Comparator(a1, a2, b1, b2, out, max);
input [16:0] a1, a2;
input [8:0] b1,b2;
output [16:0] out;
output[8:0] max;

wire result;

com comp1(.comp1(a1), .comp2(a2), .out(result));

MUX2D1BWP16P90 Mux0(.I0(a1[0]), .I1(a2[0]), .S(result), .Z(out[0]));
MUX2D1BWP16P90 Mux1(.I0(a1[1]), .I1(a2[1]), .S(result), .Z(out[1]));
MUX2D1BWP16P90 Mux2(.I0(a1[2]), .I1(a2[2]), .S(result), .Z(out[2]));
MUX2D1BWP16P90 Mux3(.I0(a1[3]), .I1(a2[3]), .S(result), .Z(out[3]));
MUX2D1BWP16P90 Mux4(.I0(a1[4]), .I1(a2[4]), .S(result), .Z(out[4]));
MUX2D1BWP16P90 Mux5(.I0(a1[5]), .I1(a2[5]), .S(result), .Z(out[5]));
MUX2D1BWP16P90 Mux6(.I0(a1[6]), .I1(a2[6]), .S(result), .Z(out[6]));
MUX2D1BWP16P90 Mux7(.I0(a1[7]), .I1(a2[7]), .S(result), .Z(out[7]));
MUX2D1BWP16P90 Mux8(.I0(a1[8]), .I1(a2[8]), .S(result), .Z(out[8]));
MUX2D1BWP16P90 Mux9(.I0(a1[9]), .I1(a2[9]), .S(result), .Z(out[9]));
MUX2D1BWP16P90 Mux10(.I0(a1[10]), .I1(a2[10]), .S(result), .Z(out[10]));
MUX2D1BWP16P90 Mux11(.I0(a1[11]), .I1(a2[11]), .S(result), .Z(out[11]));
MUX2D1BWP16P90 Mux12(.I0(a1[12]), .I1(a2[12]), .S(result), .Z(out[12]));
MUX2D1BWP16P90 Mux13(.I0(a1[13]), .I1(a2[13]), .S(result), .Z(out[13]));
MUX2D1BWP16P90 Mux14(.I0(a1[14]), .I1(a2[14]), .S(result), .Z(out[14]));
MUX2D1BWP16P90 Mux15(.I0(a1[15]), .I1(a2[15]), .S(result), .Z(out[15]));
MUX2D1BWP16P90 Mux16(.I0(a1[16]), .I1(a2[16]), .S(result), .Z(out[16]));

MUX2D1BWP16P90 Mux17(.I0(b1[0]), .I1(b2[0]), .S(result), .Z(max[0]));
MUX2D1BWP16P90 Mux18(.I0(b1[1]), .I1(b2[1]), .S(result), .Z(max[1]));
MUX2D1BWP16P90 Mux19(.I0(b1[2]), .I1(b2[2]), .S(result), .Z(max[2]));
MUX2D1BWP16P90 Mux20(.I0(b1[3]), .I1(b2[3]), .S(result), .Z(max[3]));
MUX2D1BWP16P90 Mux21(.I0(b1[4]), .I1(b2[4]), .S(result), .Z(max[4]));
MUX2D1BWP16P90 Mux22(.I0(b1[5]), .I1(b2[5]), .S(result), .Z(max[5]));
MUX2D1BWP16P90 Mux23(.I0(b1[6]), .I1(b2[6]), .S(result), .Z(max[6]));
MUX2D1BWP16P90 Mux24(.I0(b1[7]), .I1(b2[7]), .S(result), .Z(max[7]));
MUX2D1BWP16P90 Mux25(.I0(b1[8]), .I1(b2[8]), .S(result), .Z(max[8]));
endmodule

module com(comp1, comp2, out);
input [16:0] comp1,comp2;
output out;

wire w0,w1;

wire [17:0] inv;
wire [17:0] inv1,inv2;

GINVMCOD1BWP16P90 Ginv0(.I(comp2[0]), .ZN(inv[0]));
GINVMCOD1BWP16P90 Ginv1(.I(comp2[1]), .ZN(inv[1]));
GINVMCOD1BWP16P90 Ginv2(.I(comp2[2]), .ZN(inv[2]));
GINVMCOD1BWP16P90 Ginv3(.I(comp2[3]), .ZN(inv[3]));
GINVMCOD1BWP16P90 Ginv4(.I(comp2[4]), .ZN(inv[4]));
GINVMCOD1BWP16P90 Ginv5(.I(comp2[5]), .ZN(inv[5]));
GINVMCOD1BWP16P90 Ginv6(.I(comp2[6]), .ZN(inv[6]));
GINVMCOD1BWP16P90 Ginv7(.I(comp2[7]), .ZN(inv[7]));
GINVMCOD1BWP16P90 Ginv8(.I(comp2[8]), .ZN(inv[8]));
GINVMCOD1BWP16P90 Ginv9(.I(comp2[9]), .ZN(inv[9]));
GINVMCOD1BWP16P90 Ginv10(.I(comp2[10]), .ZN(inv[10]));
GINVMCOD1BWP16P90 Ginv11(.I(comp2[11]), .ZN(inv[11]));
GINVMCOD1BWP16P90 Ginv12(.I(comp2[12]), .ZN(inv[12]));
GINVMCOD1BWP16P90 Ginv13(.I(comp2[13]), .ZN(inv[13]));
GINVMCOD1BWP16P90 Ginv14(.I(comp2[14]), .ZN(inv[14]));
GINVMCOD1BWP16P90 Ginv15(.I(comp2[15]), .ZN(inv[15]));
GINVMCOD1BWP16P90 Ginv16(.I(comp2[16]), .ZN(inv[16]));
BUFFD12BWP16P90 buff(.I(1'b1), .Z(inv[17]));

B9rca Rca1(.a(inv[8:0]), .b(9'b0), .cin(1'b1), .sum(inv1[8:0]), .cout(w0));
B9rca Rca2(.a(inv[17:9]), .b(9'b0), .cin(w0), .sum(inv1[17:9]), .cout());

B9rca Rca3(.a(inv1[8:0]), .b(comp1[8:0]), .cin(1'b0), .sum(inv2[8:0]), .cout(w1));
B9rca Rca4(.a(inv1[17:9]), .b({1'b0,comp1[16:9]}), .cin(w1), .sum(inv2[17:9]), .cout());

BUFFD12BWP16P90 Buf0( .I(inv2[17]), .Z(out));
endmodule

module Mul(a, b, out);
input [8:0] a;
input b;
output [8:0] out;

AN2D12BWP16P90 And0(.A1(a[0]), .A2(b), .Z(out[0]));
AN2D12BWP16P90 And1(.A1(a[1]), .A2(b), .Z(out[1]));
AN2D12BWP16P90 And2(.A1(a[2]), .A2(b), .Z(out[2]));
AN2D12BWP16P90 And3(.A1(a[3]), .A2(b), .Z(out[3]));
AN2D12BWP16P90 And4(.A1(a[4]), .A2(b), .Z(out[4]));
AN2D12BWP16P90 And5(.A1(a[5]), .A2(b), .Z(out[5]));
AN2D12BWP16P90 And6(.A1(a[6]), .A2(b), .Z(out[6]));
AN2D12BWP16P90 And7(.A1(a[7]), .A2(b), .Z(out[7]));
AN2D12BWP16P90 And8(.A1(a[8]), .A2(b), .Z(out[8]));
endmodule

module B9rca(a, b, cin, sum, cout);
input [8:0] a, b;
input cin;
output [8:0] sum;
output cout;

FA1D1BWP16P90 FA0(.A(a[0]), .B(b[0]), .CI(cin), .S(sum[0]), .CO(c0));
FA1D1BWP16P90 FA1(.A(a[1]), .B(b[1]), .CI(c0), .S(sum[1]), .CO(c1));
FA1D1BWP16P90 FA2(.A(a[2]), .B(b[2]), .CI(c1), .S(sum[2]), .CO(c2));
FA1D1BWP16P90 FA3(.A(a[3]), .B(b[3]), .CI(c2), .S(sum[3]), .CO(c3));
FA1D1BWP16P90 FA4(.A(a[4]), .B(b[4]), .CI(c3), .S(sum[4]), .CO(c4));
FA1D1BWP16P90 FA5(.A(a[5]), .B(b[5]), .CI(c4), .S(sum[5]), .CO(c5));
FA1D1BWP16P90 FA6(.A(a[6]), .B(b[6]), .CI(c5), .S(sum[6]), .CO(c6));
FA1D1BWP16P90 FA7(.A(a[7]), .B(b[7]), .CI(c6), .S(sum[7]), .CO(c7));
FA1D1BWP16P90 FA8(.A(a[8]), .B(b[8]), .CI(c7), .S(sum[8]), .CO(cout));
endmodule
