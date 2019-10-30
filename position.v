//=============================================
// D Flip-Flop
//=============================================
module DFF(clk, in, out);

  input  clk; // The clock
  input  [15:0] in;  // The input D
  output [15:0] out; // The output Q
  reg    out;

  always @(posedge clk)//<--This is the statement that makes the circuit behave with TIME
  out = in; // The output is set to the same value of the input
endmodule


//=============================================
// 4-Channel, 2-Bit Multiplexer
//=============================================

module Mux4(a3, a2, a1, a0, s, b) ;
 parameter k = 3 ;//Three Bits Wide
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
module Axis_Position (input clk,  input [3:0] mode_selector, input [3:0] pos_selector);   
    reg [15:0] position;
    wire [15:0] position_out;
    // 4 bit one hot values for the multiplexer mode
    // 0001 is the reset 
    // 0010 is the attack mode
    // 0100 is the defense mode
    // 1000 is the stealth mode
    // The output of the mode multiplexer would be the velocity associated with that mode
    Mux_4 mode(stealth_speed, defense_speed, attack_speed, 16'b0, mode_selector, velocity_out);  // Add arbitary values for a1, a2 and a3

    Add_sub_rca16 V_adder(1'b0, velocity_out, position, 1'b0, c_out, adder_out); // The adder would ouput the next position in the normal case
    // 4 bit one hot values for the multiplexer position
    // 0001 is the reset 
    // 0010 is the normal result which is the sum of the previous position and current velocity/clk * clk = velocity
    // 0100 is the warp speed mode
    // 1000 is a dont care value and should never appear
    Mux_4 position(16'b1, warp_speed_value, adder_out, 16'b0, pos_selector, position_value);  // Set the warp speed to an arbitary large value // teleportation pretty much

    // Its gonna take the output of the position multiplexer
    DFF Q(clk, position_value, position_out);

    always @(*)
        begin
           position = position_out; 
        end
endmodule

module Spacial_Position(input clk, input [3:0] mode_selector, input [3:0] pos_selector, output [15:0] position_x_out, position_y_out, position_z_out);
    // Calculating 
    Axis_Position x(clk, mode_selector, pos_selector);
    Axis_Position y(clk, mode_selector, pos_selector);
    Axis_Position z(clk, mode_selector, pos_selector);
    always @(*)
        begin
            position_x_out = x.position;
            position_y_out = y.position;
            position_z_out = z.position;
        end
endmodule
