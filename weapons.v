`include "common.v"
//=============================================Saturation Counter=============================================

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




//=================================================
//Run Counter
//=================================================
module ammoCount(input clk, input [8:0]ammoIn, input load, input fire, input [8:0]fireRate);
reg rst, up;
reg [1:0]loadMax;
wire [8:0]ammoOut;
AmmoCounter sat(clk, rst, up, fire, load, loadMax, ammoIn, ammoOut, fireRate);
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

   //initial values
   initial
   	begin
       up = 0; rst = 0; loadMax = 01;
   	end
endmodule

module weapons(input clk, input [3:0]mode_selector, input [8:0]ammo, input loadingAmmo, input fire, input [8:0]fireRate, output error);
  wire mode;
  reg error;
  reg shoot;
  Mux4 #(1) selMode(1'b0, 1'b0, 1'b1, 1'b0, mode_selector, mode);  //0010 is attack mode
  ammoCount run(clk, ammo, loadingAmmo, shoot, fireRate);   //run the counter

  initial begin
  forever begin
  #5
    shoot = fire & !loadingAmmo;    //You can't shoot while you are reloading
    error = ((fire & (!mode)) | (fire & (!ammo)));  //Trying to shoot with no ammo or in the wrong mode is an error
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
  reg loadingAmmo;
  wire error;
  weapons try(clk, mode_selector, ammo, loadingAmmo, fire, fireRate, error);
  //============================================
  //Set initial values
  //============================================
  initial begin
  #11
  fire = 0; //down
  ammo = 500; //in
  #10
  loadingAmmo = 1;    $display("load into ammo reg"); //load
  mode_selector = 4'b0010;  //set mode to attack
  #10
  loadingAmmo = 0;  $display("done loading ammo"); //load
  fireRate = 5; //5 rounds per clock
  fire = 1; $display("start firing");
  #100
  loadingAmmo = 1; $display("Start loading"); //load
  #10
  ammo = 200; $display("load ammo"); //in
  #10
  loadingAmmo = 0;  $display("done loading"); //load
  fireRate = 1; //1 round per clock
  #200
  fire = 0; $display ("stop firing"); //down
  #200;
  $finish;
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
