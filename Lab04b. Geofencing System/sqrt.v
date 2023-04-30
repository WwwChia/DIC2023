//------------------------------------------------------//
//- @author: Wei Chia Huang                             //        
//- Last update: Apr 17 2023                            //
//------------------------------------------------------//
module sqrt(in, clk, rst, out);

input [20:0] in;
input clk, rst;
output reg [10:0] out;

reg [3:0] idx;

always@(posedge clk or posedge rst) begin
	if(rst)
		idx <= 4'd10;
	
	else if(idx != 0)
		idx <= idx - 1;
end

always@(posedge clk or posedge rst) begin
	if(rst)
		out <= 11'b100_0000_0000;
	
	else if(idx != 0) begin
		if((out*out) > in) begin
		    out[idx] <= 0;
		    out[idx-1] <= 1;
		end
		
		else
		    out[idx-1] <= 1;
	end
	
	else if(idx == 0) begin
		if((out*out) > in)
		    out[idx] <= 0;
	end
end

endmodule