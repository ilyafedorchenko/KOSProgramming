
//=========================== Triggers ======================================

WHEN ALTITUDE < 60000 THEN {
	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	PRINT "Entered atmo." AT (0,6).
	RETURN FALSE.
}

ON MAXTHRUST {
	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	PRINT "Burn complete, staging." AT (0,5).
	LOCK STEERING TO SRFRETROGRADE.
	WAIT 5.
	STAGE.
	STAGE.
	STAGE.
	RETURN FALSE.
}

WHEN ALTITUDE < 10000 THEN {
	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	PRINT "Chutes ready to deploy." AT (0,7).
	RETURN FALSE.
}

WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN {
    UNLOCK ALL.
    CLEARSCREEN.
    PRINT "Flight complete" AT (0,2).
    WAIT 15.
    REBOOT.
}

//============================== MAIN =====================================

CLEARSCREEN.

PRINT "Starting abort procedure - v 0.1." AT (0,1).
WAIT 3.
LOCK STEERING TO RETROGRADE.
WAIT 8.

IF PERIAPSIS > 70000 {
	PRINT "Starting deorbit procedure" AT (0, 2).
	LOCK STEERING TO RETROGRADE.
	WAIT 5.
	PRINT "Start burning" AT (0,3).
	LOCK THROTTLE TO 1.
}

UNTIL FALSE { //UNTIL (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") {
	PRINT "Waiting for landing..." AT (0,4).
	WAIT 3.
}