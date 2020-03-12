//

RUNPATH ("1:/libs.ks").

SET target_PERI TO 250000.
SET dV_LIST TO dV_CALC_Hohmann(PERIAPSIS, target_PERI).

LOCK STEERING TO PROGRADE.

FOR x IN dV_LIST { //ADD SECOND BURN

	CLEARSCREEN.
	SET Burn_Time TO Time_CALC_MNV(dV_LIST[x]).

	PRINT "dV to Burn: " + dV_LIST[x] AT (0,2).
	PRINT "From R1: " + PERIAPSIS AT (0,3).
	PRINT "To R2: " + target_PERI AT (0,4).
	PRINT "Burn time: " + Burn_Time[x] AT (0,4).

	UNTIL ETA:PERIAPSIS <= Burn_Time/2 {
	PRINT "ETA to burn: " + (ETA:APOAPSIS - Burn_Time/2) AT (0,5).
	WAIT 0.
	}
	
	LOCK THROTTLE TO 1.
	PRINT "Burning..." AT (0,7).
	
	WHEN APOAPSIS >= target_PERI THEN {
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

}

PRINT "Script execution completed." AT (0,10).
LOCK STEERING TO HEADING(0,0).
WAIT 15.
