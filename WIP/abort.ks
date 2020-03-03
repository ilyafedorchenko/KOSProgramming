// Orbital or Suborbital flight?

// Orbital
// Go to suborbital (Periapsis < 35000)

SET targetPart TO SHIP:PARTSTAGGED("TestShield").

PRINT "Starting deorbit procedure".
WAIT 3.
LOCK STEERING TO RETROGRADE.
WAIT 8.
STAGE.

//IF PERIAPSIS > 70000 {
//	PRINT "Starting deorbit procedure".
//	WAIT 3.
//	LOCK STEERING TO RETROGRADE.
//	WAIT 5.
//	PRINT "Starting burn".
//	LOCK THROTTLE TO 0.4.
//}

// Suborbital

WHEN PERIAPSIS <= 60000 THEN {
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	PRINT "Stop burn".
	//LOCK THROTTLE TO 0.
	//UNTIL stage:nextDecoupler = "None" {
    //	STAGE.
	//}
	
	//STAGE. // final stagge with chutes
	LOCK STEERING TO SRFRETROGRADE.
}

WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN { 	//Didn't work, I guess, reboot was the cause
    UNLOCK ALL.														// Check if call of separate script will work better
    PRINT "Flight complete".
    WAIT 15.
}

WHEN (ALTITUDE < 53000 AND ALTITUDE > 44000 AND VELOCITY > 1970 AND VELOCITY < 2460) THEN {
	PRINT "Conditions reached. Trying to test shield".
	targetPart:DOEVENT("Run Test").
	WAIT 15.
}

UNTIL (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") {
	PRINT "Waiting for landing..." AT (0,7).
}