//------------------------------------------------------//
//- Digital IC Design 2023                              //
//- Lab04b: Verilog Behavioral Level                    //
//- @author: Wei Chia Huang                             //
//- Last update: Apr 22 2023                            //
//------------------------------------------------------//
`timescale 1ns/10ps

module geofence ( clk,reset,X,Y,R,valid,is_inside,Area);

input        clk;
input        reset;
input  [9:0] X;
input  [9:0] Y;
input [10:0] R;

output reg        valid;
output reg        is_inside;
output reg signed [21:0] Area;

reg is_valid;  //complete sorting

reg signed [10:0] sorted_X[0:5];
reg signed [10:0] sorted_Y[0:5];
reg signed [11:0] sorted_R[0:5];
reg signed [21:0] Area_compare;

reg in_valid;
reg sort_idx;
reg [2:0] counter;
reg [2:0] sort_cnt;
reg [2:0] i;

reg [22:0] dist_01_s, dist_12_s, dist_23_s, dist_34_s, dist_45_s, dist_50_s;  //distane square of adjacent points
reg [10:0] dist_01, dist_12, dist_23, dist_34, dist_45, dist_50;  //distane of adjacent points

reg [11:0] sorted_R_temp[0:5];
reg [10:0] s[0:5];

reg [20:0] p01, q01, p12, q12, p23, q23, p34, q34, p45, q45, p50, q50;
reg [10:0] p01_s, q01_s, p12_s, q12_s, p23_s, q23_s, p34_s, q34_s, p45_s, q45_s, p50_s, q50_s;

reg [3:0] state;

always@(posedge clk or posedge reset) begin
    if(reset)
        counter <= 0;
    
    else if(valid == 1)
        counter <= 0;
    
    else if(counter != 6)
        counter <= counter + 1;
end

always@(posedge clk or posedge reset) begin
    if(reset) begin
        for(i = 0; i < 6; i = i + 1) begin
            sorted_X[i] <= 0;
            sorted_Y[i] <= 0;
            sorted_R[i] <= 0;
        end
    end

    else if(counter != 6) begin  //store temporarily
        sorted_X[counter] <= {1'b0, X};
        sorted_Y[counter] <= {1'b0, Y};
        sorted_R[counter] <= {1'b0, R};
    end

    else begin
        if(in_valid && (~sort_idx) && (sort_cnt < 5)) begin
            for(i = 1; i < 5; i = i + 2) begin
                if(((sorted_X[i] - sorted_X[0]) * (sorted_Y[i+1] - sorted_Y[0]) - (sorted_X[i+1] - sorted_X[0]) * (sorted_Y[i] - sorted_Y[0])) < 0) begin
                    sorted_X[i] <= sorted_X[i+1];
                    sorted_Y[i] <= sorted_Y[i+1];
                    sorted_R[i] <= sorted_R[i+1];
                    sorted_X[i+1] <= sorted_X[i];
                    sorted_Y[i+1] <= sorted_Y[i];
                    sorted_R[i+1] <= sorted_R[i];
                end
            end
        end

        else if(in_valid && sort_idx && (sort_cnt < 5)) begin
            for(i = 2; i < 6; i = i + 2) begin
                if(((sorted_X[i] - sorted_X[0]) * (sorted_Y[i+1] - sorted_Y[0]) - (sorted_X[i+1] - sorted_X[0]) * (sorted_Y[i] - sorted_Y[0])) < 0) begin
                    sorted_X[i] <= sorted_X[i+1];
                    sorted_Y[i] <= sorted_Y[i+1];
                    sorted_R[i] <= sorted_R[i+1];
                    sorted_X[i+1] <= sorted_X[i];
                    sorted_Y[i+1] <= sorted_Y[i];
                    sorted_R[i+1] <= sorted_R[i];
                end
            end
        end
    end
end

always@(posedge clk or posedge reset) begin
    if(reset)
        in_valid <= 0;

    else if(counter == 5)
        in_valid <= 1;

    else if(sort_cnt == 5)
        in_valid <= 0;
end

always@(posedge clk or posedge reset) begin
    if(reset)
        sort_cnt <= 0;

    else if(in_valid && (sort_cnt != 5))
        sort_cnt <= sort_cnt + 1;

    else if(sort_cnt == 5)
        sort_cnt <= 0;
end

always@(posedge clk or posedge reset) begin
    if(reset)
        sort_idx <= 0;

    else if(counter == 6)
        sort_idx <= ~sort_idx;
end

always@(posedge clk or posedge reset) begin
    if(reset)
        is_valid <= 0;

    else if(sort_cnt == 5)
        is_valid <= 1;

    else if(sort_cnt == 0)
        is_valid <= 0;
end

always@(posedge clk or posedge reset) begin
    if(reset)
        Area <= 0;

    else if(sort_cnt == 5) begin
        Area <= ((sorted_X[0]*sorted_Y[1] - sorted_X[1]*sorted_Y[0])+
                 (sorted_X[1]*sorted_Y[2] - sorted_X[2]*sorted_Y[1])+
                 (sorted_X[2]*sorted_Y[3] - sorted_X[3]*sorted_Y[2])+
                 (sorted_X[3]*sorted_Y[4] - sorted_X[4]*sorted_Y[3])+
                 (sorted_X[4]*sorted_Y[5] - sorted_X[5]*sorted_Y[4])+
                 (sorted_X[5]*sorted_Y[0] - sorted_X[0]*sorted_Y[5])) >>> 1;
    end
end

always@(posedge clk or posedge reset) begin
    if(is_valid) begin
        sorted_R_temp[0] <= sorted_R[0];
        sorted_R_temp[1] <= sorted_R[1];
        sorted_R_temp[2] <= sorted_R[2];
        sorted_R_temp[3] <= sorted_R[3];
        sorted_R_temp[4] <= sorted_R[4];
        sorted_R_temp[5] <= sorted_R[5];
    end
end

always@(posedge clk or posedge reset) begin  //use one cycle to calculate the square of distane between any two adjacent points
    if(reset) begin
        dist_01_s <= 0;  //23-bit
        dist_12_s <= 0;
        dist_23_s <= 0;
        dist_34_s <= 0;
        dist_45_s <= 0;
        dist_50_s <= 0;
    end

    else if(is_valid) begin
        dist_01_s <= (sorted_X[1] - sorted_X[0]) * (sorted_X[1] - sorted_X[0]) + (sorted_Y[1] - sorted_Y[0]) * (sorted_Y[1] - sorted_Y[0]);  //23-bit
        dist_12_s <= (sorted_X[2] - sorted_X[1]) * (sorted_X[2] - sorted_X[1]) + (sorted_Y[2] - sorted_Y[1]) * (sorted_Y[2] - sorted_Y[1]);
        dist_23_s <= (sorted_X[3] - sorted_X[2]) * (sorted_X[3] - sorted_X[2]) + (sorted_Y[3] - sorted_Y[2]) * (sorted_Y[3] - sorted_Y[2]);
        dist_34_s <= (sorted_X[4] - sorted_X[3]) * (sorted_X[4] - sorted_X[3]) + (sorted_Y[4] - sorted_Y[3]) * (sorted_Y[4] - sorted_Y[3]);
        dist_45_s <= (sorted_X[5] - sorted_X[4]) * (sorted_X[5] - sorted_X[4]) + (sorted_Y[5] - sorted_Y[4]) * (sorted_Y[5] - sorted_Y[4]);
        dist_50_s <= (sorted_X[0] - sorted_X[5]) * (sorted_X[0] - sorted_X[5]) + (sorted_Y[0] - sorted_Y[5]) * (sorted_Y[0] - sorted_Y[5]);
    end
end

always@(posedge clk or posedge reset) begin  //use one cycle to calculate the square root of distane between any two adjacent points
    if(state == 1) begin
        dist_01 <= sqrt(dist_01_s);
        dist_12 <= sqrt(dist_12_s);
        dist_23 <= sqrt(dist_23_s);
        dist_34 <= sqrt(dist_34_s);
        dist_45 <= sqrt(dist_45_s);
        dist_50 <= sqrt(dist_50_s);
    end
end

always@(posedge clk or posedge reset) begin
    if(state == 2) begin
        s[0] <= (sorted_R_temp[0] + sorted_R_temp[1] + dist_01) >> 1;  //11-bit
        s[1] <= (sorted_R_temp[1] + sorted_R_temp[2] + dist_12) >> 1;
        s[2] <= (sorted_R_temp[2] + sorted_R_temp[3] + dist_23) >> 1;
        s[3] <= (sorted_R_temp[3] + sorted_R_temp[4] + dist_34) >> 1;
        s[4] <= (sorted_R_temp[4] + sorted_R_temp[5] + dist_45) >> 1;
        s[5] <= (sorted_R_temp[5] + sorted_R_temp[0] + dist_50) >> 1;
    end
end

always@(posedge clk) begin
    if(state == 3) begin
        p01 <=  s[0] * (s[0] - sorted_R_temp[0]);
        q01 <= (s[0] - sorted_R_temp[1]) * (s[0] - dist_01);
        p12 <=  s[1] * (s[1] - sorted_R_temp[1]);
        q12 <= (s[1] - sorted_R_temp[2]) * (s[1] - dist_12);
        p23 <=  s[2] * (s[2] - sorted_R_temp[2]);
        q23 <= (s[2] - sorted_R_temp[3]) * (s[2] - dist_23);
        p34 <=  s[3] * (s[3] - sorted_R_temp[3]);
        q34 <= (s[3] - sorted_R_temp[4]) * (s[3] - dist_34);
        p45 <=  s[4] * (s[4] - sorted_R_temp[4]);
        q45 <= (s[4] - sorted_R_temp[5]) * (s[4] - dist_45);
        p50 <=  s[5] * (s[5] - sorted_R_temp[5]);
        q50 <= (s[5] - sorted_R_temp[0]) * (s[5] - dist_50);
    end
end

always@(posedge clk) begin
    if(state == 4) begin
        p01_s <= sqrt(p01);
        q01_s <= sqrt(q01);
        p12_s <= sqrt(p12);
        q12_s <= sqrt(q12);
        p23_s <= sqrt(p23);
        q23_s <= sqrt(q23);
    end
end

always@(posedge clk) begin
    if(state == 5) begin
        p34_s <= sqrt(p34);
        q34_s <= sqrt(q34);
        p45_s <= sqrt(p45);
        q45_s <= sqrt(q45);
        p50_s <= sqrt(p50);
        q50_s <= sqrt(q50);
    end
end

always@(posedge clk) begin
    if(state == 6)
        Area_compare <= (p01_s*q01_s) + (p12_s*q12_s) + (p23_s*q23_s) + (p34_s*q34_s) + (p45_s*q45_s) + (p50_s*q50_s);
end

always@(posedge clk) begin
    if(state == 7) begin
        if(Area_compare > Area)
            is_inside <= 0;
        
        else
            is_inside <= 1;
    end
end

always@(posedge clk) begin
    if(state == 0)
        valid <= 0;
    
    else if(state == 7)
        valid <= 1;
end

always@(posedge clk or posedge reset) begin
    if(reset)
        state <= 0;

    else if(is_valid)
        state <= state + 1;

    else if((state >= 1) && (state < 7))
        state <= state + 1;

    else
        state <= 0;
end

function [10:0] sqrt;
    input [21:0] in;
    reg [3:0] idx;

    begin
        sqrt = 11'b100_0000_0000;

        for(idx = 4'd10; idx > 0; idx = idx - 1) begin
            if(idx != 0) begin
                if((sqrt*sqrt) > in) begin
                    sqrt[idx] = 0;
                    sqrt[idx-1] = 1;
                end

                else
                    sqrt[idx-1] = 1;
            end
        end

        if((sqrt*sqrt) > in)
            sqrt[0] = 0;
    end
endfunction

endmodule
