LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNTIL stage:nextDecoupler = "None" {
    STAGE.
}

STAGE.

LOCK STEERING TO SRFRETROGRADE.
WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN { 	//Didn't work, I guess, reboot was the cause
    UNLOCK ALL.														// Check if call of separate script will work better
    PRINT "Flight complete".
}