module PositionTestBench();
  parameter k = 16;

  reg clk;
  reg [3:0] mode;
  reg [3:0] pos_mode;
  reg [k-1:0] jump_position_x = 'b1001001001;
  reg [k-1:0] jump_position_y = 'b1001001001;
  reg [k-1:0] jump_position_z = 'b1001001001;

  reg [k-1:0] x;
  reg [k-1:0] y;
  reg [k-1:0] z;

  Position #(k) position(clk, mode, pos_mode, {jump_position_x, jump_position_y, jump_position_z});

	//---------------------------------------------
	//The Display Thread with Clock Control
	//---------------------------------------------
	initial
		begin
		forever
			begin
				#5
				clk = 0;
				#5
				clk = 1;
			end
	end


  	//---------------------------------------------
	//The Display Thread with Clock Control
	//---------------------------------------------
	initial
		begin
		#1 ///Offset the Square Wave
		$display("CLK| x | y | z |");
		$display("---+---+---+---+");
		forever
			begin
				#10
				$display(" %b |%d|%d|%d|",clk, position.x, position.y, position.z);
			end
	end

	initial
		begin
			#2 //Offset the Square Wave
      #10 mode = 'b0001; pos_mode = 'b0001;
      #10 mode = 'b0010; pos_mode = 'b0010;
			#50
      #10 mode = 'b0010; pos_mode = 'b0100;
      #10 mode = 'b0010; pos_mode = 'b0010;
			#50

			$finish;
		end
endmodule

module WeaponsTestBench();
  reg clk;
  reg [3:0]mode_selector;
  reg [8:0]ammo;
  reg fire;
  wire error;
  weapons try(clk, mode_selector, ammo, fire, error);
  //============================================
  //Set initial values
  //============================================
  initial begin
  ammo = 500;
  mode_selector = 4'b0010;
  fire = 1;
  #200
  fire = 0; $display ("stop firing");
  #200;
  end
  //---------------------------------------------
  //The Display Thread with Clock Control
  //---------------------------------------------
    initial begin
  	  forever
  			begin
  					#5
  					clk = 0 ;
  					#5
  					clk = 1 ;
  			end
    end
endmodule

module LifeTestBench; 
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
