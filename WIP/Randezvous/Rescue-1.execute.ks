// Rendezvous with ship on orbit of Kerbin (rescue mission)

RUNPATH ("1:/libs.ks").

// set target vessel

set target_Vess to vessel("Siwise's Capsule").
set target to target_Vess.
set phAng to PHASEANGLE_TO_VESS(target_Vess:name).

// calc target T

set dT to 1 + (360-phAng)/360. // calcs proportion to increase orbit period for the ship
set Th to target:orbit:period * dT / 2. // calcs halfperiod for the new orbit period

// change T

function change_T {	
	parameter _Th.
	set _burnT to 5. // desired min TBurn

	set Alt2 to r2_CALC_HOHMANN(ship:altitude,_Th).
	set dV to dV_CALC_HOHMANN(ship:altitude,Alt2).
	set TBurn to TIME_CALC_MNV(dV[0]).

	if TBurn / _burnT < 1 {
		ACTIVEENGINES_THR_LIM((TBurn / _burnT)*100).
		set TBurn to TIME_CALC_MNV(dV[0]).	
	}
	
	clearscreen.
	print "Angle to gain: " + (360 - phAng) at (0,1).
	print "Target Apo: " + Alt2 at (0,2).
	print "dV needed: " + dV[0] at (0,3).
	print "Burn time: " + TBurn at (0,4).
	print "New period: " + _Th * 2 at (0,5).
	
	local t is time:seconds + TBurn.
	lock throttle to 1.
	wait until TIMER(t).
	//WAIT_VISUAL(round(TBurn),0,0).
	lock throttle to 0.

	print "Period gained: " + ship:orbit:period at (0,6).
	ACTIVEENGINES_THR_LIM(100).
}

// wait closest approach

function await_closest_approach {
	
	clearscreen.
	until false {
		set lastDistance to target:distance.
		print "Distance to target: " + target:distance at (0,1).
		wait 1.
		if target:distance > lastDistance {
			break.
		}
	}
}

// kill relative velocity

function kill_relative_vel {
	
	//local max_acc is ship:maxthrust/ship:mass.
	lock killVec to target:velocity:orbit - ship:velocity:orbit.
	//set dV to killVec:mag.
	set killVec0 to killVec.
	//local tset is min(dV/max_acc, 1).

	clearscreen.
	lock steering to killVec0.
	WAIT_VISUAL(10,0,0).
	wait until vang(killVec0, ship:facing:vector) < 0.25.

	set tset to 0.
	lock throttle to tset.
	local done is false.
	
	until done {
		set max_acc to ship:maxthrust/ship:mass.
		set tset to min(killVec:mag/max_acc, 1).

		print "killVec:mag: " + killVec:mag at (0,1).
		print "vdot(killVec0, killVec): " + vdot(killVec0, killVec) at (0,2).		

		if vdot(killVec0, killVec) < 0 {
		    print "End burn, remain dv " + round(killVec:mag,1) + "m/s, vdot: " + round(vdot(killVec0, killVec),1) at (0,3).
		    lock throttle to 0.
		    break.
		}
	
		if killVec:mag < 0.1 {
			print "Finalizing burn, remain dv " + round(killVec:mag,1) + "m/s, vdot: " + round(vdot(killVec0, killVec),1) at (0,4).
			wait until vdot(killVec0, killVec) < 0.5.
			lock throttle to 0.
			print "End burn, remain dv " + round(killVec:mag,1) + "m/s, vdot: " + round(vdot(killVec0, killVec),1) at (0,3).
			set done to True.
		}
		wait 0.
	}


	//print "Relative velocity: " + (ship:velocity:orbit - target:velocity:orbit):mag at (0,1).
	//lock throttle to 0.1.
	//wait until ISH(1,(ship:velocity:orbit - target:velocity:orbit):mag,0.01).
	//lock throttle to 0.
	
	//until false {
	//	set lastDiff to (target:velocity:orbit - ship:velocity:orbit):mag.
	//	if (target:velocity:orbit - ship:velocity:orbit):mag > lastDiff {
	//		lock throttle to 0.
	//		break.
	//	}
	//}
}

// approach

function approach {
	lock steering to target:position.
	WAIT_VISUAL(15,0,0).
	lock throttle to 0.05.
	wait until ISH(5,(ship:velocity:orbit - target:velocity:orbit):mag,0.01).
	lock throttle to 0.
	lock steering to target:velocity:orbit - ship:velocity:orbit.

}

//main

change_T(Th).
wait until eta:apoapsis <= 2.
//TUNE_ORB_T(2*Th).

//wait until eta:periapsis <= 60.

until target:distance < 1000 {
	await_closest_approach().
	kill_relative_vel().
	if target:distance > 1000 {approach().}
}

kill_relative_vel().

print "Distance to target: " + target:distance at (0,2).
print "Script execution completed." at (0,4).

lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
WAIT_VISUAL(10,0,0).