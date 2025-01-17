//horizontal speed variables 
hsp = 0; //current horizontal speed
max_hsp = 3; //the max horizontal speed you go
walksp = 0.7; //how fast the player goes
runsp = 1.3; // how fast you can go while running

//friction
friction_ = 0.2; //this slows you down if you're not moving

//vertical speed variables
vsp = 0; //current vertical speed
vsp_max = 9; //max speed when falling
vspjump = -6.5; //how high the player jumps
canjump = 0; //are we touching the ground?
global.grv = 0.3; //gravity

//dash variables
candash = false; //resets when touching ground
dashdistance = 82; // how far the dash goes
dashdist = 1.3; 
dashtime = 10; // the amount of time the dash is used

//shoot variables
global.ammo = 0; //how much ammo the boy has
shootdelay = 0; // the cooldown of shooting the balls
shootdelaymax = 7; // the amount for the cooldown

//health variables
global.HP = 1; //how much health the player has
HP_max_boy = 2; //max health of boy

tears = 0; //crying particles
invincibility = false; //if you got hit or not and gives you iframes
invincible_timer = room_speed*1.5; //how long the iframes last
blinktimer = invincible_timer; //the player flashes white when hit
slime_splat = 0; //used when you die and game over screen

stateFree = function(){
	if(global.HP <= 0){
		state = stateDead;	
		slime_splat = 0;
	}
	#region movement
	shootdelay = max(shootdelay - 1,0);
		//horizontal movement
		var move = right - left;
		if (move !=0){
			if (!run){
				hsp += move*walksp;
				max_hsp = 3;
			}else{
				hsp += move*runsp*0.2;
				max_hsp = 5.5;
			}
			hsp = clamp(hsp,-max_hsp,max_hsp);
		}else{
			if(image_xscale = 1){
				if(hsp < 0.1){
					hsp = 0;	
				}
			}
			if(image_xscale = -1){
				if(hsp > -0.1){
					hsp = 0;	
				}
			}
			hsp = lerp(hsp,0,friction_);
		}
	
	vsp += global.grv;
	vsp = clamp(vsp,-vsp_max,vsp_max);
	
	//jump
	if (canjump -- > 0) && (jump){
		vsp = vspjump;
		canjump = 0;
	}
	//shoot inputs
	if(object_index = Obj_boy){
		if(place_meeting(x,y,Obj_paper)){
				global.ammo += 1;
		}
	}
	
	if(global.ammo > 0){
		if(shootdelay == 0){
			if(shoot){
				instance_create_layer(x,y,"Player",Obj_paperball);
				shootdelay = shootdelaymax;
			}
		}
	}
	
	//dash input
	if(object_index = Obj_slime){
		if (inputs) && (candash) && (dash){
			candash = false;
			canjump = 0;
			var move = right - left;
			if (move !=0){
				if (!run){
					hsp += move*walksp;
					max_hsp = 3;
				}else{
					hsp += move*runsp;
					max_hsp = 5;
				}
			}
			dashdirection = point_direction(0,0, right-left,down-up);
			if(!run){
				dashdistance = 82;
				dashsp = dashdistance/dashtime;
			}else{
				dashdistance = 82*dashdist;
				dashsp = dashdistance/dashtime
			}
			dashenergy = dashdistance;
			state = statedash;
		}
	}

	//run animation
	if (run){
		image_speed = 2;	
	}
	#endregion
	#region collisions
	//making you move while on the platform
	
	
	
	//horizontal collision
	if (place_meeting(x+hsp,y,Obj_solid)){
		while(abs(hsp) > 0.1){
			hsp *= 0.5;
			if(!place_meeting(x+hsp,y,Obj_solid)) x += hsp;
		}
		hsp = 0;
	}

	//vertical collision
	if (place_meeting(x,y+vsp,Obj_solid)){
		if(vsp>0){
			candash = true;
			canjump = 7;
		}
		while (abs(vsp) > 0.1){
			vsp *= 0.5;
			if(!place_meeting(x,y+vsp,Obj_solid)) y += vsp
			var _moveplat = instance_place(x,y+1,Obj_moveplat);
			if(_moveplat != noone){
					
			}
		}
		vsp = 0;
	}
	x += hsp; 
	y += vsp;
	#endregion

}
statedash = function(){
	#region dashing
	//move while dashing
		var move = right - left;
		if (move !=0){
			if (!run){
				hsp += move*walksp;
				max_hsp = 3;
			}else{
				hsp += move*runsp;
				max_hsp = 5;
			}
		}
		//move via the dash
		hsp = lengthdir_x(dashsp,dashdirection);
		vsp = lengthdir_y(dashsp,dashdirection);
	
		//trail effect
		with (instance_create_depth(x,y,depth+1,Obj_trail)){
			sprite_index = other.sprite_index;
			image_blend = #09E444;
			image_alpha = 0.9;
		}
		//horizontal collision 
		if (place_meeting(x+hsp,y,Obj_solid)){
			while(abs(hsp) > 0.1){
				hsp *= 0.5;
				if(!place_meeting(x+hsp,y,Obj_solid)) x +=hsp;
			}
			hsp = 0;
		}
		x += hsp; 

		//vertical collision
		if (place_meeting(x,y+vsp,Obj_solid)){
			while (abs(vsp) > 0.1){
				vsp *= 0.5;
				if(!place_meeting(x,y+vsp,Obj_solid)) y += vsp
			}
			vsp = 0;
		}
		y += vsp;
	
		//ending the dash
		dashenergy -= dashsp;
		if (dashenergy <= 0){
			vsp = 0;
			hsp = 0;
			state = stateFree;
		}
	#endregion
}
stateDead = function(){
	hsp = 0;
	vsp = 0;
	//cause of splatter
	if(slime_splat <= 0){
		image_alpha = 0;
		repeat(15){
			instance_create_layer(x,y,"Behind",Obj_slimesplatter);
		}
		slime_splat = 1;
	}
	Obj_game.timer--;
	
}
state = stateFree;