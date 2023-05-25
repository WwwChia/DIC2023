//------------------------------------------------------//
//- Digital IC Design 2023                              //
//- Lab08: Low-Power Syntheis                           //
//- @author: Wei Chia Huang                             //
//- Last update: May 25 2023                            //
//------------------------------------------------------//
`timescale 1ns/10ps

//cadence translate_off
`include "/usr/chipware/CW_mult_n_stage.v"
`include "/usr/chipware/CW_mult.v"
`include "/usr/chipware/CW_pipe_reg.v"
//cadence translate_on

module SET ( clk , rst, en, central, radius, busy, valid, candidate);

input         clk, rst;
input         en;
input  [15:0] central;
input   [7:0] radius;
output        busy;
output        valid;
output  [7:0] candidate;  //[6:0]即可

//Write Your Design Here
reg valid;
reg busy;
reg [7:0] candidate;

//sign extension
reg signed [5:0] central_se[0:3];
reg signed [5:0]  radius_se[0:1];

reg signed [5:0] sorted_X[0:3];  //X boundary(sorted_X[1] & sorted_X[2])(range:-15 ~ 30)
reg signed [5:0] sorted_Y[0:3];  //Y boundary(sorted_Y[1] & sorted_Y[2])(range:-15 ~ 30)

integer i;
integer j;
reg [2:0] state;

reg       sort_idx;
reg [2:0] sort_cnt;

wire signed [11:0] r_square[0:1];

reg signed [5:0] X_tp;  //testing point
reg signed [5:0] Y_tp;

wire signed [11:0] result[0:3];

reg [7:0] cycle_cnt;
reg [1:0] reciprocal_cnt;

parameter  INIT       = 0,
           SB_MODIFY  = 1,  //sorting boundary modify
           SORTING    = 2,
           SBR_MODIFY = 3,  //sorting boundary remodify(+early test)
           CALCULATE  = 4;

CW_mult_n_stage #(6, 6, 3) u1 (.A(radius_se[0]), .B(radius_se[0]), .TC(1'b1), .CLK (clk), .Z(r_square[0]));  //r1^2
CW_mult_n_stage #(6, 6, 3) u2 (.A(radius_se[1]), .B(radius_se[1]), .TC(1'b1), .CLK (clk), .Z(r_square[1]));  //r2^2

CW_mult_n_stage #(6, 6, 3) u3 (.A(X_tp - central_se[0]), .B(X_tp - central_se[0]), .TC(1'b1), .CLK (clk), .Z(result[0]));
CW_mult_n_stage #(6, 6, 3) u4 (.A(Y_tp - central_se[1]), .B(Y_tp - central_se[1]), .TC(1'b1), .CLK (clk), .Z(result[1]));
CW_mult_n_stage #(6, 6, 3) u5 (.A(X_tp - central_se[2]), .B(X_tp - central_se[2]), .TC(1'b1), .CLK (clk), .Z(result[2]));
CW_mult_n_stage #(6, 6, 3) u6 (.A(Y_tp - central_se[3]), .B(Y_tp - central_se[3]), .TC(1'b1), .CLK (clk), .Z(result[3]));

always@(posedge clk or posedge rst) begin
    if(rst)
        state <= INIT;

    else if(en)
        state <= SB_MODIFY;

    else if(state == SB_MODIFY)
        state <= SORTING;

    else if(sort_cnt == 4)
        state <= SBR_MODIFY;

    else if(state == SBR_MODIFY)
        state <= CALCULATE;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        central_se[0] <= 0;
        central_se[1] <= 0;
        central_se[2] <= 0;
        central_se[3] <= 0;
        radius_se[0]  <= 0;
        radius_se[1]  <= 0;
    end

    else if(en) begin
        central_se[0] <= {2'b00, central[15:12]};  //x1
        central_se[1] <=  {2'b00, central[11:8]};  //y1
        central_se[2] <=   {2'b00, central[7:4]};  //x2
        central_se[3] <=   {2'b00, central[3:0]};  //y2
        radius_se[0]  <=    {2'b00, radius[7:4]};  //r1
        radius_se[1]  <=    {2'b00, radius[3:0]};  //r2
    end
end

always@(posedge clk or posedge rst) begin
    if(rst)
        sort_cnt <= 0;

    else if(state == 2 && (sort_cnt < 4))
        sort_cnt <= sort_cnt + 1;

    else if(sort_cnt == 4)  //necessary
        sort_cnt <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst)
        sort_idx <= 0;

    else if(state == SORTING && (sort_cnt < 4))
        sort_idx <= ~sort_idx;

    else if(valid)
        sort_idx <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(i = 0; i <= 3; i = i + 1)
            sorted_X[i] <= 0;
    end

    else if(valid) begin
        for(i = 0; i <= 3; i = i + 1)
            sorted_X[i] <= 0; 
    end
    
    else if(state == SB_MODIFY) begin
        sorted_X[0] <= central_se[0] - radius_se[0]; 
        sorted_X[1] <= central_se[0] + radius_se[0]; 
        sorted_X[2] <= central_se[2] - radius_se[1];
        sorted_X[3] <= central_se[2] + radius_se[1];                                        
    end

    else if(state == SORTING  && (sort_cnt < 4)) begin  //start sorting
        if(~sort_idx) begin
            for(i = 0; i < 3; i = i + 2) begin
                if(sorted_X[i] > sorted_X[i+1]) begin
                    sorted_X[i] <= sorted_X[i+1];
                    sorted_X[i+1] <= sorted_X[i];
                end
            end
        end

        else begin
            for(i = 1; i < 3; i = i + 2) begin
                if(sorted_X[i] > sorted_X[i+1]) begin
                    sorted_X[i] <= sorted_X[i+1]; 
                    sorted_X[i+1] <= sorted_X[i]; 
                end
            end
        end
    end

    else if(state == SBR_MODIFY) begin
        sorted_X[1] <= (sorted_X[1] < 1) ? 1 : sorted_X[1];
        sorted_X[2] <= (sorted_X[2] > 8) ? 8 : sorted_X[2];
    end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(j = 0; j <= 3; j = j + 1)
            sorted_Y[j] <= 0;
    end

    else if(valid) begin
        for(j = 0; j <= 3; j = j + 1)
            sorted_Y[j] <= 0;
    end

    else if(state == SB_MODIFY) begin
        sorted_Y[0] <= central_se[1] - radius_se[0];
        sorted_Y[1] <= central_se[1] + radius_se[0];
        sorted_Y[2] <= central_se[3] - radius_se[1];
        sorted_Y[3] <= central_se[3] + radius_se[1];
    end

    else if(state == SORTING  && (sort_cnt < 4)) begin  //start sorting
        if(~sort_idx) begin
            for(j = 0; j < 3; j = j + 2) begin
                if(sorted_Y[j] > sorted_Y[j+1]) begin
                    sorted_Y[j] <= sorted_Y[j+1];
                    sorted_Y[j+1] <= sorted_Y[j];
                end
            end
        end

        else begin
            for(j = 1; j < 3; j = j + 2) begin
                if(sorted_Y[j] > sorted_Y[j+1]) begin
                    sorted_Y[j] <= sorted_Y[j+1];
                    sorted_Y[j+1] <= sorted_Y[j];
                end
            end
        end
    end

    else if(state == SBR_MODIFY) begin
        sorted_Y[1] <= (sorted_Y[1] < 1) ? 1 : sorted_Y[1];
        sorted_Y[2] <= (sorted_Y[2] > 8) ? 8 : sorted_Y[2];
    end
end

always@(posedge clk or posedge rst) begin
    if(rst)
        candidate <= 0;

    else if(state == SBR_MODIFY) begin
        if((sorted_X[1] > 8) || (sorted_X[2] < 1) || (sorted_Y[1] > 8) || (sorted_Y[2] < 1))
            candidate <= 0;  //complete
    end

    else if(state == CALCULATE) begin
        if((cycle_cnt >= 3) && (reciprocal_cnt <= 3)) begin
            if(((result[0] + result[1]) <= r_square[0]) && ((result[2] + result[3]) <= r_square[1]))
                candidate <= candidate + 1;
        end
    end

    else if(valid == 0)
        candidate <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst)
        X_tp <= 0;
    
    else if(valid)
        X_tp <= 0;
    
    else if(state == SBR_MODIFY)
        X_tp <= (sorted_X[1] < 1) ? 1 : sorted_X[1];

    else if(state == CALCULATE) begin
        if(X_tp != sorted_X[2])
            X_tp <= X_tp + 1;

        else if(Y_tp != sorted_Y[2])
            X_tp <= sorted_X[1];
    end
end

always@(posedge clk or posedge rst) begin
    if(rst)
        Y_tp <= 0;
    
    else if(state == SBR_MODIFY)
        Y_tp <= (sorted_Y[1] < 1) ? 1 : sorted_Y[1];

    else if(state == CALCULATE) begin
        if((Y_tp != sorted_Y[2]) && (X_tp == sorted_X[2]))
            Y_tp <= Y_tp + 1;
    end

    else if(valid)
        Y_tp <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst)
        reciprocal_cnt <= 0;

    else if((state == CALCULATE) && (Y_tp == sorted_Y[2]) && (X_tp == sorted_X[2]))
        reciprocal_cnt <= reciprocal_cnt + 1;
    
    else if(valid == 1)
        reciprocal_cnt <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst)
        cycle_cnt <= 0;

    else if(state == CALCULATE) begin
        if(reciprocal_cnt != 3)
            cycle_cnt <= cycle_cnt + 1;

        else
            cycle_cnt <= 0;
    end
end

always@(posedge clk or posedge rst) begin
    if(rst)
        busy <= 0;

    else if(en)
        busy <= 1;

    else if(reciprocal_cnt == 3)
        busy <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst)
        valid <= 0;

    else if(state == SBR_MODIFY) begin
        if((sorted_X[1] > 8) || (sorted_X[2] < 1) || (sorted_Y[1] > 8) || (sorted_Y[2] < 1))
            valid <= 1;
    end

    else if(reciprocal_cnt == 3)
        valid <= 1;
    
    else if(valid == 1)
        valid <= 0;
end

endmodule
