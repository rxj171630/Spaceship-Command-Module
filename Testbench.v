`include "position.v"
`include "weapons.v"
`include "common.v"
`include "LifeSupport.v"


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
    wire [8:0]newAmmo;
    reg loadingAmmo;
    wire error;
    weapons try(clk, mode, ammo, loadingAmmo, fire, fireRate, newAmmo, error);

    reg rst, chrg, o2sup,atk;
    reg [k-1:0] shield, temp, pwr, o2;
    wire fatal;
    wire [k-1:0] outshield, outtemp, outpower, outo2 ;

    LifeSupport ls(clk, rst,pwr,shield, chrg,atk, o2, o2sup, mode, temp, outshield, outtemp, outpower, outo2, fatal);
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
        $display("FIRING - 1 bit - Are the weapons being fired?");
        $display("RELOAD - 1 bit - Are we reloading the ammo? Automatically stops firing when reloading");
        $display("AMMO COUNT - 9-bit - How much ammo is loaded? Max capacity is 511 rounds");
        $display("POWER - 32-bit - How much power do we have? At 0, no life support subsystems will be responding.");
		$display("TEMP - 32-bit - What is our current temperature?");
		$display("SHIELD - 32-bit - How much shielding do we have?");
		$display("OXYGEN - 32-bit - How much oxygen do we have left?");
		$display("FATAL ERROR - 32-bit - Is the crew dead if the temperature reaches above 100 or runs out of oxygen?");
        $display("");
    $display("  Global  ||              Positioning Systems                     ||                  Weapons Systems                 ||                Life Support                  |");
    $display("----------||------------------------------------------------------||--------------------------------------------------||----------------------------------------------|");
    $display("CLK| MODE ||P MODE| POS X | POS Y | POS Z | VEL X | VEL Y | VEL Z || FIRING | RELOAD | AMMO COUNT | FIRE RATE | ERROR || POWER | TEMP | SHIELD | OXYGEN | FATAL ERROR |");
	$display("---+------++------+-------+-------+-------+-------+-------+-------++--------+--------+------------+-----------+-------++-------+------+--------+--------+-------------+");
		forever
			begin
				#10
				$display(" %b | %b || %b | %5d | %5d | %5d | %5d | %5d | %5d ||    %d   |    %d   |     %d    |    %d    |   %b   ||%7d|%6d|%8d|%8d|%13b|",clk, mode, pos_mode, position.x, position.y, position.z, velocity.x, velocity.y, velocity.z, fire, loadingAmmo, newAmmo, fireRate, error,outpower, outtemp, outshield, outo2, fatal);
			end
        $display("FIXME NEGATIVE NUMBERS!!!!!!!!!!!!!!!!!");

    end




	initial
		begin
			#2 //Offset the Square Wave
            #10 mode = `RESET;  pos_mode = `RESET; fire = 0; ammo = 500; loadingAmmo = 1; pwr=7'b1111111; temp=7'b100010; shield=7'b1100100; o2=8'b11111111; o2sup=1; atk=0; chrg=1; rst=1;
            #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = 1; speed[`Y] = 1; speed[`Z] = 1; loadingAmmo = 0; fireRate = 2; fire = 1; chrg=0; rst=0; o2sup=0;
			#50
            #10 mode = `ATTACK; pos_mode = `JUMP;   jump_position[`X] = 100; jump_position[`Y] = 100; jump_position[`Z] = 100; loadingAmmo = 1; ammo = 200;
            #10 mode = `ATTACK; pos_mode = `NORMAL; speed[`X] = 4; speed[`Y] = 4; speed[`Z] = 4; loadingAmmo = 0; fireRate = 1;
			#100
            #10 fire = 0;
            #20	atk=1;
			#400 mode= `STEALTH;
			#400
			#300
			$finish;
		end


endmodule
