//=============================================
// D Flip-Flop
//=============================================
module DFF(clk,in,out);
	parameter k = 16;

  input  clk;
	input  [k-1:0] in;
	output [k-1:0] out;
	reg    [k-1:0] out;

  always @(posedge clk)//<--This is the statement that makes the circuit behave with TIME
  out = in;
endmodule


//=============================================
// 4-Channel, 2-Bit Multiplexer
//=============================================

module Mux4(a3, a2, a1, a0, s, b) ;
  parameter k = 16;//number of bits
  input [k-1:0] a3, a2, a1, a0 ;  // inputs
  input [3:0]   s ; // one-hot select
  output[k-1:0] b ;
  assign b = ({k{s[3]}} & a3) |
             ({k{s[2]}} & a2) |
             ({k{s[1]}} & a1) |
             ({k{s[0]}} & a0) ;
endmodule

/*
  This is the module for implementing the half adder with two inputs
  a and b as well as two outpus c_out (out carry) and sum
*/
module Half_Adder (input a, b, output c_out, sum);
  //Using XOR gate to produce the sum
  xor G1(sum, a, b);
  //Using AND gate to generate the carry output
  and G2(c_out, a, b );  // This is the carry output generated for the program
endmodule

/*
  This is the module for implementing the full adder. We have three inputs, a and b
  as well as the carry in c_in and two outputs, c_out (outcarry) and sum
*/
module Full_Adder (input a, b, c_in, output c_out, sum);
  wire w1, w2, w3;   // Wires used to store outputs

  //Using two half adders and an OR gates for a full adder
  Half_Adder M1 (a, b, w1, w2);
  Half_Adder M2 (w2, c_in, w3, sum);
  or (c_out, w1, w3);

endmodule

//This is the 4 bit adder-subtractor for the circuit
module Add_sub_rca4 (input Mode, input [3:0] a, b, input c_in, output c_out, output [3:0] sum);

  //Wires for storing bits
  wire c_in1, c_in2, c_in3, c_in4;
  wire x_0, x_1, x_2, x_3;
  // If the mode is subtraction(1), we would basically invert the bits in B using XOR.
  xor X1(x_0,Mode,b[0]);
  xor X1(x_1,Mode,b[1]);
  xor X2(x_2,Mode,b[2]);
  xor X3(x_3,Mode,b[3]);

  //We are calling the 4 adders to display the proper result
  Full_Adder M0 (a[0], x_0, c_in, c_in1, sum[0]);
  Full_Adder M1 (a[1], x_1, c_in1, c_in2, sum[1]);
  Full_Adder M2 (a[2], x_2, c_in2, c_in3, sum[2]);
  Full_Adder M3 (a[3], x_3, c_in3, c_out, sum[3]);
endmodule

module Add_sub_rca16 (input Mode, input [15:0] a, b, input c_in, output c_out, output [15:0] sum);

  //Wires for storing bits
  wire c_in1, c_in2, c_in3, c_in4;

  //We are calling the 4 adders to display the proper result
  Add_sub_rca4 M0 (Mode, a[3:0], b[3:0], c_in, c_in1, sum[3:0]);//1st 4 bits
  Add_sub_rca4 M1 (Mode, a[7:4], b[7:4], c_in1, c_in2, sum[7:4]);//2nd 4 bits
  Add_sub_rca4 M2 (Mode, a[11:8], b[11:8], c_in2, c_in3, sum[11:8]);//3rd 4 bits
  Add_sub_rca4 M3 (Mode, a[15:12], b[15:12], c_in3, c_out, sum[15:12]);//4th 4 bits
endmodule


//This is the module for calculating the position in a single axis
module Axis_Position (clk, mode, pos_mode, jump_position);   

  parameter k = 16;
  parameter [k-1:0] ATTACK_SPEED = {{k-1{1'b0}},1'b1};  // speed when mode is attack
  parameter [k-1:0] STEALTH_SPEED = {{k-1{1'b0}},1'b1}; // speed when mode is steath
  parameter [k-1:0] DEFENSE_SPEED = {{k-1{1'b0}},1'b1}; // speed when mode is defense
  
  input clk;
  input [3:0] mode;
  input [3:0] pos_mode; 
  input [k-1:0] jump_position; // position to jump to

  wire [k-1:0] position, next_position;
  wire [k-1:0] adder_out;
  wire [k-1:0] velocity_out;

  // 4 bit one hot values for the multiplexer mode
  // 0001 is the reset 
  // 0010 is the attack mode
  // 0100 is the defense mode
  // 1000 is the stealth mode
  // The output of the mode multiplexer would be the velocity associated with that mode
  Mux4 mode_mux(STEALTH_SPEED, DEFENSE_SPEED, ATTACK_SPEED, 16'b0, mode, velocity_out);  // Add arbitary values for a1, a2 and a3

  Add_sub_rca16 V_adder(1'b0, velocity_out, position, 1'b0, c_out, adder_out); // The adder would ouput the next position in the normal case

  // 4 bit one hot values for the multiplexer position
  // 0001 is the reset 
  // 0010 is the sublight which is the sum of the current position and velocity
  // 0100 is the jump mode
  // 1000 is a dont care value and should never appear
  Mux4 position_mux({{k-1{1'b0}},1'b1}, jump_position, adder_out, {k{1'b0}}, pos_mode, next_position);  // Set the warp speed to an arbitary large value // teleportation pretty much

  // Its gonna take the output of the position multiplexer
  DFF #(k) Q(clk, next_position, position);

endmodule

module Position(input clk, input [3:0] mode_selector, input [3:0] pos_mode);
    parameter k = 16;
    reg [k-1:0] x, y, z;
    
    // Calculating 
    Axis_Position #(k) x_pos(clk, mode_selector, pos_mode, 16'b1001001001);
    Axis_Position #(k) y_pos(clk, mode_selector, pos_mode, 16'b1001001001);
    Axis_Position #(k) z_pos(clk, mode_selector, pos_mode, 16'b1001001001);
    always @(*)
        begin
            x = x_pos.position;
            y = y_pos.position;
            z = z_pos.position;
        end
endmodule


module TestBench();


endmodule