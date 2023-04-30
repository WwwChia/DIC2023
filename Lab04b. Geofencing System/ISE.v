//------------------------------------------------------//
//- Digital IC Design 2022                              //
//-                                                     //
//- Lab10: Scain Chain Insertion and ATPG               //
//------------------------------------------------------//

module ISE
(
   // Output Port
   OUT_VALID,
   OUT_DATA,
   
   // Input Port
   CLK,
   RESET,
   IN_VALID,
   IN_DATA
);

parameter DATA_WIDTH = 8;

input                   CLK;
input                   RESET;
input                   IN_VALID;
input  [DATA_WIDTH-1:0] IN_DATA;

output                  OUT_VALID;
output [DATA_WIDTH-1:0] OUT_DATA;

wire                    CLK;
wire                    RESET;
wire                    IN_VALID;
wire   [DATA_WIDTH-1:0] IN_DATA;
wire   [DATA_WIDTH  :0] TEMP1;
wire   [DATA_WIDTH  :0] TEMP2;
wire   [DATA_WIDTH  :0] TEMP3;
wire   [DATA_WIDTH+1:0] SUM_ROW1;
wire   [DATA_WIDTH+2:0] SUM_ROW2;
wire   [DATA_WIDTH+1:0] SUM_ROW3;
wire   [DATA_WIDTH+3:0] SUM_TOTAL;
reg    [DATA_WIDTH-1:0] OUT_DATA;
reg                     OUT_VALID;

reg  [5*DATA_WIDTH-1:0] ROW1;
reg  [5*DATA_WIDTH-1:0] ROW2;
reg  [5*DATA_WIDTH-1:0] ROW3;
reg  [5*DATA_WIDTH-1:0] ROW4;
reg  [5*DATA_WIDTH-1:0] ROW5;

reg  [5:0] COUNTER;
wire       SMOOTHING;
wire       CHANGE_ROW;

assign TEMP1 = ROW1[5*DATA_WIDTH-1:4*DATA_WIDTH] + ROW1[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign TEMP2 = ROW2[5*DATA_WIDTH-1:4*DATA_WIDTH] + ROW2[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign TEMP3 = ROW3[5*DATA_WIDTH-1:4*DATA_WIDTH] + ROW3[3*DATA_WIDTH-1:2*DATA_WIDTH];

assign SUM_ROW1 = TEMP1 + {ROW1[4*DATA_WIDTH-1:3*DATA_WIDTH], 1'b0};
assign SUM_ROW2 = {TEMP2, 1'b0} + {ROW2[4*DATA_WIDTH-1:3*DATA_WIDTH], 2'b0};
assign SUM_ROW3 = TEMP3 + {ROW3[4*DATA_WIDTH-1:3*DATA_WIDTH], 1'b0};

assign SUM_TOTAL = SUM_ROW1 + SUM_ROW2 + SUM_ROW3;

assign SMOOTHING = (COUNTER>=6'd25 && COUNTER<6'd34)? 1'b1 : 1'b0;

assign CHANGE_ROW = (COUNTER==6'd27 || COUNTER==6'd30)? 1'b1 : 1'b0;

//cadence sync_set_reset "RESET"

always@(posedge CLK)
begin
   if (RESET)
   begin
      ROW1 <= 0;
      ROW2 <= 0;
      ROW3 <= 0;
      ROW4 <= 0;
      ROW5 <= 0;
   end
   else if (IN_VALID)
   begin
      ROW1 <= {ROW1, ROW2[5*DATA_WIDTH-1:4*DATA_WIDTH]};
      ROW2 <= {ROW2, ROW3[5*DATA_WIDTH-1:4*DATA_WIDTH]};
      ROW3 <= {ROW3, ROW4[5*DATA_WIDTH-1:4*DATA_WIDTH]};
      ROW4 <= {ROW4, ROW5[5*DATA_WIDTH-1:4*DATA_WIDTH]};
      ROW5 <= {ROW5, IN_DATA};
   end
   else if (SMOOTHING)
   begin
      if (CHANGE_ROW)
      begin
         ROW1 <= {ROW2[2*DATA_WIDTH-1:0], ROW2[5*DATA_WIDTH-1:2*DATA_WIDTH]};
         ROW2 <= {ROW3[2*DATA_WIDTH-1:0], ROW3[5*DATA_WIDTH-1:2*DATA_WIDTH]};
         ROW3 <= {ROW4[2*DATA_WIDTH-1:0], ROW4[5*DATA_WIDTH-1:2*DATA_WIDTH]};
         ROW4 <= {ROW5[2*DATA_WIDTH-1:0], ROW5[5*DATA_WIDTH-1:2*DATA_WIDTH]};
         ROW5 <= {ROW1[2*DATA_WIDTH-1:0], ROW1[5*DATA_WIDTH-1:2*DATA_WIDTH]};
      end
      else
      begin
         ROW1 <= {ROW1, ROW1[5*DATA_WIDTH-1:4*DATA_WIDTH]};
         ROW2 <= {ROW2, ROW2[5*DATA_WIDTH-1:4*DATA_WIDTH]};
         ROW3 <= {ROW3, ROW3[5*DATA_WIDTH-1:4*DATA_WIDTH]};
         ROW4 <= {ROW4, ROW4[5*DATA_WIDTH-1:4*DATA_WIDTH]};
         ROW5 <= {ROW5, ROW5[5*DATA_WIDTH-1:4*DATA_WIDTH]};
      end
   end
end

always@(posedge CLK)
begin
   if (RESET)
      COUNTER <= 6'd0;
   else if (IN_VALID || SMOOTHING)
      COUNTER <= COUNTER + 6'd1;
   else if (COUNTER==6'd34)
      COUNTER <= 6'd0;
end

always@(posedge CLK)
begin
   if (RESET)
      OUT_VALID <= 1'd0;
   else if (SMOOTHING)
      OUT_VALID <= 1'd1;
   else
      OUT_VALID <= 1'd0;
end

always@(posedge CLK)
begin
   if (RESET)
      OUT_DATA <= 0;
   else if (SMOOTHING)
      OUT_DATA <= SUM_TOTAL[DATA_WIDTH+3:4];
end


endmodule
