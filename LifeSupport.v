//
//Decoder
//
module Dec(a,b);
	input a;
	output [1:0] b;
	assign b=1<<a;
endmodule
///
///DFF
///
module DFF(clk,in,out);
  parameter n=5;
  input  clk;
  input [n-1:0] in;
  output [n-1:0] out;
  reg  [n-1:0]  out;
  
  always @(posedge clk)//<--This is the statement that makes the circuit behave with TIME
  out = in;
 endmodule
//
//Mux2
//
module Mux2(a1, a0, s, b);
	parameter k=5;
	input [k-1:0] a1, a0;
	input [2-1:0] s;
	output [k-1:0] b;
		assign b=({k{s[1]}} &a1)|
				 ({k{s[0]}} & a0);
endmodule
//
//Mux4
//
module Mux4(a3, a2, a1, a0, s, b) ;
	parameter k = 1 ;//Three Bits Wide
	input [k-1:0] a3, a2, a1, a0 ;  // inputs
	input [3:0]   s ; // one-hot select
	output[k-1:0] b ;
	assign b = ({k{s[3]}} & a3) | 
               ({k{s[2]}} & a2) | 
               ({k{s[1]}} & a1) |
               ({k{s[0]}} & a0) ;
endmodule
//=============================================
// Saturation Counter
//=============================================
module SaturationCounter(clk, rst,pwr,shield, def, sth , temp, outshield, outtemp) ;
  parameter n = 5 ;
  
//---------------------------------------------
// Parameters
//---------------------------------------------
  input clk, rst, def, sth, pwr ;
  input [3:0] mode;
  input [n-1:0] shield, temp;
  output [n-1:0] outshield, outtemp;
  
//---------------------------------------------
// Local Variables
//---------------------------------------------  
  wire [n-1:0] nextTe, nextSh, outShield,outTemp,tempW,shieldW;
  
  

//---------------------------------------------  
// Main Counter Control
//--------------------------------------------- 
  
  assign outShield    =(def===1) ? outshield + 1 : outshield-1;
  assign outTemp  = ((temp  > outtemp)|(sth===1)) ? outtemp + 1 :outtemp - 1;
 
  assign tempW=temp;
  assign shieldW=shield;
  
  
  DFF #(n) Dtemp 	(clk, nextTe, outtemp); 
 
  
  Mux4 #(n) muxT(
	temp, 
	outtemp, 
	outTemp, 
	{n{1'b0}},
       {
		(rst),
        (pwr&~sth),
        (sth&~rst&pwr),
        (~pwr&~rst&~def&~sth)
		},
	nextTe) ;
		
	 DFF #(n) Dshield   (clk, nextSh, outshield) ;
	Mux4 #(n) muxS(
	shield,
	outshield,
	outShield, 
	{n{1'b0}},
        {
		(rst),
        (pwr&~def),
        (def&pwr&~rst),
        (~pwr&~rst&~def&~sth)
		},
	nextSh) ;
endmodule
//============================================= // Test Bench //=============================================
 module Test_Fsm1 ; 
parameter n = 5 ; 
reg clk, rst,def, sth, pwr;
reg	 [3:0] mode ; 
reg [n-1:0] shield, temp; 
wire [n-1:0]out; 

wire [n-1:0] outshield, outtemp ; 
SaturationCounter ls(clk, rst, pwr, shield, def, sth, temp, outshield, outtemp); // clock with period of 10 units
 initial 
 begin 
	 $display("CLK|RST|UP|DN|LD|LDMAX|IN|MAX|OUT");
	end
initial 
begin  clk=0;
clk = 1 ; 
forever 
begin 
#1
$display("%b %b %d |%d ",ls.nextTe, clk,outshield, outtemp);
#5 clk=0;
$display("%b %b %d |%d ", ls.nextTe, clk,outshield, outtemp);
#5 clk=1;

	

end 
end 

// input stimuli 
initial 
begin 
#10 
#10 pwr=0;def=0; sth=0; rst=1; temp=5'b11111; shield=5'b11000;
#10 pwr=1;def=1; sth=0; rst=0; 
#10 
#120
#10 pwr=0;def=0; sth=0;
#160 //appropriate time to count down
 
$finish; 
end
endmodule