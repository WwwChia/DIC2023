//------------------------------------------------------//
//- Digital IC Design 2023                              //
//- Lab06: Logic Synthesis                              //
//- @author: Wei Chia Huang                             //        
//- Last update: Apr 29 2023                            //                
//------------------------------------------------------//
`timescale 1ns/10ps

module MBF(CLK, RESET, IN_VALID, IN_DATA, X_DATA, Y_DATA, OUT_VALID);

input   CLK;
input   RESET;
input   IN_VALID;

input       [12:0]  IN_DATA;
output  reg [12:0]  X_DATA;
output  reg [12:0]  Y_DATA;
output  reg         OUT_VALID;

//Write Your Design Here
wire [4:0] L[0:11];
wire [4:0] H[0:11];

reg  [6:0] counter;
reg  [4:0] i;
reg  [4:0] j;
reg  [4:0] k;

reg [12:0] d[0:11];

reg [20:0] accl[0:11];  //21-bit  
reg [20:0] acch[0:11];

reg [20:0] X_DATA_TEMP;
reg [20:0] Y_DATA_TEMP;

assign  H[0] = 5'b01110;  //filter coefficient
assign  H[1] = 5'b00100;
assign  H[2] = 5'b00011;
assign  H[3] = 5'b00001;
assign  H[4] = 5'b10000;
assign  H[5] = 5'b01110;
assign  H[6] = 5'b11100;
assign  H[7] = 5'b10000;
assign  H[8] = 5'b11111;
assign  H[9] = 5'b11100;
assign H[10] = 5'b11111;
assign H[11] = 5'b10001;

assign  L[0] = 5'b11011;  
assign  L[1] = 5'b10011;  
assign  L[2] = 5'b00101;
assign  L[3] = 5'b01001;
assign  L[4] = 5'b10101;
assign  L[5] = 5'b10001;
assign  L[6] = 5'b10000;
assign  L[7] = 5'b10011;
assign  L[8] = 5'b01011;
assign  L[9] = 5'b01100;
assign L[10] = 5'b10000;
assign L[11] = 5'b11111;

always@(posedge CLK or posedge RESET) begin
    if(RESET)
        counter <= 0;
    
    else
        counter <= counter + 1;
end

/*delay stage of LPF & HPF*/
always@(posedge CLK or posedge RESET) begin
    if(RESET) begin
        for(i = 0; i <= 11; i = i + 1)
            d[i] <= 0;
    end

    else begin
        d[0] <= (IN_VALID) ? IN_DATA : 1'b0;    
        d[1] <= d[0];
        d[2] <= d[1];
        d[3] <= d[2];
        d[4] <= d[3];
        d[5] <= d[4];
        d[6] <= d[5];
        d[7] <= d[6];
        d[8] <= d[7];
        d[9] <= d[8];
        d[10] <= d[9];
        d[11] <= d[10];
	end
end

/*multiply stage of HPF*/
always@(posedge CLK or posedge RESET) begin
    if(RESET) begin
        for(j = 0; j <= 11; j = j + 1)
            acch[j] <= 0;
    end

    else begin
        acch[0] <= d[0] * H[0];
        acch[1] <= d[1] * H[1];
        acch[2] <= d[2] * H[2];
        acch[3] <= d[3] * H[3];
        acch[4] <= d[4] * H[4];
        acch[5] <= d[5] * H[5];
        acch[6] <= d[6] * H[6];
        acch[7] <= d[7] * H[7];
        acch[8] <= d[8] * H[8];
        acch[9] <= d[9] * H[9];
        acch[10] <= d[10] * H[10];
        acch[11] <= d[11] * H[11];
    end
end

/*multiply stage of LPF*/
always@(posedge CLK or posedge RESET) begin
    if(RESET) begin
        for(k = 0; k <= 11; k = k + 1)
            accl[k] <= 0;
    end

    else begin
        accl[0] <= d[0] * L[0];
        accl[1] <= d[1] * L[1];
        accl[2] <= d[2] * L[2];
        accl[3] <= d[3] * L[3];
        accl[4] <= d[4] * L[4];
        accl[5] <= d[5] * L[5];
        accl[6] <= d[6] * L[6];
        accl[7] <= d[7] * L[7];
        accl[8] <= d[8] * L[8];
        accl[9] <= d[9] * L[9];
        accl[10] <= d[10] * L[10];
        accl[11] <= d[11] * L[11];
    end
end

/*accumulate stage of HPF*/
always@(posedge CLK or posedge RESET) begin
    if(RESET) 
        X_DATA_TEMP <= 0;
    
    else
		X_DATA_TEMP <= (acch[0] + acch[1] + acch[2] + acch[3] + acch[4] + acch[5] + acch[6] + acch[7] + acch[8] + acch[9] + acch[10] + acch[11]);
end

always@(posedge CLK or posedge RESET) begin
    if(RESET) 
        X_DATA <= 0;
    
    else
		X_DATA <= (X_DATA_TEMP >> 9) + X_DATA_TEMP[8];
end

/*accumulate stage of LPF*/
always@(posedge CLK or posedge RESET) begin
    if(RESET) 
        Y_DATA_TEMP <= 0;
    
    else 
		Y_DATA_TEMP <= (accl[0] + accl[1] + accl[2] + accl[3] + accl[4] + accl[5] + accl[6] + accl[7] + accl[8] + accl[9] + accl[10] + accl[11]);
end

always@(posedge CLK or posedge RESET) begin
    if(RESET) 
        Y_DATA <= 0;
    
    else 
		Y_DATA <= (Y_DATA_TEMP >> 9) + Y_DATA_TEMP[8];
end

always@(posedge CLK or posedge RESET) begin
    if(RESET)
        OUT_VALID <= 0;
    
    else if(X_DATA_TEMP)
        OUT_VALID <= 1;
    
    else if(counter == 44)  //output ends
        OUT_VALID <= 0;
end

endmodule