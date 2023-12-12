//------------------------------------------------------//
//- Digital IC Design 2023                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/10ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY);

//Parameter
parameter fp_latency = 3;

//I/O Ports
input         CLK;  //clock signal
input         RESET;  //sync. RESET = 1
input         ENABLE;  //input data sequence when ENABLE = 1
input   [7:0] DATA_IN;  //input data sequence
output  [7:0] DATA_OUT;  //ouput data sequence
output        READY;  //output data is READY when READY = 1

reg READY;
reg [4:0] counter_in;
reg [7:0] input_A [0:7];
reg [7:0] input_B [0:7];
reg in_data_rdy;
reg [7:0] output_Z [0:7];
reg [7:0] DATA_OUT;
reg [3:0] counter_out;

real real_A, real_B, real_Z;
integer fp_count;
integer i;

//Latch input data sequence
always@(posedge CLK) begin
   if(RESET) begin
      counter_in <= 0;
      in_data_rdy <= 1'b0;
      for(i=0; i <= 7; i=i+1) 
         input_A[i] <= 0;
      for(i=0; i <= 7; i=i+1) 
         input_B[i] <= 0;
   end 
   else if(ENABLE && (counter_in < 5'd8)) begin
      input_A[counter_in] <= DATA_IN;
      counter_in <= counter_in + 1'b1;
      in_data_rdy <= 1'b0;
   end 
   else if(ENABLE && (counter_in < 5'd15)) begin
      input_B[counter_in-8] <= DATA_IN;
      counter_in <= counter_in + 1'b1;
      in_data_rdy <= 1'b0;
   end 
   else if(ENABLE && !in_data_rdy) begin  //Last input received, in_data_rdy = 1
      input_B[counter_in-8] <= DATA_IN;
      in_data_rdy <= 1'b1;
   end 
   else if(counter_out == 4'd8) begin //When output is completed, in_data_rdy = 0;
      in_data_rdy <= 1'b0;
      counter_in <= 0;     
   end
end

//Convert double precision to real number
always@(RESET or in_data_rdy) begin
   if(RESET) begin
      real_A = 0.0;
      real_B = 0.0;
   end 
   else if(in_data_rdy) begin
      real_A = $bitstoreal({input_A[7], input_A[6], input_A[5], input_A[4],
                            input_A[3], input_A[2], input_A[1], input_A[0]});
      real_B = $bitstoreal({input_B[7], input_B[6], input_B[5], input_B[4],
                            input_B[3], input_B[2], input_B[1], input_B[0]});
   end
end

//Perform FP MUL operation
always@(real_A or real_B) begin
  real_Z = real_A * real_B;
  //Convert real number to double precision
  #2 {output_Z[7], output_Z[6], output_Z[5], output_Z[4], output_Z[3], output_Z[2], output_Z[1], output_Z[0]} = $realtobits(real_Z);  
end

//Output Control
always@(posedge CLK) begin
   if(RESET) begin
      fp_count <= 0;
      READY <= 0;
      DATA_OUT <= 0;
      counter_out <= 0;
   end 
   else if(in_data_rdy && (fp_count != fp_latency))
     fp_count <= fp_count + 1'b1;
   else if(in_data_rdy) begin  //input is ready
      if(counter_out < 4'd8) begin
         DATA_OUT <= output_Z[counter_out];
         counter_out <= counter_out + 1'b1;
         READY <= 1'b1;
      end 
      else
         READY <= 1'b0;
   end 
   else begin
     counter_out <= 0;
     fp_count <= 0;
   end
end

endmodule
