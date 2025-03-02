/*
	Brendan Dileo
	July 25 2024
	This was my second try at creating a mod menu using GSC. This script allows the player to enter god mode, refill ammo, etc.

	Credits / Help:
	@TheSkyeLord - Weapon Ports
	Link: https://www.ugx-mods.com/forum/full-weapons/84/skyes-weapon-ports-to-bo3-master-hub/16874/

	@pistakilla - Timer Help
	Link: https://github.com/pistakilla/t7-gsc-scripts/tree/main/zm_timer

	@Joshr520 - Reference for Zombie Timer
	Link: https://github.com/Joshr520/BO3-Autosplits

	@Cabcon - Starter File
	Link: https://cabconmodding.com/threads/black-ops-3-zombie-gsc-modding-how-to-start-coding-a-mod-startup-mod-download.2245/

	@IceGrenade - Tutorials
	Link: https://www.youtube.com/watch?v=1ahHTW4hhzk&list=PLrBAoFlW-blqmkmXLcHcZULdIhD6h_q9u&index=8
*/

#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\codescripts\struct;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perks; // Needed for perks
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_score; // Needed for timer

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_hud_message.gsc;

#namespace clientids;

REGISTER_SYSTEM( "clientids", &main, undefined )

// Main Function
function main() {
	callback::on_start_gametype( &main );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 
	callback::on_start_gametype( &initialize );

	level.clientid = 0;
}

// Connect Function
function on_player_connect() {
	self.clientid = matchRecordNewPlayer( self );
	if ( !isdefined( self.clientid ) || self.clientid == -1 )
	{
		self.clientid = level.clientid;
		level.clientid++;
	}
}

// Spawn Function
function on_player_spawned() {
	level flag::wait_till( "initial_blackscreen_passed" );
	thread giveCustomWeapon(self);
	thread modMenuControl(self);
	thread zm_text_display();
	thread zm_menu_instruction_display(); // 1st text part of menu
	thread zm_menu_instruction_display_two(); // 2nd text part of menu
}

// Initialization
function initialize() {
	level thread timer_init(); // Initializes timer
	level thread set_zombie_count(); // Initializes number of zombies shown in counter
}

// Function for giving player BO2 weapons. Credits to Skye's BO2 Weapon Pack
function giveCustomWeapon(player) {
	player giveWeapon(GetWeapon("t6_ballista")); // Ballista, not really working.
	IPrintLnBold("Ballista Given!");
	player giveWeapon(GetWeapon("t6_m27"));
	IPrintLnBold("M27 Given!");
	player giveWeapon(GetWeapon("t6_an-94")); // Does not work!
	IPrintLnBold("AN-94 Given!");

	// Extras. Not sure what I was doing wrong.

	// player giveWeapon(GetWeapon("t6_mauser_c96"));
	// player giveWeapon(GetWeapon("t6_msmc"));
	// player giveWeapon(GetWeapon("t6_peacekeeper"));
	// player giveWeapon(GetWeapon("t6_ksg"));
	// player giveWeapon(GetWeapon("t6_lsat"));
	// player giveWeapon(GetWeapon(""))
	// player giveWeapon(GetWeapon(""))
	// player giveWeapon(GetWeapon(""))
}

// Mod Menu Function
function modMenuControl(player) {
	IPrintLnBold("modMenuControl started");
	for (;;) {
		wait(0.1);
		if (player MeleeButtonPressed() && player JumpButtonPressed()) {
			giveRayGun(player);
			IPrintLnBold("Given Ray Gun!");
			wait(1);
		} else if (player MeleeButtonPressed() && player ReloadButtonPressed()) {
			giveGod();
			IPrintLnBold("God Mode Enabled!");
			wait(1);
		} else if (player MeleeButtonPressed() && player SprintButtonPressed()) {
			giveAllMapPerks(player);
			IPrintLnBold("Given All Map Perks!");
			wait(1);
		} else if (player MeleeButtonPressed() && player AdsButtonPressed()) {
			givePlayerPoints(player);
			givePlayersPoints_(999999);
			IPrintLnBold("Points Given!");
			wait(1);
		} else if (player MeleeButtonPressed() && player FragButtonPressed()) {
			giveRound100();
			IPrintLnBold("Going to Round 100!");
			wait(1);
		} else if (player JumpButtonPressed() && player ReloadButtonPressed()) {
			changeZombieHealth(1);
			IPrintLnBold("Zombie Health Changed!");
			wait(1);
		} else if (player SprintButtonPressed() && player FragButtonPressed()) {
			changeZombieSpeed();
			IPrintLnBold("Zombie Speed Changed!");
			wait(1);
		} else if (player JumpButtonPressed() && player FragButtonPressed()) {
			givePlayerAmmo(player);
			IPrintLnBold("Ammo Refilled!");
			wait(1);
		}
	}
}

// God Mode Function
function giveGod() { 
	self EnableInvulnerability();
	IPrintLn("God Mode Enabled!");
}

// Function that gives player the raygun
function giveRayGun(player) { // Gives Player Ray Gun.
	player giveWeapon(GetWeapon("ray_gun"));
}

// Function that gives players all the perks on the map
function giveAllMapPerks(player) { // Gives Player all map perks.
	array::thread_all(getplayers(), &zm_utility::give_player_all_perks);
}

// Round 100 function
function giveRound100() {
	level endon("game_ended");
	wait(1);
	zm_utility::zombie_goto_round(101); // Forked from 'zm_utility' file.
}

// Function responsible for changing the zombies health
function changeZombieHealth(starting_health) {
    zombies = GetAISpeciesArray("axis");
    foreach (z in zombies) {
        if (isDefined(z.animname) && z.animname == "zombie" && !isDefined(z.health_reset)) {
            z.health = starting_health;
            z.health_reset = true;
        }
    }
}

// Function that changes the speed of the zombies
function changeZombieSpeed() {
	if (level.gamedifficulty == 0) {
		level.zombie_move_speed = 71;
	} else {
		level.zombie_move_speed = 71;
	}
}

// Function that gives the player points ... Not working cant figure out why?
function givePlayerPoints(player) {
	level.player_points = 999999;
}

// Function that gives player max ammo
function givePlayerAmmo(player) {
	weapons = player GetWeaponsList(1);

	// Iterates over number of weapons
    for(x = 0; x < weapons.size; x++) {
        // Refills ammo
        if(player HasWeapon(weapons[x])) {
            player giveMaxAmmo(weapons[x]); // Forked
        }
    }
}

// Display Function 1 (For Mod Menu Display) From '_hud_message.gsc'
function zm_text_display() {
	level flag::wait_till("initial_blackscreen_passed");

	text_display = hud::createserverfontstring("objective", 1.25);
    text_display hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y );
    text_display setText("Drendos Menu");

	for(;;) {
		level waittill( "end_game" );
	}
}

// Display Function 2 (For Mod Menu Display) ... From '_hud_message.gsc'
function zm_menu_instruction_display() {
	level flag::wait_till("initial_blackscreen_passed");

	instruction_display = hud::createserverfontstring("objective", 1);
	instruction_display hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y + 25);
	instruction_display setText("Press 'Melee' & 'Jump' for Ray Gun\n" + 
		"Press 'Melee' & 'Reload' for God Mode\n" + 
		"Press 'Melee' & 'Sprint' for All Perks\n" + 
		"Press 'Melee' & 'ADS' for Points\n" + 
		"Press 'Melee' & 'Frag' for Round 100\n" + 
		"Press 'Jump' & 'Reload' to change Zombie Health\n");

	for(;;) {
		level waittill( "end_game" );
	}

}

// Display Function 2.5 (For Mod Menu Display) From '_hud_message.gsc'
function zm_menu_instruction_display_two() {

	instruction_display_2 = hud::createserverfontstring("objective", 1);
	instruction_display_2 hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y + 100);
	instruction_display_2 setText("Press 'Sprint' & 'Frag' to Change Zombie Speed\n" + 
		"Press 'Jump' & 'Frag' to Refill Ammo\n");

	for(;;) {
		level waittill( "end_game" );
	}
}

// Timer Initialization Function
function timer_init() {
	level.pos_x = -2;
    level.pos_y = 0;
	level.total_time = 0;

	level thread start_timer();
}

// Function that starts the game timer
function start_timer() { // Based off of the BO2 Reimagined Mod made by @Jbleezy, and the BO1 Remix by @5and5
	level flag::wait_till("initial_blackscreen_passed");

    hud_timer = hud::createserverfontstring("objective", 1.25);
    hud_timer hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y + 175);

    for (;;) {
        start_time = int(getTime() / 1000);
        hud_timer setTimerup(0);

        level waittill("end_game");

        end_time = int(getTime() / 1000);
        level.total_time = end_time - start_time;
    }
}

// Function that retreives the number of zombies
function get_zombie_count() {
	return zombie_utility::get_current_zombie_count(); // From 'zombie_utility'
}

// Function that displays the number of zombies onto the screen (hud)
function set_zombie_count() {
	level endon("game_ended");

	zm_count = hud::createserverfontstring("objective", 1.25);
	zm_count hud::setpoint("TOPRIGHT", "TOPRIGHT", level.pos_x, level.pos_y + 190);

	for(;;) {
		zm_left = level.zombie_total + get_zombie_count();
		zm_count SetValue(zm_left);
		wait(0.5);
	}
}
