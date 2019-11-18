`include "position.v"
`include "weapons.v"
`include "common.v"
//`include "LifeSupport.v"


module TestBench();
    parameter k = 32;
    
    reg clk;
    reg [3:0] mode;//one hot steath, defense, attack, no-op
    reg [3:0] pos_mode;// undef, jump, sublight, reset
    
    reg [3*k-1:0] jump_position;// in the form {X, Y, Z}
    reg [3*k-1:0] speed;// in the form {X, Y, Z}
  
    Velocity #(k) velocity(mode, speed);
    Position #(k) position(clk, mode, pos_mode, jump_position, {velocity.z, velocity.y, velocity.x});

    reg [8:0]ammo;
    reg fire;
    reg [8:0]fireRate;
    reg loadingAmmo;
    wire error;
    weapons try(clk, mode, ammo, loadingAmmo, fire, fireRate, error);



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
        $display("VELOCITY is in units/clock-tick");
        $display("");
		$display("CLK| MODE |P MODE| POS X | POS Y | POS Z | VEL X | VEL Y | VEL Z | FIREING | LOADING | AMMO COUNT | FIRE RATE | ERROR |");
		$display("---+------+------+-------+-------+-------+-------+-------+-------+---------+---------+------------+-----------+-------+");
		forever
			begin
				#10
				$display(" %b | %b | %b | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %b |",clk, mode, pos_mode, position.x, position.y, position.z, velocity.x, velocity.y, velocity.z, fire, loadingAmmo, ammo, fireRate, error);
			end
        $display("FIXME NEGATIVE NUMBERS!!!!!!!!!!!!!!!!!");

    end




	initial 
		begin
			#2 //Offset the Square Wave
            #10 mode = `RESET;  pos_mode = `RESET; fire = 0; ammo = 500; loadingAmmo = 1;
            #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = 1; speed[`Y] = 1; speed[`Z] = 1; loadingAmmo = 0; fireRate = 2; fire = 1;
			#50
            #10 mode = `ATTACK; pos_mode = `JUMP;   jump_position[`X] = 100; jump_position[`Y] = 100; jump_position[`Z] = 100; loadingAmmo = 1; ammo = 200;
            #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = 4; speed[`Y] = 4; speed[`Z] = 4; loadingAmmo = 0; fireRate = 1;
			#100
            #10 fire = 0;
            #20

            
			$finish;
		end


endmodule