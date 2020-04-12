// Script for test-ship. Go to circular 80km orbit. 

function SetInclination {
	parameter _Incl_0.		// Starting inclination
	parameter _Incl_1.		// Desired inclination
	parameter _Alt_0.		// Starting Alt for inclination change
	parameter _Alt_1.		// Desired altitude for desired inclination

	declare local _AltReach to (Altitude - _Alt_0) / (_Alt_1 - _Alt_0). // 0..1 
	declare local _Incl to _Incl_0 + _AltReach * (_Incl_1 - _Incl_0).  // Inclination to return 

	return _Incl. // Current inclination for steering
}

function AscProfile {
	parameter profile_list.
	parameter target_apo.

	set profile_line to 0.
	set profile_col_num to 3.
	set last_line to (profile_list:length / profile_col_num - 1).

	set alt_col to 0.
	set incl_col to 1.
	set throt_col to 2.

	when Altitude >= profile_list[alt_col + (profile_line + 1) * profile_col_num] then {
			set profile_line to profile_line + 1.
			if (last_line - profile_line) > 0 {
				return true.	
			} else {
				return false.
			}
	}

	when profile_list[incl_col + (profile_line + 1) * profile_col_num] = 0 then {
		lock Steering to Prograde.
		return false.
	}

	lock Steering to Heading(90,SetInclination(
		profile_list[incl_col + (profile_line + 0) * profile_col_num],	// _Incl_0
		profile_list[incl_col + (profile_line + 1) * profile_col_num],	// _Incl_1
		profile_list[alt_col + (profile_line + 0) * profile_col_num],	// _Alt_0
		profile_list[alt_col + (profile_line + 1) * profile_col_num])	// _Alt_1
	).

	lock dApo to round(target_apo - apoapsis,0).
	lock Throttle to min(
		profile_list[throt_col + profile_line * profile_col_num],
		max(dApo / 10000, 0)
	).
	
	Stage.
	clearscreen.
	until Altitude >= 70000 {
		print "dApo : " + dApo at (0,1).
		print "Steering : " + Steering at (0,2).
		print "Throttle : " + Throttle at (0,3).
		wait 0.
	}

	unlock all.
	lock Throttle to 0.
	lock Steering to prograde.

	print "Ascent script completed." at (0,1).
	WAIT_VISUAL(5,0,0).
}

//=======================================MAIN=========================================

runpath("1:/libs.ks").
clearscreen.

// set target vessel

//set target_Vess to vessel("Siwise's Capsule").
//set target to target_Vess.

// wait for launch window: to be ahead of target with 10 degr phase angle

//set target_PhaseAng to 0.
//set vel_grad to 360 / target_Vess:orbit:period. // angular speed of target 
//set TTO_angular to 322 * vel_grad. // Time to orbit - 5 minutes - in relative target angular speed
//set startBurnErr to 0.00002. // Error tolerance for ISH
//
//if (target_PhaseAng - TTO_angular) < 0 { // расчет фазового угла для запуска
//	set phaseAngStartBurn to 360 + (target_PhaseAng - TTO_angular). 
//} else {
//	set phaseAngStartBurn to (target_PhaseAng - TTO_angular).
//}
//
//until ISH(phaseAngStartBurn,PHASEANGLE_TO_VESS(target_Vess:name),startBurnErr) {
//	print "TTO_angular: " + TTO_angular at (0,1).
//	print "Target angular velocity: " + vel_grad at (0,2).
//	print "Phase angle to launch: " + phaseAngStartBurn at (0,3).
//	print "Actual phase angle to " + target_Vess:name + " : " + PHASEANGLE_TO_VESS(target_Vess:name) at (0,4).
//	wait 0.
//}

// Launch!

set ascent_profile to list (
	//up to ALT,	INCLINATION,	THROT
	0,				90,				1.0,
	8000,			85,				1.0,
	10000,			80,				1.0,
	15000,			45,				1.0,
	30000,			45,				1.0,
	90000,			0,				1.0
).

when Maxthrust < 0.001 then {	//Stage_dirty - to refactor
	print "Dirty stage." at (0,0).
	stage.
	wait 0.1.
	return true.
}

when Altitude > 70000 then {	//Activate antenna - REFACTOR - make function to activate antennas
	Toggle Brakes.
}

AscProfile(ascent_profile, 80000).
CIRC_MNV().

print "Script execution completed." AT (0,9).
lock steering to prograde.
WAIT_VISUAL(5,0,0).