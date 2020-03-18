//

FUNCTION ALTER_ASC_PROFILE {

	// Твердотопливный ускоритель отрабатывает чисто вертикально.
	LOCK Steering to Heading(90,90). 
	LOCK Throttle to 1.
	STAGE.
	WAIT UNTIL STAGE:SOLIDFUEL<1.
	
	//Вторая ступень отрабатывает тангаж от 90 до 40 градусов по мере расхода топлива.
	//Апоапсис в результате получится около 75 км. Это чисто опытная подгонка (да, нубство, хехе)
	STAGE.
	SET MaxFuel to STAGE:OXIDIZER.
	LOCK Steering to Heading(90,90-60*(1-STAGE:OXIDIZER/MaxFuel)).
	WAIT UNTIL STAGE:OXIDIZER<1.
	LOCK Steering to PROGRADE.
	LOCK Throttle to 0.
	WAIT 1.
	STAGE.
}


FUNCTION EXEC_ASC_PROFILE {
	PARAMETER profile_list.
	PARAMETER target_APO.
	PARAMETER bear_col.

	SET profile_line TO 0.
	SET proflie_col_num TO 3.
	SET last_line TO (profile_list:LENGTH / proflie_col_num - 1).

	SET alt_col TO 0.
	SET incl_col TO 1.
	SET throt_col TO 2.

	CLEARSCREEN.

	LOCK STEERING TO HEADING(bear_col, profile_list[incl_col + profile_line * proflie_col_num]).
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

	UNTIL APOAPSIS >= target_APO {	// loop checking apoapsis according to proflist[alt_col+line]
									// check existance of nex_alt if ok - set next_alt to proflist[alt_col+line+1]	
		
		PRINT "BEARING: " + bear_col AT (0, 0).
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
	CLEARSCREEN.
	
	SET dV_LIST TO dV_CALC_Hohmann(PERIAPSIS, target_PERI).

	PRINT "dV needed: " + dV_LIST AT (0,20).
	PRINT "dV to Burn: " + dV_LIST[1] AT (0,21).
	PRINT "From R1: " + PERIAPSIS AT (0,27).
	PRINT "To R2: " + target_PERI AT (0,28).

	SET Burn_Time TO Time_CALC_MNV(dV_LIST[1]).
	PRINT "Burn time: " + Burn_Time AT (0,4).

	LOCK STEERING TO PROGRADE.

	UNTIL ETA:APOAPSIS <= Burn_Time/2 {
		PRINT "ETA to burn: " + (ETA:APOAPSIS - Burn_Time/2) AT (0,5).
		WAIT 0.
	}
	
	LOCK THROTTLE TO 1.
	PRINT "Burning..." AT (0,7).
	
	WHEN PERIAPSIS >= target_PERI THEN {
		LOCK THROTTLE TO 0.
		PRINT "Orbit reached." AT (0,7).
		RETURN FALSE.
	}

	UNTIL PERIAPSIS >= target_PERI {
		PRINT "Target_PERI: " + target_PERI AT (0,8).
		PRINT "PERIAPSIS: " + PERIAPSIS AT (0,9).
		WAIT 0.
	}
}


//=======================================MAIN=========================================

RUNPATH ("1:/libs.ks").

SET ascent_profile TO LIST (
//ALT, 	INCLINATION,	THROT
0,			90,			0.0,
5000,		80,			0.0,
10000,		60,			0.0,
11000,		55,			0.0,
12000,		45,			0.0,
13000,		45,			0.5,
14000,		45,			0.5,
15000,		45,			1.0,
16000,		45,			1.0,
25000,		45,			1.0,
30000,		45,			1.0,
60000,		45,			1.0
).

//STAGE.
//EXEC_ASC_PROFILE(ascent_profile, 80000, 89.95).
ALTER_ASC_PROFILE().
CIRC_MNV().

//STAGE.
//EXEC_CIRCULARIZE(APOAPSIS).

PRINT "Script execution completed." AT (0,9).
WAIT_VISUAL(20,0,0).
