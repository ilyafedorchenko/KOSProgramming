// Orbital or Suborbital flight?

// Orbital
// Go to suborbital (Periapsis < 35000)

IF PERIAPSIS > 70000 {
	LOCK STEERING TO RETROGRADE.
	WAIT 5.
	LOCK THROTTLE TO 1.
}

WHEN PERIAPSIS <= 35000 THEN {
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	LOCK THROTTLE TO 0.
	//UNTIL stage:nextDecoupler = "None" {
    //	STAGE.
	//}
	STAGE.
	STAGE. // final stagge with chutes
}

// Suborbital

LOCK STEERING TO SRFRETROGRADE.
WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN { 	//Didn't work, I guess, reboot was the cause
    UNLOCK ALL.														// Check if call of separate script will work better
    PRINT "Flight complete".
}