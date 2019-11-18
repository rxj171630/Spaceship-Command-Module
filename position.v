`include "common.v"

`define X k-1:0
`define Y 2*k-1:k
`define Z 3*k-1:2*k

`define RESET   'b0001
`define ATTACK  'b0010
`define DEFENSE 'b0100
`define STEALTH 'b1000
`define JUMP   'b0100
`define NORMAL 'b0010


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
  
  `define STEALTH_OFFSET 2'b11
  `define DEFENSE_OFFSET 2'b10
  `define ATTACK_OFFSET 2'b01


  input [3:0] mode;
  input [k-1:0] speed;//default speed
  wire [k-1:0] velocity;//adjusted speed

  //Takes speed and applies offset based on mode
  wire [1:0] offset;

  // 4 bit one hot values for the multiplexer mode
  // 0001 is zero speed 
  // 0010 is the attack mode
  // 0100 is the defense mode
  // 1000 is the stealth mode
  // The output of the mode multiplexer would be the velocity associated with that mode
  Mux4 #(2) velocity_mux(`STEALTH_OFFSET, `DEFENSE_OFFSET, `ATTACK_OFFSET, 2'b00, mode, offset);

  assign velocity = speed / offset;



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
