// Ascend ship to target orbit

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
	set proflie_col_num to 3.
	set last_line to (profile_list:length / proflie_col_num - 1).

	set alt_col to 0.
	set incl_col to 1.
	set throt_col to 2.

	local lock dApo to abs(apoapsis - target_apo).

	when Altitude >= profile_list[alt_col + (profile_line + 1) * proflie_col_num] then {
			set profile_line to profile_line + 1.
			if (last_line - profile_line) > 0 {
				return true.	
			} else {
				return false.
			}
	}

	when profile_list[incl_col + (profile_line + 1) * proflie_col_num] = 0 then {
		lock Steering to Prograde.
		return false.
	}

	lock Steering to Heading(90,SetInclination(
		profile_list[incl_col + (profile_line + 0) * proflie_col_num],	// _Incl_0
		profile_list[incl_col + (profile_line + 1) * proflie_col_num],	// _Incl_1
		profile_list[alt_col + (profile_line + 0) * proflie_col_num],	// _Alt_0
		profile_list[alt_col + (profile_line + 1) * proflie_col_num])	// _Alt_1
	).


	lock Throttle to min(profile_list[throt_col + profile_line * proflie_col_num], max(dApo / (target_apo * 0.05), 0.1)).
	
	Stage.
	
	clearscreen.
	until apoapsis > target_apo {
		
		set ThrIsp to ENGTHRUSTISP().				// EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
		set AThr to ThrIsp[0]*Throttle/(ship:mass).	// Ускорение, которое сообщают ракете активные двигатели при тек. массе.

		wait 0.
	}.

	lock Throttle to 0.
	lock Steering to prograde.
	
	wait 1.
}

//=======================================MAIN=========================================

runpath("1:/libs.ks").

SET ascent_profile TO LIST (
	//up to ALT,	INCLINATION,	THROT
	0,				90,				1.0,
	8000,			90,				1.0,
	10000,			80,				1.0,
	15000,			70,				1.0,
	20000,			45,				1.0,
	90000,			0,				1.0
).

when Maxthrust < 0.001 then {	//Stage_dirty - to refactor
	stage.
	return true.
}

when Altitude > 60000 then {	//Activate antenna - REFACTOR - make function to activate antennas
	Toggle Brakes.
}

AscProfile(ascent_profile, 81000).
CIRC_MNV().

print "Script execution completed." AT (0,9).
lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
WAIT_VISUAL(20,0,0).