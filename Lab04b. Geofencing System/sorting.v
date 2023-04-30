//------------------------------------------------------//
//- @author: Wei Chia Huang                             //        
//- Last update: Apr 17 2023                            //
//------------------------------------------------------//
module sorting(clk, rst, X, Y, R, is_valid, Area);

input [9:0] X, Y;
input [10:0] R;
input clk, rst;

output reg is_valid;
output reg signed [21:0] Area;

reg signed [10:0] sorted_X[0:5];
reg signed [10:0] sorted_Y[0:5];
reg signed [11:0] sorted_R[0:5];

reg in_valid;
reg sort_idx;
reg [2:0] counter;
reg [2:0] sort_cnt;
reg [2:0] i;

always@(posedge clk or posedge rst) begin
    if(rst) 
		counter <= 0;
	  
	else if(counter != 6)
		counter <= counter + 1;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
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

always@(posedge clk or posedge rst) begin
    if(rst) 
		in_valid <= 0;
	  
	else if(counter == 5)
		in_valid <= 1;
		
	else if(sort_cnt == 5)
		in_valid <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst) 
		sort_cnt <= 0;
	  
	else if(in_valid && (sort_cnt != 5))
		sort_cnt <= sort_cnt + 1;
		
	else if(sort_cnt == 5)
		sort_cnt <= 0;
end		

always@(posedge clk or posedge rst) begin
    if(rst) 
		sort_idx <= 0;
	  
	else if(counter == 6)
		sort_idx <= ~sort_idx;
end

always@(posedge clk or posedge rst) begin
    if(rst) 
		is_valid <= 0;
	  
	else if(sort_cnt == 5)
		is_valid <= 1;
		
	else if(sort_cnt == 0)
		is_valid <= 0;
end

always@(posedge clk or posedge rst) begin
    if(rst) 
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

endmodule