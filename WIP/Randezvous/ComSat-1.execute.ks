// Makes Hohhman transfer from circular orbit to target circular orbit with target phase angle
// Randezvous: target phase angle = 0 
// Sat constellation: target phase angle = 90 / 130

RUNPATH ("1:/libs.ks").

set target_Alt to 440000.
set target_PhaseAng to 90.
set target_Vess to vessel("ComSat-3").
set startBurnErr to 0.00002. // Error tolerance for ISH

set cur_Alt to (apoapsis+periapsis)/2.

//============================ Wait for phase angle =================================

set vel_grad to 360 / target_Vess:orbit:period.
set r1 to cur_Alt + body:radius.
set r2 to target_Alt + body:radius.
set Th to constant:pi * sqrt(((r1 + r2) ^ 3)/(8 * body:mu)). // период полуорбиты до Ap
set phaseAngStartBurn to 360 + (target_PhaseAng - Th * vel_grad). // расчет фазового угла начала маневра

clearscreen.

if target_Alt > cur_Alt {
		lock steering to prograde.
	} else if target_Alt < cur_Alt {
		lock steering to retrograde.
	} else {
		reboot.
	}

until ISH(phaseAngStartBurn,PHASEANGLE_TO_VESS(target_Vess:name),startBurnErr) {
	print "Phase angle to start burn: " + phaseAngStartBurn at (0,1).
	print "Actual phase angle to " + target_Vess:name + " : " + PHASEANGLE_TO_VESS(target_Vess:name) at (0,2).
} 

//================================== Maneuver =======================================


set dV_LIST to dV_CALC_HOHMANN(cur_Alt, target_Alt).
set target_min_T to 1. // желаемое min время маневра
set ActEngs to ACTIVEENGINES().
set burnNode to 0.

FOR dV_x IN dV_LIST {

	clearscreen.
	set Burn_Time TO Time_CALC_MNV(dV_x).

	if Burn_Time < target_min_T {
		for en in ActEngs {
			set en:thrustlimit to Burn_Time / target_min_T * 100.
		}
		SET Burn_Time TO Time_CALC_MNV(dV_x).
	}

	print "dV to Burn: " + dV_x at (0,2).
	print "From R1: " + cur_Alt at (0,3).
	print "To R2: " + target_Alt at (0,4).
	print "Burn time: " + Burn_Time at (0,5).

	if burnNode > 0 {
		until eta:periapsis <= Burn_Time/2 {
		print "ETA to burn: " + (eta:periapsis - Burn_Time/2) AT (0,6).
		wait 0.
		}
	} else if burnNode < 0 {
		until eta:apoapsis <= Burn_Time/2 {
		print "ETA to burn: " + (eta:apoapsis - Burn_Time/2) AT (0,6).
		wait 0.
		}
	}
	
	set endBurnT to time:seconds + Burn_Time.
	set endVel to velocity:orbit:mag + dV_x.
	if target_Alt > cur_Alt {
		lock remain_dV to endVel - velocity:orbit:mag.
	} else {
		lock remain_dV to velocity:orbit:mag - endVel.
	}
	lock remain_T to endBurnT - time:seconds.
	lock throttle to 1.

	until remain_dV <= 0 {
		print remain_T + " seconds to burn " at (0,8).
		print remain_dV + " dV to gain " at (0,9).
		print "endVel: " + endVel at (0,10).
		print "velocity: " + velocity:orbit:mag at (0,11).
		print "remain_dV/dV_x: " + round(remain_dV/dV_x,3) at (0,12).
		if remain_T/Burn_Time <= 0.1 {
			lock throttle to remain_T.
			print "throttle: " + round(remain_T,4) at (0,13).
		
			if remain_dV > 0 {
				lock throttle to 0.1.
				wait until remain_dV <= 0.
				print "remain_dV/dV_x: " + round(remain_dV/dV_x,3) at (0,14).
			}
		}
		wait 0.
	}

	unlock remain_dV.
	unlock remain_T.

	lock throttle to 0.
	
	if target_Alt > cur_Alt {
		set burnNode to -1.
	} else if target_Alt < cur_Alt {
		set burnNode to 1.
	} else {
		reboot.
	}



	for en in ActEngs {
		set en:thrustlimit to 100.
	}
	WAIT_VISUAL(10,0,0).
}

TUNE_ORB_T(target_Vess:orbit:period).

print "Script execution completed." at (0,15).
lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
WAIT_VISUAL(10,0,0).