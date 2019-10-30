//=============================================
// D Flip-Flop
//=============================================
module DFF(clk,in,out);

input  clk; // The clock
input  in;  // The input D
output out; // The output Q
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
module Add_half (input a, b, output c_out, sum);
  //Using XOR gate to produce the sum
  xor G1(sum, a, b);
  //Using AND gate to generate the carry output
  and G2(c_out, a, b );  // This is the carry output generated for the program
endmodule

/*
  This is the module for implementing the full adder. We have three inputs, a and b
  as well as the carry in c_in and two outputs, c_out (outcarry) and sum
*/
module Add_full (input a, b, c_in, output c_out, sum);
  wire w1, w2, w3;   // Wires used to store outputs

  //Using two half adders and an OR gates for a full adder
  Add_half M1 (a, b, w1, w2);
  Add_half M2 (w2, c_in, w3, sum);
  or (c_out, w1, w3);

<<<<<<< HEAD
endmodule

//This contains 
module Axis_Position ();
endmodule

module Spacial_Position();
    Axis_Position x();
    Axis_Position y();
    Axis_Position z();
endmodule
=======
endmodule
>>>>>>> c5ec5600be539b1091c1c0a6f52aa90ab0f8a60d
