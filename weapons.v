//=============================================Saturation Counter=============================================

//=============================================
// Saturation Counter
//=============================================
module SaturationCounter(clk, rst, up, down, load, loadMax, in, out, rate) ;
  parameter n = 9 ;

//---------------------------------------------
// Parameters
//---------------------------------------------
  input clk, rst, up, down, load;
  input [1:0] loadMax;
  input [n-1:0] in ;
  input [n-1:0] rate;
  output [n-1:0] out ;

//---------------------------------------------
// Local Variables
//---------------------------------------------
  wire [n-1:0] next, outpm1,outDown,outUp ;
  wire [n-1:0] max;
  wire [n-1:0] mux2out;
  wire [1:0] selectMax;

//---------------------------------------------
// Load Max Count
//---------------------------------------------

  Mux2 #(n) muxSat  (in    , max       , loadMax, mux2out);
  DFF  #(n) maxcount(clk    , mux2out  , max              ) ;

//---------------------------------------------
// Main Counter Control
//---------------------------------------------

  assign outUp    = (max> out) ? out + {{n-1{down}},1'b1} : max;
  assign outDown  = (0  < out) ? out - rate  : 0;
  assign outpm1   = ({down}>0)? {outDown} :{outUp};



  DFF #(n) count   (clk, next   , out) ;
  Mux4 #(n) mux(out, in, outpm1, {n{1'b0}},{(~rst & ~up & ~down & ~load),(~rst & load),(~rst & (up | down)),rst},next);

endmodule

//=============================================
// D Flip-Flop
//=============================================
module DFF(clk,in,out);

  input  clk;
  input  [8:0]in;
  output [8:0]out;
  reg    out;

  always @(posedge clk)//<--This is the statement that makes the circuit behave with TIME
  out = in;
 endmodule


 //=============================================
// 4-Channel, 4-Bit Multiplexer
//=============================================

module Mux4(a3, a2, a1, a0, s, b) ;
	parameter k = 4 ;//Four Bits Wide
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

//============================================================================================================

//========================================================
// 4-Channel, 1-Bit Multiplexer, used for determining mode
//========================================================

module Mux4_1(a3, a2, a1, a0, s, b) ;
 parameter k = 1 ;//1 Bit Wide
 input [k-1:0] a3, a2, a1, a0 ;  // inputs
 input [3:0]   s ; // one-hot select
 output[k-1:0] b ;
 assign b = ({k{s[3]}} & a3) |
              ({k{s[2]}} & a2) |
              ({k{s[1]}} & a1) |
              ({k{s[0]}} & a0) ;
endmodule


//=================================================
//Run Counter
//=================================================
module ammoCount(input clk, input [8:0]ammoIn, input fire, input [8:0]fireRate);
reg rst, up, load;
reg [1:0]loadMax;
wire [8:0]ammoOut;
SaturationCounter sat(clk, rst, up, fire, load, loadMax, ammoIn, ammoOut, fireRate);
//---------------------------------------------
//The Display Thread with Clock Control
//---------------------------------------------
   initial
    begin
	  #1 ///Offset the Square Wave
      $display("CLK|RST| UP|DOWN|LOAD|LOAD_MAX|   OUTPUT");
      $display("---+---+---+----+----+--------+-----------");
	  forever
			begin
			#5
			$display(" %1b | %1b | %1b |  %1b |  %1b |    %1b   |%5b [%d]",clk,rst,up,fire,load,loadMax[1],ammoOut,ammoOut);
			end
   end

   //Initial values and delay for output
   initial
   	begin
       up = 0; load = 1; rst = 0; loadMax = 01;
   	  #2 //Offset the Square Wave
       #5 load = 1; rst = 0;  $display("load into ammo reg");
       #5 load = 0;  $display("start firing");
       #300
   		$finish;
   	end
endmodule

module weapons(input clk, input [3:0]mode_selector, input [8:0]ammo, input fire, input [8:0]fireRate, output error);
  wire mode;
  reg error;
  Mux4_1 selMode(1'b0, 1'b0, 1'b1, 1'b0, mode_selector, mode);  //0010 is attack mode
  ammoCount run(clk, ammo, fire, fireRate);

  initial begin
  forever begin
  #5
    error = ((fire & (!mode)) | (fire & (!ammo)));
    $display("error: %b", error);
    end
  end

endmodule

module testBench();
  reg clk;
  reg [3:0]mode_selector;
  reg [8:0]ammo;
  reg fire;
  reg [8:0]fireRate;
  wire error;
  weapons try(clk, mode_selector, ammo, fire, fireRate, error);
  //============================================
  //Set initial values
  //============================================
  initial begin
  fire = 0;
  ammo = 500;
  mode_selector = 4'b0010;
  #12
  fire = 1;
  fireRate = 1;
  #200
  fire = 0; $display ("stop firing");
  #200;
  end
  //---------------------------------------------
  //The Display Thread with Clock Control
  //---------------------------------------------
  initial begin
  forever begin
      #5
      clk = 0 ;
      #5
      clk = 1 ;	
      end
    end
endmodule
