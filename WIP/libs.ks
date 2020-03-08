// All handy functions

FUNCTION ISH {
	PARAMETER target_value.
	PARAMETER actual_value.
	PARAMETER error_tolerance.

	IF ABS(target_value - actual_value)/target_value < error_tolerance {
		RETURN TRUE.
	} ELSE {
		RETURN FALSE.
	}
}

FUNCTION ORB_VEL { //Orbital velocity for specific height of the orbit
	PARAMETER targeted_h.
	RETURN ROUND(SQRT(BODY:Mu / (BODY:RADIUS + targeted_h)), 2).
}


FUNCTION dV_CALC_Hohmann {	//
	PARAMETER r1. // initial orbit
	PARAMETER r2. // target orbit
	
	// Mu - gravetational parameter of the body
	

	LOCAL dV1 IS ROUND(ORB_VEL(r1) * (SQRT(2 * (r2 + BODY:RADIUS)/(r1 + r2 + 2 * BODY:RADIUS)) - 1), 2).
	LOCAL dV2 IS ROUND(ORB_VEL(r2) * (1 - SQRT(2 * (r1 + BODY:RADIUS)/(r1 + r2 + 2 * BODY:RADIUS))), 2).

	RETURN LIST(dV1, dV2).
}

//Time of burn calc to reach dV

FUNCTION Time_CALC_MNV {	// Calc time in sec to burn for given dV
	PARAMETER dV.

	LIST ENGINES IN ShipEngines.
	LOCAL NumberOfEngines IS ShipEngines:LENGTH.

	LOCAL f IS ShipEngines[NumberOfEngines - 1]:MAXTHRUST * 1000. // Engine Thrust in Newtons (kg * m/s^2)
	LOCAL m IS SHIP:MASS * 1000.	// Staring mass (kg)
	LOCAL e IS CONSTANT:E.			// Base of natural log
	LOCAL p IS ShipEngines[NumberOfEngines - 1]:ISP.	// Engines Isp (s)
	LOCAL g IS CONSTANT:g0.			// Grav accel consdtant

	RETURN g * m * p * (1 - e^(-dV / (g * p))) / f.
}


FUNCTION dV_CALC_SHIP {		//Calc total dV for current first Engine of all Engines. Engine should be activated
	LIST ENGINES IN ShipEngines.
	LOCAL NumberOfEngines IS ShipEngines:LENGTH.

	LOCAL DryMass IS SHIP:MASS - ((SHIP:LIQUIDFUEL + SHIP:OXIDIZER) * 0.005).
	RETURN ROUND(ShipEngines[NumberOfEngines - 1]:ISP * CONSTANT:g0 * LN(SHIP:MASS / SHIP:DryMass), 2).
}


FUNCTION Timer {
	PARAMETER t1. // time in future

	IF (t1 - TIME:SECONDS <= 0) {
		RETURN TRUE.
	} ELSE {
		RETURN FALSE.
	}
}


// RETURN active engines



