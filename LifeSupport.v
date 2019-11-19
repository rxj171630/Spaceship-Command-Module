
module LifeSupport(clk, rst,pwr,shield, chrg,atk, o2, o2sup, mode, temp, outshield, outtemp, outpower, outo2, fatal) ;
  parameter n = 32 ;
  
//---------------------------------------------
// Parameters
//---------------------------------------------
  input clk, rst, chrg, o2sup, atk ;
  input [3:0] mode;
  input [n-1:0] shield, temp, pwr, o2;
  output [n-1:0] outshield, outtemp, outpower, outo2;
  output  fatal;
//---------------------------------------------
// Local Variables
//---------------------------------------------  
  wire [n-1:0] nextTe, nextSh, nextPwr, nextO2, outShield,outTemp, outPower,outDmg, outO2;
  
  wire on, def, sth	;
  
  assign def = (((~mode[3]&mode[2]&~mode[1]&~mode[0])===1)&(outpower>0))? 1: 0; 
  assign sth = (((mode[3]&~mode[2]&~mode[1]&~mode[0])===1)&(outpower>0))? 1: 0;
  

//---------------------------------------------  
// Main Counter Control
//--------------------------------------------- 
  
  assign outShield    	=((def===1)||(outshield<=100)) ? outshield + 1 : outshield-1;
  assign outDmg 		= (atk===1)? outshield - 5: outshield;
  assign outTemp  		= ((temp  > outtemp)||(sth===1)) ? outtemp + 1 :outtemp - 1;
  assign outPower 		= (chrg===1) ? outpower: outpower-1;
  assign outO2 			= ((o2sup===1)||(outo2===0)) ? outo2: outo2-1;
  assign fatal			=((outtemp<100)&&(outo2!=0))? 0: 1;
  
  
 
  DFF #(n) DO2 (clk, nextO2, outo2);
  Mux2 #(n) muxO2(
	o2, 	
	outO2, 
	
       {
		(o2sup),
        (!o2sup)
		},
	nextO2) ;
	
	   DFF #(n) DPwr (clk, nextPwr, outpower);
  Mux2 #(n) muxPwr(
	pwr, 
	outPower, 
	
       {
		(chrg),
        (!chrg)
		},
	nextPwr) ;
  
  
  DFF #(n) Dtemp 	(clk, nextTe, outtemp); 
 
  
  Mux4 #(n) muxT(
	temp, 
	outtemp, 
	outTemp, 
	{n{1'b0}},
       {
		(rst),
        (~sth&~rst),
        (sth&~rst),
        (~rst&~def&~sth)
		},
	nextTe) ;
		
		
			
	 DFF #(n) Dshield   (clk, nextSh, outshield) ;
	Mux4 #(n) muxS(
	shield,
	outshield,
	outShield, 
	outDmg,
        {
		(rst),
        (~def&~rst&~atk),
        (def&~rst&~atk),
        (atk)
		},
	nextSh) ;
endmodule
