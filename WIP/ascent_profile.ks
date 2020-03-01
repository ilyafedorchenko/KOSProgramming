//

FUNCTION EXEC_ASC_PROFILE {
	PARAMETER profile_list.
	PARAMETER target_APO.

	SET profile_line TO 0.
	SET proflie_col_num TO 4.
	SET alt_col TO 0.
	SET bear_col TO 1.
	SET incl_col TO 2.
	SET throt_col TO 3.

	LOCK STEERING TO HEADING(profile_list[bear_col + profile_line * 4], profile_list[incl_col + profile_line * 4]).
	LOCK THROTTLE TO profile_list[throt_col + profile_line * 4].

	UNTIL APOAPSIS >= target_APO {	// loop checking apoapsis according to proflist[alt_col+line]
									// check existance of nex_alt if ok - set next_alt to proflist[alt_col+line+1]	
		CLEARSCREEN.
		PRINT "BEARING: " + profile_list[bear_col + profile_line * 4] AT (0, 0).
		PRINT "INCLINATION: " + profile_list[incl_col + profile_line * 4] AT (0, 1).
		PRINT "THROTTLE: " + profile_list[throt_col + profile_line * 4] AT (0, 2).

		IF ALTITUDE > profile_list[alt_col + profile_line * 4] {
			SET profile_line TO profile_line + 1.
		}
		WAIT 0.001. 
	}
	LOCK THROTTLE TO 0.
	PRINT "Ascent completed.".
}

FUNCTION EXEC_CIRCULARIZE {
	PARAMETER target_PERI.
	
	UNTIL ETA:APOAPSIS >= 15 {
		CLEARSCREEN.
		PRINT "ETA to burn: " + (ETA:APOAPSIS - 15) AT (0,1).
		WAIT 0.001.
	}
	
	LOCK STEERING TO PROGRADE.
	WAIT 5.
	LOCK THROTTLE TO 1.

	UNTIL PERIAPSIS >= target_PERI {
		CLEARSCREEN.
		PRINT "Burning..." AT (0,1).
		WAIT 0.001.
	}
	LOCK THROTTLE TO 0.
	CLEARSCREEN.
	PRINT "Orbit reached." AT (0,1).
}

SET ascent_profile TO LIST (
//ALT, 	BEARING,	INCLINATION,	THROT
0,			90,			90,				1.0,
10000,		90,			90,				1.0,
30000,		90,			70,				0.5,
60000,		90,			45,				0.3,
70000,		90,			0,				0.1
).

STAGE.
EXEC_ASC_PROFILE(ascent_profile, 72000).
EXEC_CIRCULARIZE(APOAPSIS).

