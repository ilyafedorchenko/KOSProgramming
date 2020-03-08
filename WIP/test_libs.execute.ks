RUNPATH ("1:/libs.ks").

PRINT "Total dV of the Ship is: " + dV_CALC_SHIP().

SET dV TO dV_CALC_Hohmann(-140000,100000).
FOR x IN dV {
	PRINT "Needed dV to go to 100 000 is: " + x.
	PRINT "Time of burn: " + Time_CALC_MNV(x).	
}

//SET t TO 0.

//UNTIL t > 600 {
//	PRINT "Time: " + TIME:SECONDS AT (0,6).
//	PRINT "t: " + t AT (0,7).
//	SET t TO t+1.
//	WAIT 0.
//}

SET t1 TO TIME:SECONDS + 10.

UNTIL Timer(t1) {
	LOCAL dT IS t1 - TIME:SECONDS.
	PRINT "Time: " + TIME:SECONDS AT (0,8).
	PRINT "t1: " + ROUND(t1,2) AT (0,9).
	PRINT "dT: " + ROUND(dT,2) AT (0,10).
	WAIT 0.
}
PRINT "Ring!" AT (0,11).

WAIT 20.
