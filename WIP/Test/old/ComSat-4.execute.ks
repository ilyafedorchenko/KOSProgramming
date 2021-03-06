RUNPATH ("1:/libs.ks").

PRINT "Total dV of the Ship is: " + dV_CALC_SHIP().

SET dV TO dV_CALC_Hohmann(PERIAPSIS,250000).
FOR x IN dV {
	PRINT "Needed dV to go to 100 000 is: " + x.
	PRINT "Time of burn: " + Time_CALC_MNV(x).	
}

LOCK STEERING TO HEADING(0,0).

SET t1 TO TIME:SECONDS + 600.

UNTIL Timer(t1) {
	LOCAL dT IS t1 - TIME:SECONDS.
	PRINT "Time: " + TIME:SECONDS AT (0,8).
	PRINT "t1: " + ROUND(t1,2) AT (0,9).
	PRINT "dT: " + ROUND(dT,2) AT (0,10).
	WAIT 0.
}
PRINT "Ring!" AT (0,11).

LOCK STEERING TO HEADING(180,0).

WAIT 20.
