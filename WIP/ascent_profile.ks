//

FUNCTION ABORT_FUNC {
	UNTIL stage:nextDecoupler = "None" {
    	STAGE.
    }
}

FUNCTION EXEC_ASC_PROFILE {
	PARAMETER profile_list
	PARAMETER target_APO

	SET profile_line TO 0
	SET proflie_col_num TO 4
	SET alt_col TO 0
	SET bear_col TO 1
	SET incl_col TO 2 
	SET throt_col TO 3

	LOCK STEERING TO HEADING(profile_list[bear_col + line * 4], profile_list[incl_col + line * 4]).
	LOCK THROTTLE TO profile_list[throt_col + line * 4].

	UNTIL APOAPSIS >= target_APO {	// loop checking apoapsis according to proflist[alt_col+line]
		//		check existance of nex_alt if ok - set next_alt to proflist[alt_col+line+1]	
		PRINT "HEADING: " + HEADING AT (0, 0).
		PRINT "THROTTLE: " + THROTTLE AT (0, 1).

		IF ALTITUDE > profile_list[alt_col + profile_line * 4] {
			SET profile_line TO profile_line + 1.
		}
		WAIT 0.001. 
	}
	LOCK THROTTLE TO 0.
	PRINT "Ascent profile completed.".
}

SET ascent_profile TO LIST (
//ALT, 	BEARING,	INCLINATION,	THROT
0,			0,			90,				1.0,
10000,		0,			80,				1.0,
30000,		0,			70,				0.5,
60000,		0,			40,				0.3,
70000,		0,			0,				0.1,
).

EXEC_ASC_PROFILE(ascent_profile, 80000).
ON ABORT {
    PRINT "Aborting!".
    ABORT_FUNC().
}


