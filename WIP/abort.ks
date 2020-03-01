// Orbital or Suborbital flight?

// Orbital
// Go to suborbital (Periapsis < 35000)

IF PERIAPSIS > 70000 {
	LOCK STEERING TO RETROGRADE.
	UNTIL PERIAPSIS <= 35000 {
		LOCK THROTTLE TO 1.
		WAIT 0.001.
	}
}

// Suborbital

LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

UNTIL stage:nextDecoupler = "None" {
    STAGE.
}

STAGE. // final stagge with chutes

LOCK STEERING TO SRFRETROGRADE.
WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN { 	//Didn't work, I guess, reboot was the cause
    UNLOCK ALL.														// Check if call of separate script will work better
    PRINT "Flight complete".
}