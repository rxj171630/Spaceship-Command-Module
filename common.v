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



//=============================================
// 2-Channel, 4-Bit Multiplexer
//=============================================

module Mux2(a1, a0, s, b) ;
	parameter k = 4 ;//Four Bits Wide
	input [k-1:0] a3, a2, a1, a0 ;  // inputs
	input [1:0]   s ; // one-hot select
	output[k-1:0] b ;
	assign b = ({k{s[1]}} & a1) |
             ({k{s[0]}} & a0) ;
endmodule