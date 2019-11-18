`define X k-1:0
`define Y 2*k-1:k
`define Z 3*k-1:2*k

`define RESET   'b0001
`define ATTACK  'b0010
`define DEFENSE 'b0100
`define STEALTH 'b1000
`define JUMP   'b0100
`define NORMAL 'b0010


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



//Adder Module
module Adder(a, b, out);
  parameter k = 16;

  input [k-1:0] a;
  input [k-1:0] b;
  output [k-1:0] out;

  assign out = a + b;
endmodule

//This is the module for calculating the position in a single axis
module Axis_Position (clk, pos_mode, jump_position, velocity);   

  parameter k = 16;
  
  input clk;
  input [3:0] pos_mode; 
  input [k-1:0] jump_position; // position to jump to
  input [k-1:0] velocity;

  wire [k-1:0] position, next_position;
  wire [k-1:0] adder_out;
  
  // The adder would ouput the next position in the normal case
  Adder #(k) add(position, velocity, adder_out);

  // 4 bit one hot values for the multiplexer position
  // 0001 is the reset 
  // 0010 is the sublight which is the sum of the current position and velocity
  // 0100 is the jump mode
  // 1000 is a do nothing SHOULDNT EVER HAPPEN USE ZERO VELOCITY INSTEAD
  Mux4 #(k) position_mux(position, jump_position, adder_out, {k{1'b0}}, pos_mode, next_position);  // Set the warp speed to an arbitary large value // teleportation pretty much

  // Its gonna take the output of the position multiplexer
  DFF #(k) Q(clk, next_position, position);

endmodule

module Position(clk, mode, pos_mode, jump_position, velocity);
  parameter k = 16;

  input clk;
  input [3:0] mode;
  input [3:0] pos_mode;
  input [3*k-1:0] jump_position;// in the form {X, Y, Z}
  input [3*k-1:0] velocity;// in the form {X, Y, Z}

  reg [k-1:0] x;
  reg [k-1:0] y;
  reg [k-1:0] z;
  
  // Calculating 
  Axis_Position #(k) x_pos(clk, pos_mode, jump_position[`X], velocity[`X]);//Calulates x positon
  Axis_Position #(k) y_pos(clk, pos_mode, jump_position[`Y], velocity[`Y]);//Calculates y position
  Axis_Position #(k) z_pos(clk, pos_mode, jump_position[`Z], velocity[`Z]);//Calulates z position
  always @(*)
      begin
          x = x_pos.position;
          y = y_pos.position;
          z = z_pos.position;
      end
endmodule

module Axis_Velocity(mode, speed);
  parameter k = 16;
  
  `define STEALTH_OFFSET 3
  `define DEFENSE_OFFSET 2
  `define ATTACK_OFFSET 1


  input [3:0] mode;
  input [k-1:0] speed;//default speed
  wire [k-1:0] velocity;//adjusted speed

  //Takes speed and applies offset based on mode
  wire [k-1:0] stealth_speed, defense_speed, attack_speed;
  assign stealth_speed = speed / `STEALTH_OFFSET;
  assign defense_speed = speed / `DEFENSE_OFFSET;
  assign attack_speed = speed / `ATTACK_OFFSET;

  // 4 bit one hot values for the multiplexer mode
  // 0001 is zero speed 
  // 0010 is the attack mode
  // 0100 is the defense mode
  // 1000 is the stealth mode
  // The output of the mode multiplexer would be the velocity associated with that mode
  Mux4 #(k) velocity_mux(stealth_speed, defense_speed, attack_speed, {k{1'b0}}, mode, velocity);  // Add arbitary values for a1, a2 and a3

endmodule

module Velocity(mode, speed);
  parameter k = 16;

  input [3:0] mode;
  input [3*k-1:0] speed;//in the form {XSPEED, YSPEED, ZSPEED}
  reg [k-1:0] x, y, z;  


  Axis_Velocity #(k) x_vel(mode, speed[`X]);
  Axis_Velocity #(k) y_vel(mode, speed[`Y]);
  Axis_Velocity #(k) z_vel(mode, speed[`Z]);
  always @(*)
  begin
    x = x_vel.velocity;
    y = y_vel.velocity;
    z = z_vel.velocity;
  end
endmodule

module TestBench();
  parameter k = 32;


  reg clk;
  reg [3:0] mode;//one hot steath, defense, attack, no-op
  reg [3:0] pos_mode;// undef, jump, sublight, reset
  
  reg [3*k-1:0] jump_position;// in the form {X, Y, Z}
  reg [3*k-1:0] speed;// in the form {X, Y, Z}
  
  Velocity #(k) velocity(mode, speed);
  Position #(k) position(clk, mode, pos_mode, jump_position, {velocity.z, velocity.y, velocity.x});

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
    $display("CLK - The clock signal");
    $display("MODE - 4 bit one hot, 0001 - OFF, 0010 - ATTACK, 0100 - DEFENSE, 1000 - STEALTH");
    $display("P MODE - 4 bit one hot, 0001 - reset positon, 0010 - NORMAL SUBLIGHT, 0100 - JUMP DRIVE, 1000 - NO CHANGE");
    $display("VELOCITY IS IN UNITS/CLOCK TICK");
    $display("");
		$display("CLK| MODE |P MODE| pos x | pos y | pos z | vel x | vel y | vel z |");
		$display("---+------+------+-------+-------+-------+-------+-------+-------+");
		forever
			begin
				#10
				$display(" %b | %b | %b | %d | %d | %d | %d | %d | %d |",clk, mode, pos_mode, position.x, position.y, position.z, velocity.x, velocity.y, velocity.z);
			end
	end	



	initial 
		begin
			#2 //Offset the Square Wave
      #10 mode = `RESET;  pos_mode = `RESET;
      #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = 1; speed[`Y] = 1; speed[`Z] = 1;
			#50
      #10 mode = `ATTACK; pos_mode = `JUMP;   jump_position[`X] = 100; jump_position[`Y] = 100; jump_position[`Z] = 100;
      #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = -4; speed[`Y] = 4; speed[`Z] = 4;
			#100
			
			$finish;
		end


endmodule