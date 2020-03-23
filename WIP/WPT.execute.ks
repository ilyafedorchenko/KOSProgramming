RUNPATH ("1:/libs.ks").

CLEARSCREEN.

SET my_WPS TO ALLWAYPOINTS().
SET my_WP TO WPT_COORD().

CLEARSCREEN.
PRINT "Current WPT Name: "	+ my_WP:NAME AT(0,2).
PRINT "GEOPOSITION LAT: "	+ my_WP:GEOPOSITION:LAT AT(0,3).
PRINT "GEOPOSITION LNG: "	+ my_WP:GEOPOSITION:LNG AT (0,4).

SET burn_WPT_LNG TO my_WP:GEOPOSITION:LNG - 90.

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION LNG_CONVERT { // Convert LNG to 0..360 Degrees AND to -180..0..180 Deg
	PARAMETER LNG_.

	IF -180 < LNG_ AND LNG_ < 0   {
		RETURN 360 + LNG_.
	} ELSE IF 0 <= LNG_ AND LNG_ <= 180 {
		RETURN LNG_.
	} ELSE IF 180 < LNG_ AND LNG_ < 360 {
		RETURN LNG_ - 360.
	} ELSE {
		RETURN 0.
	}
}

LOCK dAngle TO LNG_CONVERT(SHIP:GEOPOSITION:LNG) - LNG_CONVERT(burn_WPT_LNG). //угол до точки маневра

LOCK burnDATA TO ANBurn(ship:velocity:orbit:Mag, my_WP:GEOPOSITION:LAT - SHIP:ORBIT:INCLINATION). //Поменял SET на LOCK
// Чего возвращает ANBurn
//				0	1
//	RETURN LIST(Fi, dVorb).	

SET burnT TO Time_CALC_MNV(burnDATA[1]:MAG).
//LOCK STEERING TO PROGRADE + R(-90+burnDATA[0],0,0).
LOCK STEERING TO burnDATA[1].

PRINT "==============================" AT(0,5).
PRINT "burnT: " + ROUND(burnT) AT(0,6).
PRINT "burnDATA Vector: " + burnDATA[0] AT(0,7).
PRINT "burnDATA Fi: " + burnDATA[1] AT(0,8).

UNTIL ABS(dAngle) < 0.5  {
	PRINT "SHIP:GEOPOSITION:LNG " + SHIP:GEOPOSITION:LNG  AT(0,9).
	PRINT "Waypoint LNG " + burn_WPT_LNG  AT(0,10).
	PRINT "SHIP - MNV angle: " + dAngle AT(0,11).
	WAIT 0.
}

//LOCK THROTTLE TO 1.
PRINT "Burning s:" + burnT AT(0,13).

LOCK THROTTLE TO 1.
WAIT_VISUAL(ROUND(burnT+2),0,0). //???????????????????????????
LOCK THROTTLE TO 0.

PRINT "SHIP:ORBIT:INCLINATION " + SHIP:ORBIT:INCLINATION  AT(0,9).
PRINT "Waypoint LAT " + my_WP:GEOPOSITION:LAT  AT(0,10).
PRINT "" AT(0,11).

PRINT "Script executed." AT(0,13).
WAIT_VISUAL(20,0,0).