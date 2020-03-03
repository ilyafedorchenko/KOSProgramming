//

FUNCTION EXEC_ASC_PROFILE {
	PARAMETER profile_list.
	PARAMETER target_APO.

	SET profile_line TO 0.
	SET proflie_col_num TO 4.
	SET last_line TO (profile_list:LENGTH / proflie_col_num - 1).

	SET alt_col TO 0.
	SET bear_col TO 1.
	SET incl_col TO 2.
	SET throt_col TO 3.

	CLEARSCREEN.

	LOCK STEERING TO HEADING(profile_list[bear_col + profile_line * proflie_col_num], profile_list[incl_col + profile_line * proflie_col_num]).
	LOCK THROTTLE TO profile_list[throt_col + profile_line * proflie_col_num].

	WHEN MAXTHRUST < 0.001 THEN {	//Stage_dirty - to refactor
			STAGE.
			RETURN TRUE.
		} 

	WHEN ALTITUDE >= profile_list[alt_col + (profile_line + 1) * proflie_col_num] THEN {
			SET profile_line TO profile_line + 1.
			IF (last_line - profile_line) > 0 {
				RETURN TRUE.	
			} ELSE {
				RETURN FALSE.
			}
		}

	UNTIL APOAPSIS > target_APO {	// loop checking apoapsis according to proflist[alt_col+line]
									// check existance of nex_alt if ok - set next_alt to proflist[alt_col+line+1]	
		
		PRINT "BEARING: " + profile_list[bear_col + profile_line * proflie_col_num] AT (0, 0).
		PRINT "INCLINATION: " + profile_list[incl_col + profile_line * proflie_col_num] AT (0, 1).
		PRINT "THROTTLE: " + profile_list[throt_col + profile_line * proflie_col_num] AT (0, 2).
		PRINT "PROFILE ALT: " + profile_list[alt_col + profile_line * proflie_col_num] + " - " + profile_list[alt_col + (profile_line + 1) * proflie_col_num] AT (0, 3).
		PRINT "ACTUAL ALT: " + ALTITUDE AT (0, 4).
		PRINT "Target_APO: " + target_APO AT (0, 5).

		WAIT 0. 
	}

	LOCK THROTTLE TO 0.
	PRINT "Ascent completed.".
	WAIT 3.

}

FUNCTION EXEC_CIRCULARIZE { // DOESN'T WORK PROPERLY, need calculation of dV for circularization and time to burn 
	PARAMETER target_PERI.
	
	UNTIL ETA:APOAPSIS < 12 {
		CLEARSCREEN.
		PRINT "ETA to burn: " + (ETA:APOAPSIS - 12) AT (0,1).
		WAIT 0.
	}
	
	LOCK STEERING TO PROGRADE.
	WAIT 2.
	LOCK THROTTLE TO 1.
	PRINT "Burning..." AT (0,2).
	
	WHEN PERIAPSIS >= target_PERI*0.8 THEN LOCK THROTTLE TO 0.2.
	WHEN PERIAPSIS >= target_PERI THEN {
		LOCK THROTTLE TO 0.
		PRINT "Orbit reached." AT (0,5).
		RETURN FALSE.
	}

	UNTIL PERIAPSIS >= target_PERI {
		PRINT "Target_PERI: " + target_PERI AT (0,3).
		PRINT "PERIAPSIS: " + PERIAPSIS AT (0,4).
		WAIT 0.
	}
}

SET ascent_profile TO LIST (
//ALT, 	BEARING,	INCLINATION,	THROT
0,			90,			90,				1.0,
5000,		90,			85,				1.0,
10000,		90,			80,				1.0,
15000,		90,			45,				0.9,
30000,		90,			15,				0.9,
60000,		90,			0,				0.5
).

STAGE.
EXEC_ASC_PROFILE(ascent_profile, 80000).
EXEC_CIRCULARIZE(APOAPSIS).

PRINT "Script execution completed." AT (0,6).
WAIT 15.
