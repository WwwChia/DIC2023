//------------------------------------------------------//
//- Digital IC Design 2023                              //
//- Lab03b: Verilog Gate Level                          //
//- @author: Wei Chia Huang                             //        
//- Last update: Apr 17 2023                            //
//------------------------------------------------------//
`timescale 1ns/10ps

module add8(a, b, cin, sum, cout);  //8-bit ripple carry adder
    input [7:0] a, b;
    input cin;
    output [7:0] sum;
    output cout;

    wire c0, c1, c2, c3, c4, c5, c6;

    ADDFX1 U0(.S(sum[0]), .CO(c0), .A(a[0]), .B(b[0]), .CI(cin)); 
    ADDFX1 U1(.S(sum[1]), .CO(c1), .A(a[1]), .B(b[1]), .CI(c0));
    ADDFX1 U2(.S(sum[2]), .CO(c2), .A(a[2]), .B(b[2]), .CI(c1));
    ADDFX1 U3(.S(sum[3]), .CO(c3), .A(a[3]), .B(b[3]), .CI(c2));
    ADDFX1 U4(.S(sum[4]), .CO(c4), .A(a[4]), .B(b[4]), .CI(c3));
    ADDFX1 U5(.S(sum[5]), .CO(c5), .A(a[5]), .B(b[5]), .CI(c4));
    ADDFX1 U6(.S(sum[6]), .CO(c6), .A(a[6]), .B(b[6]), .CI(c5));
    ADDFX1 U7(.S(sum[7]), .CO(cout), .A(a[7]), .B(b[7]), .CI(c6));
endmodule

module multiplier(a, b, mulout);  //9x8 array multiplier
    input [8:0] a;
    input [7:0] b;
    output [16:0] mulout;
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    AND2X1 u0(.Y(mulout[0]), .A(a[0]), .B(b[0]));
    AND2X1 u1(.Y(w10), .A(a[1]), .B(b[0]));
    AND2X1 u2(.Y(w20), .A(a[2]), .B(b[0]));
    AND2X1 u3(.Y(w30), .A(a[3]), .B(b[0]));
    AND2X1 u4(.Y(w40), .A(a[4]), .B(b[0]));
    AND2X1 u5(.Y(w50), .A(a[5]), .B(b[0]));
    AND2X1 u6(.Y(w60), .A(a[6]), .B(b[0]));
    AND2X1 u7(.Y(w70), .A(a[7]), .B(b[0]));
    AND2X1 u8(.Y(w80), .A(a[8]), .B(b[0]));
    AND2X1 u9(.Y(w01), .A(a[0]), .B(b[1]));
    AND2X1 u10(.Y(w11), .A(a[1]), .B(b[1]));
    AND2X1 u11(.Y(w21), .A(a[2]), .B(b[1]));
    AND2X1 u12(.Y(w31), .A(a[3]), .B(b[1]));
    AND2X1 u13(.Y(w41), .A(a[4]), .B(b[1]));
    AND2X1 u14(.Y(w51), .A(a[5]), .B(b[1]));
    AND2X1 u15(.Y(w61), .A(a[6]), .B(b[1]));
    AND2X1 u16(.Y(w71), .A(a[7]), .B(b[1]));
    AND2X1 u17(.Y(w81), .A(a[8]), .B(b[1]));
    AND2X1 u18(.Y(w02), .A(a[0]), .B(b[2]));
    AND2X1 u19(.Y(w12), .A(a[1]), .B(b[2]));
    AND2X1 u20(.Y(w22), .A(a[2]), .B(b[2]));
    AND2X1 u21(.Y(w32), .A(a[3]), .B(b[2]));
    AND2X1 u22(.Y(w42), .A(a[4]), .B(b[2]));
    AND2X1 u23(.Y(w52), .A(a[5]), .B(b[2]));
    AND2X1 u24(.Y(w62), .A(a[6]), .B(b[2]));
    AND2X1 u25(.Y(w72), .A(a[7]), .B(b[2]));
    AND2X1 u26(.Y(w82), .A(a[8]), .B(b[2]));
    AND2X1 u27(.Y(w03), .A(a[0]), .B(b[3]));
    AND2X1 u28(.Y(w13), .A(a[1]), .B(b[3]));
    AND2X1 u29(.Y(w23), .A(a[2]), .B(b[3]));
    AND2X1 u30(.Y(w33), .A(a[3]), .B(b[3]));
    AND2X1 u31(.Y(w43), .A(a[4]), .B(b[3]));
    AND2X1 u32(.Y(w53), .A(a[5]), .B(b[3]));
    AND2X1 u33(.Y(w63), .A(a[6]), .B(b[3]));
    AND2X1 u34(.Y(w73), .A(a[7]), .B(b[3]));
    AND2X1 u35(.Y(w83), .A(a[8]), .B(b[3]));
    AND2X1 u36(.Y(w04), .A(a[0]), .B(b[4]));
    AND2X1 u37(.Y(w14), .A(a[1]), .B(b[4]));
    AND2X1 u38(.Y(w24), .A(a[2]), .B(b[4]));
    AND2X1 u39(.Y(w34), .A(a[3]), .B(b[4]));
    AND2X1 u40(.Y(w44), .A(a[4]), .B(b[4]));
    AND2X1 u41(.Y(w54), .A(a[5]), .B(b[4]));
    AND2X1 u42(.Y(w64), .A(a[6]), .B(b[4]));
    AND2X1 u43(.Y(w74), .A(a[7]), .B(b[4]));
    AND2X1 u44(.Y(w84), .A(a[8]), .B(b[4]));
    AND2X1 u45(.Y(w05), .A(a[0]), .B(b[5]));
    AND2X1 u46(.Y(w15), .A(a[1]), .B(b[5]));
    AND2X1 u47(.Y(w25), .A(a[2]), .B(b[5]));
    AND2X1 u48(.Y(w35), .A(a[3]), .B(b[5]));
    AND2X1 u49(.Y(w45), .A(a[4]), .B(b[5]));
    AND2X1 u50(.Y(w55), .A(a[5]), .B(b[5]));
    AND2X1 u51(.Y(w65), .A(a[6]), .B(b[5]));
    AND2X1 u52(.Y(w75), .A(a[7]), .B(b[5]));
    AND2X1 u53(.Y(w85), .A(a[8]), .B(b[5]));
    AND2X1 u54(.Y(w06), .A(a[0]), .B(b[6]));
    AND2X1 u55(.Y(w16), .A(a[1]), .B(b[6]));
    AND2X1 u56(.Y(w26), .A(a[2]), .B(b[6]));
    AND2X1 u57(.Y(w36), .A(a[3]), .B(b[6]));
    AND2X1 u58(.Y(w46), .A(a[4]), .B(b[6]));
    AND2X1 u59(.Y(w56), .A(a[5]), .B(b[6]));
    AND2X1 u60(.Y(w66), .A(a[6]), .B(b[6]));
    AND2X1 u61(.Y(w76), .A(a[7]), .B(b[6]));
    AND2X1 u62(.Y(w86), .A(a[8]), .B(b[6]));
    AND2X1 u63(.Y(w07), .A(a[0]), .B(b[7]));
    AND2X1 u64(.Y(w17), .A(a[1]), .B(b[7]));
    AND2X1 u65(.Y(w27), .A(a[2]), .B(b[7]));
    AND2X1 u66(.Y(w37), .A(a[3]), .B(b[7]));
    AND2X1 u67(.Y(w47), .A(a[4]), .B(b[7]));
    AND2X1 u68(.Y(w57), .A(a[5]), .B(b[7]));
    AND2X1 u69(.Y(w67), .A(a[6]), .B(b[7]));
    AND2X1 u70(.Y(w77), .A(a[7]), .B(b[7]));
    AND2X1 u71(.Y(w87), .A(a[8]), .B(b[7]));
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a0(.S(mulout[1]), .CO(c10), .A(w10), .B(w01), .CI(0));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a1(.S(s20), .CO(c20), .A(w20), .B(w11), .CI(0));
    ADDFX1 a2(.S(mulout[2]), .CO(c02), .A(w02), .B(s20), .CI(c10));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a3(.S(s30), .CO(c30), .A(w30), .B(w21), .CI(0));
    ADDFX1 a4(.S(s12), .CO(c12), .A(w12), .B(s30), .CI(c20));
    ADDFX1 a5(.S(mulout[3]), .CO(c03), .A(w03), .B(s12), .CI(c02));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a6(.S(s40), .CO(c40), .A(w40), .B(w31), .CI(0));
    ADDFX1 a7(.S(s22), .CO(c22), .A(w22), .B(s40), .CI(c30));
    ADDFX1 a8(.S(s13), .CO(c13), .A(w13), .B(s22), .CI(c12));
    ADDFX1 a9(.S(mulout[4]), .CO(c04), .A(w04), .B(s13), .CI(c03));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a10(.S(s50), .CO(c50), .A(w50), .B(w41), .CI(0));
    ADDFX1 a11(.S(s32), .CO(c32), .A(w32), .B(s50), .CI(c40));
    ADDFX1 a12(.S(s23), .CO(c23), .A(w23), .B(s32), .CI(c22));
    ADDFX1 a13(.S(s14), .CO(c14), .A(w14), .B(s23), .CI(c13));
    ADDFX1 a14(.S(mulout[5]), .CO(c05), .A(w05), .B(s14), .CI(c04));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     
    ADDFX1 a15(.S(s60), .CO(c60), .A(w60), .B(w51), .CI(0));
    ADDFX1 a16(.S(s42), .CO(c42), .A(w42), .B(s60), .CI(c50));
    ADDFX1 a17(.S(s33), .CO(c33), .A(w33), .B(s42), .CI(c32));
    ADDFX1 a18(.S(s24), .CO(c24), .A(w24), .B(s33), .CI(c23));
    ADDFX1 a19(.S(s15), .CO(c15), .A(w15), .B(s24), .CI(c14));
    ADDFX1 a20(.S(mulout[6]), .CO(c06), .A(w06), .B(s15), .CI(c05));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a21(.S(s70), .CO(c70), .A(w70), .B(w61), .CI(0));
    ADDFX1 a22(.S(s52), .CO(c52), .A(w52), .B(s70), .CI(c60));
    ADDFX1 a23(.S(s43), .CO(c43), .A(w43), .B(s52), .CI(c42));
    ADDFX1 a24(.S(s34), .CO(c34), .A(w34), .B(s43), .CI(c33));
    ADDFX1 a25(.S(s25), .CO(c25), .A(w25), .B(s34), .CI(c24));
    ADDFX1 a26(.S(s16), .CO(c16), .A(w16), .B(s25), .CI(c15));
    ADDFX1 a27(.S(mulout[7]), .CO(c07), .A(w07), .B(s16), .CI(c06));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a28(.S(s80), .CO(c80), .A(w80), .B(w71), .CI(0));
    ADDFX1 a29(.S(s62), .CO(c62), .A(w62), .B(s80), .CI(c70));
    ADDFX1 a30(.S(s53), .CO(c53), .A(w53), .B(s62), .CI(c52));
    ADDFX1 a31(.S(s44), .CO(c44), .A(w44), .B(s53), .CI(c43));
    ADDFX1 a32(.S(s35), .CO(c35), .A(w35), .B(s44), .CI(c34));
    ADDFX1 a33(.S(s26), .CO(c26), .A(w26), .B(s35), .CI(c25));
    ADDFX1 a34(.S(s17), .CO(c17), .A(w17), .B(s26), .CI(c16));
    ADDFX1 a35(.S(mulout[8]), .CO(c08), .A(0), .B(s17), .CI(c07));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a36(.S(s81), .CO(c81), .A(w81), .B(w72), .CI(c80));
    ADDFX1 a37(.S(s63), .CO(c63), .A(w63), .B(s81), .CI(c62));
    ADDFX1 a38(.S(s54), .CO(c54), .A(w54), .B(s63), .CI(c53));
    ADDFX1 a39(.S(s45), .CO(c45), .A(w45), .B(s54), .CI(c44));
    ADDFX1 a40(.S(s36), .CO(c36), .A(w36), .B(s45), .CI(c35));
    ADDFX1 a41(.S(s27), .CO(c27), .A(w27), .B(s36), .CI(c26));
    ADDFX1 a42(.S(mulout[9]), .CO(c09), .A(s27), .B(c17), .CI(c08));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a43(.S(s82), .CO(c82), .A(w82), .B(w73), .CI(c81));
    ADDFX1 a44(.S(s64), .CO(c64), .A(w64), .B(s82), .CI(c63));
    ADDFX1 a45(.S(s55), .CO(c55), .A(w55), .B(s64), .CI(c54));
    ADDFX1 a46(.S(s46), .CO(c46), .A(w46), .B(s55), .CI(c45));
    ADDFX1 a47(.S(s37), .CO(c37), .A(w37), .B(s46), .CI(c36));
    ADDFX1 a48(.S(mulout[10]), .CO(c010), .A(s37), .B(c27), .CI(c09));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ADDFX1 a49(.S(s83), .CO(c83), .A(w83), .B(w74), .CI(c82));
    ADDFX1 a50(.S(s65), .CO(c65), .A(w65), .B(s83), .CI(c64));
    ADDFX1 a51(.S(s56), .CO(c56), .A(w56), .B(s65), .CI(c55));
    ADDFX1 a52(.S(s47), .CO(c47), .A(w47), .B(s56), .CI(c46));
    ADDFX1 a53(.S(mulout[11]), .CO(c011), .A(s47), .B(c37), .CI(c010));
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    ADDFX1 a54(.S(s84), .CO(c84), .A(w84), .B(w75), .CI(c83));
    ADDFX1 a55(.S(s66), .CO(c66), .A(w66), .B(s84), .CI(c65));
    ADDFX1 a56(.S(s57), .CO(c57), .A(w57), .B(s66), .CI(c56));
    ADDFX1 a57(.S(mulout[12]), .CO(c012), .A(s57), .B(c47), .CI(c011));
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    ADDFX1 a58(.S(s85), .CO(c85), .A(w85), .B(w76), .CI(c84));
    ADDFX1 a59(.S(s67), .CO(c67), .A(w67), .B(s85), .CI(c66));
    ADDFX1 a60(.S(mulout[13]), .CO(c013), .A(s67), .B(c57), .CI(c012));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a61(.S(s86), .CO(c86), .A(w86), .B(w77), .CI(c85));
    ADDFX1 a62(.S(mulout[14]), .CO(c014), .A(s86), .B(c67), .CI(c013));
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ADDFX1 a63(.S(mulout[15]), .CO(mulout[16]), .A(w87), .B(c86), .CI(c014));
endmodule

module div_2(in, out);
    input  [16:0] in;
    output [15:0] out;
    
    BUFX12 b0(.Y(out[0]), .A(in[1]));
    BUFX12 b1(.Y(out[1]), .A(in[2]));
    BUFX12 b2(.Y(out[2]), .A(in[3]));
    BUFX12 b3(.Y(out[3]), .A(in[4]));
    BUFX12 b4(.Y(out[4]), .A(in[5]));
    BUFX12 b5(.Y(out[5]), .A(in[6]));
    BUFX12 b6(.Y(out[6]), .A(in[7]));
    BUFX12 b7(.Y(out[7]), .A(in[8]));
    BUFX12 b8(.Y(out[8]), .A(in[9]));
    BUFX12 b9(.Y(out[9]), .A(in[10]));
    BUFX12 b10(.Y(out[10]), .A(in[11]));
    BUFX12 b11(.Y(out[11]), .A(in[12]));
    BUFX12 b12(.Y(out[12]), .A(in[13]));
    BUFX12 b13(.Y(out[13]), .A(in[14]));
    BUFX12 b14(.Y(out[14]), .A(in[15]));
    BUFX12 b15(.Y(out[15]), .A(in[16]));
endmodule


module lab03b(a, b, c, out);
    input   [7:0] a, b, c;
    output [15:0] out;
    
    wire [7:0] add_s;
    wire add_c;
    wire [16:0] mulout;

//Examples to instantiate the cells from cell library
//AND2X1 u1(out1,a,b);
  
//** Add your code below this line **//
    add8 add_8(.a(a), .b(b), .cin(0), .sum(add_s), .cout(add_c));
    multiplier mul(.a({add_c, add_s}), .b(c), .mulout(mulout));
    div_2 div(.in(mulout), .out(out));
endmodule
