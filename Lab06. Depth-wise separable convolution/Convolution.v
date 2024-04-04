//------------------------------------------------------//
//- Digital IC Design 2024                              //
//- Lab06: Logic Synthesis                              //
//- @author: Wei Chia Huang                             //
//- Last update: Mar 3 2024                             //
//------------------------------------------------------//
`timescale 1ns/10ps

module Convolution(
CLK,
RESET,
IN_DATA_1,
IN_DATA_2,
IN_DATA_3,
IN_VALID,
KERNEL_VALID,
KERNEL,
OUT_DATA,
OUT_VALID
);

integer i;

input              CLK, RESET;
input        [4:0] IN_DATA_1, IN_DATA_2, IN_DATA_3;
input              IN_VALID, KERNEL_VALID;
input signed [7:0] KERNEL;
output reg  [31:0] OUT_DATA;
output reg         OUT_VALID;

//** Add your code below this line **//
reg signed [7:0] dw_kernel[0:20];
reg signed [7:0] pw_kernel[0:2];
reg [6:0] cycle_num;
reg [2:0] j;
reg [6:0] result_cnt;

reg signed [5:0]  img_1[0:20], img_2[0:20], img_3[0:20];
reg signed [12:0] pro1_1[0:6], pro1_2[0:6], pro1_3[0:6];
reg signed [14:0] conv1_1[0:6], conv1_2[0:6], conv1_3[0:6];
reg signed [22:0] pro2_1[0:6], pro2_2[0:6], pro2_3[0:6];
reg signed [24:0] conv2_1, conv2_2, conv2_3;
reg signed [24:0] ReLU1_1, ReLU1_2, ReLU1_3;
reg signed [31:0] pro3_1, pro3_2, pro3_3;
reg signed [32:0] conv3;

always@(posedge CLK) begin
    if(RESET)
        cycle_num <= 0;
    else if(IN_VALID)
        cycle_num <= cycle_num + 1;
	else if(result_cnt == 88)
		cycle_num <= 0;    
end

always@(posedge CLK) begin
    if(IN_VALID && cycle_num <= 20) begin
        img_1[cycle_num] <= {1'b0, IN_DATA_1};
        img_2[cycle_num] <= {1'b0, IN_DATA_2};
        img_3[cycle_num] <= {1'b0, IN_DATA_3};
    end
    else begin
        for(i=0; i<20; i=i+1) begin
            img_1[i] <= img_1[i+1];
            img_2[i] <= img_2[i+1];
            img_3[i] <= img_3[i+1];
        end
        img_1[20] <= {1'b0, IN_DATA_1};
        img_2[20] <= {1'b0, IN_DATA_2};
        img_3[20] <= {1'b0, IN_DATA_3};
    end
end

always@(posedge CLK) begin
    if(KERNEL_VALID) begin
        if(cycle_num < 21)
            dw_kernel[cycle_num] <= KERNEL;
        else
            pw_kernel[cycle_num-21] <= KERNEL;
    end
end

always@(posedge CLK) begin
    if(cycle_num >= 21) begin
        for(i=0; i<7; i=i+1) begin
            pro1_1[i] <= img_1[i] * dw_kernel[i];
            pro1_2[i] <= img_2[i] * dw_kernel[i+7];
            pro1_3[i] <= img_3[i] * dw_kernel[i+14];
        end
    end
end

always@(posedge CLK) begin
    if(RESET)
        j <= 0;
    else if(cycle_num >= 22)
        j <= j + 1;
    else if(cycle_num >= 29)
        j <= 0;
end

always@(posedge CLK) begin
    if(cycle_num >= 22 && cycle_num <= 28) begin
		conv1_1[j] <= pro1_1[0] + pro1_1[1] + pro1_1[2] + pro1_1[3] + pro1_1[4] + pro1_1[5] + pro1_1[6];
        conv1_2[j] <= pro1_2[0] + pro1_2[1] + pro1_2[2] + pro1_2[3] + pro1_2[4] + pro1_2[5] + pro1_2[6];
        conv1_3[j] <= pro1_3[0] + pro1_3[1] + pro1_3[2] + pro1_3[3] + pro1_3[4] + pro1_3[5] + pro1_3[6];
    end
	else if(cycle_num >= 29) begin
        for(i=0; i<6; i=i+1) begin
            conv1_1[i] <= conv1_1[i+1];
            conv1_2[i] <= conv1_2[i+1];
            conv1_3[i] <= conv1_3[i+1];
        end
        conv1_1[6] <= pro1_1[0] + pro1_1[1] + pro1_1[2] + pro1_1[3] + pro1_1[4] + pro1_1[5] + pro1_1[6];
        conv1_2[6] <= pro1_2[0] + pro1_2[1] + pro1_2[2] + pro1_2[3] + pro1_2[4] + pro1_2[5] + pro1_2[6];
        conv1_3[6] <= pro1_3[0] + pro1_3[1] + pro1_3[2] + pro1_3[3] + pro1_3[4] + pro1_3[5] + pro1_3[6];
	end
end

always@(posedge CLK) begin
    if(cycle_num >= 29) begin
        for(i=0; i<7; i=i+1) begin
            pro2_1[i] <= conv1_1[i] * dw_kernel[i];
            pro2_2[i] <= conv1_2[i] * dw_kernel[i+7];
            pro2_3[i] <= conv1_3[i] * dw_kernel[i+14];
        end
    end
end

always@(posedge CLK) begin
    if(cycle_num >= 30) begin
        conv2_1 <= pro2_1[0] + pro2_1[1] + pro2_1[2] + pro2_1[3] + pro2_1[4] + pro2_1[5] + pro2_1[6];
        conv2_2 <= pro2_2[0] + pro2_2[1] + pro2_2[2] + pro2_2[3] + pro2_2[4] + pro2_2[5] + pro2_2[6];
        conv2_3 <= pro2_3[0] + pro2_3[1] + pro2_3[2] + pro2_3[3] + pro2_3[4] + pro2_3[5] + pro2_3[6];
    end
end

always@(posedge CLK) begin
    if(cycle_num >= 31) begin
		ReLU1_1 <= (conv2_1[24] == 1'b1)? 0 : conv2_1;
		ReLU1_2 <= (conv2_2[24] == 1'b1)? 0 : conv2_2;
		ReLU1_3 <= (conv2_3[24] == 1'b1)? 0 : conv2_3;
    end
end

always@(posedge CLK) begin
    if(cycle_num >= 32) begin
        pro3_1 <= ReLU1_1 * pw_kernel[0];
		pro3_2 <= ReLU1_2 * pw_kernel[1];
		pro3_3 <= ReLU1_3 * pw_kernel[2];
	end
end

always@(posedge CLK) begin
    if(cycle_num >= 33)
        conv3 <= pro3_1 + pro3_2 + pro3_3;
end

always@(posedge CLK) begin
    if(cycle_num >= 34) begin
        if(conv3[32] == 1'b1)
            OUT_DATA <= 0;
        else
            OUT_DATA <= conv3[31:0];
    end
end

always@(posedge CLK) begin
    if(RESET)
        result_cnt <= 0;
    else if(cycle_num >= 34)
        result_cnt <= result_cnt + 1;
end

always@(posedge CLK) begin
    if(RESET)
        OUT_VALID <= 0;
	else if(result_cnt == 88)
		OUT_VALID <= 0;
    else if(cycle_num >= 34)
        OUT_VALID <= 1;
end
endmodule
