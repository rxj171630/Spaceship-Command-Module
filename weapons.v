//=============================================Saturation Counter=============================================
//`include "common.v"
//=============================================
// Saturation Counter
//=============================================
module AmmoCounter(clk, rst, up, down, load, loadMax, in, out, rate) ;
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

//==================================================================================================================

//----------------------------------------------
//Weapons Module
//----------------------------------------------

module weapons(input clk, input [3:0]mode, input [8:0]ammo, input loadingAmmo, input fire, input [8:0]fireRate, output [8:0]newAmmo, output error);
  wire mode_selector;
  wire error;
  wire shoot;
  wire newAmmo;
  Mux4 #(1) selMode(1'b0, 1'b0, 1'b1, 1'b0, mode, mode_selector);  //0010 is attack mode
  reg rst, up;
  reg [1:0]loadMax;
  wire [8:0]ammoOut;
  wire notLoad;
  wire notMode;
  wire arg1;
  wire arg2;
  wire notAmmo;
  AmmoCounter sat(clk, rst, up, shoot, loadingAmmo, loadMax, ammo, newAmmo, fireRate);

  initial begin
        //initial values
        up = 0; rst = 0; loadMax = 01;
  end
  not n1(notAmmo, ammo);
  not n2(notLoad, loadingAmmo);
  not n3(notMode, mode);
  and a1(shoot,fire,notLoad);    //You can't shoot while you are reloading
  and a2(arg1, fire, notMode);
  and a3(arg2, mode_selector, fire, notAmmo);
  or e1(error, arg1, arg2);  //Trying to shoot in the wrong mode is an error. Trying to shoot with no ammo in the right mode is an error.

endmodule
