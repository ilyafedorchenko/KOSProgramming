runpath("1:/libs.ks").

//=========================== Functions =====================================

	function StageAll {
	
		until stage:nextDecoupler = "None" {
		    stage.
		}
	}

//=========================== Triggers ======================================

	//when Periapsis < 60000 THEN {
	//	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	//	PRINT "Suborbit." AT (0,7).
	//	StageAll().
	//	lock steering to SrfRetrograde.
	//}
	
	//when Altitude < 60000 THEN {
	//	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	//	print "Entered atmo." AT (0,6).
	//	StageAll().
	//	lock steering to SrfRetrograde.
	//}
	
	//when Maxthrust < 0.01 then {
	//	//SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	//	PRINT "Burn complete, staging." AT (0,5).
	//	StageAll().
	//}
	
	//when Alt:Radar < 10000 then {
	//	//set ship:control:pilotmainthrottle to 0.
	//	print "Chutes ready to deploy." at (0,7).
	//}
	
	//WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN {
	//    UNLOCK ALL.
	//    CLEARSCREEN.
	//    PRINT "Flight complete" AT (0,2).
	//    WAIT_VISUAL(15,0,0).
	//    REBOOT.
	//}

//============================== MAIN =====================================

clearscreen.
ACTIVEENGINES_THR_LIM(100).

print "Starting abort procedure - v 0.3.1" at (0,1).

if Periapsis >= 70000 {
	print "Starting deorbit procedure" at (0,2).
	lock Throttle to 0.
	lock Steering to Retrograde.
	WAIT_VISUAL(15,0,0).
	print "Start burning" at (0,3).
	lock Throttle to 1.
	until Periapsis < 70000 {
		print "Periapsis: " + Periapsis at (0,4).
		wait 0.
	}
} 

//lock Throttle to 0.

print "Suborbit." at (0,5).

wait until Maxthrust < 0.001.
StageAll().

lock Steering to SrfRetrograde.
WAIT_VISUAL(5,0,0).

until Alt:Radar < 70 {
	print "Alt:Radar: " + Alt:Radar at (0,6).
	wait 0.
}

print "Landed." at (0,7).
WAIT_VISUAL(10,0,0).