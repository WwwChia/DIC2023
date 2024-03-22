//------------------------------------------------------//
//- Digital IC Design 2024                              //
//- Lab08: Low-Power Syntheis                           //
//- @author: Wei Chia Huang                             //
//- Last update: Mar 5 2024                             //
//------------------------------------------------------//

//cadence translate_off
`include "/usr/chipware/CW_minmax.v"
//cadence translate_on

module LCD_CTRL(clk,
                reset,
                cmd,
                cmd_valid,
                IROM_Q,
                IROM_rd,
                IROM_A,
                IRAM_valid,
                IRAM_D,
                IRAM_A,
                busy,
                done);
input clk;
input reset;
input [2:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output reg IROM_rd;
output reg [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output reg done;

//** Add your code below this line **//
reg [7:0] image[0:7][0:7];
wire [7:0] min, max;
reg [2:0] x, y;
wire [9:0] sum;

CW_minmax #(8,4) minIP(.a({image[x][y], image[x-1][y], image[x][y-1], image[x-1][y-1]}), .tc(1'b0), .min_max(1'b0), .value(min), .index());
CW_minmax #(8,4) maxIP(.a({image[x][y], image[x-1][y], image[x][y-1], image[x-1][y-1]}), .tc(1'b0), .min_max(1'b1), .value(max), .index());

assign sum = image[x][y] + image[x-1][y] + image[x][y-1] + image[x-1][y-1];

always@(posedge clk) begin                              
    if(reset)
        IROM_rd <= 1;
    else if(IROM_A == 63)
        IROM_rd <= 0;
end

always@(posedge clk) begin
    if(reset)
        IROM_A <= 0;
    else if(IROM_rd && IROM_A < 63)
        IROM_A <= IROM_A + 1;
    else 
        IROM_A <= 0;
end

always@(posedge clk) begin
    if(IROM_rd)
        image[x][y] <= IROM_Q;
    else if(cmd_valid && !busy) begin
        if(cmd == 5) begin
            image[x][y]     <= max;
            image[x-1][y]   <= max;
            image[x][y-1]   <= max;
            image[x-1][y-1] <= max;
        end
        else if(cmd == 6) begin
            image[x][y]     <= min;
            image[x-1][y]   <= min;
            image[x][y-1]   <= min;
            image[x-1][y-1] <= min;
        end
        else if(cmd == 7) begin
            image[x][y]     <= sum[9:2];
            image[x-1][y]   <= sum[9:2];
            image[x][y-1]   <= sum[9:2];
            image[x-1][y-1] <= sum[9:2];
        end
    end
end

always@(posedge clk) begin                              
    if(reset) begin
        x <= 0;
        y <= 0;
    end
	else if(IROM_A == 63) begin
        x <= 4;
        y <= 4;
    end 
    else if(IROM_rd || IRAM_valid) begin
        if(x == 7) begin
            x <= 0;
            y <= y + 1;
        end    
        else 
            x <= x + 1;
    end
    else if(cmd_valid && !busy) begin
        case(cmd)
            0: begin
                x <= 1;
                y <= 0;
            end
            1: begin
                if(y != 1)
                    y <= y - 1;
            end
            2: begin
                if(y != 7)
                    y <= y + 1;
            end
            3: begin
                if(x != 1)
                    x <= x - 1;
            end
            4: begin
                if(x != 7)
                    x <= x + 1;
            end
        endcase
    end
end

always@(posedge clk) begin
    if(reset)
        busy <= 1;
    else if(IROM_A == 63)
        busy <= 0;
end

always@(posedge clk) begin
    if(reset)
        IRAM_valid <= 0;
    else if(cmd_valid && !busy) begin
        if(cmd == 0)
            IRAM_valid <= 1;
    end
end

always@(posedge clk) begin
    if(reset)
        IRAM_A <= 0;
    else if(IRAM_valid)
        IRAM_A <= IRAM_A + 1;
    else
        IRAM_A <= 0;
end

always@(posedge clk) begin
    if(cmd_valid && cmd == 0)
       	IRAM_D <= image[0][0];
	else if(IRAM_valid)
		IRAM_D <= image[x][y];
end

always@(posedge clk) begin
    if(reset)
        done <= 0;
    else if(IRAM_A == 63)
        done <= 1;
end
endmodule
  
