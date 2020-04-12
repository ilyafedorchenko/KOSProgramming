// Makes Hohhman transfer from circular orbit to target circular orbit with target phase angle
// Randezvous: target phase angle = 0 
// Sat constellation: target phase angle = 90 / 130

RUNPATH ("1:/libs.ks").

set target_obj to body("Mun").
set target_Alt to target_obj:altitude.
set target_PhaseAng to -5.
set startBurnErr to 0.00002. // Error tolerance for ISH

set cur_Alt to (apoapsis+periapsis)/2.

//============================ Wait for phase angle =================================

set vel_grad to 360 / target_obj:orbit:period.
set r1 to cur_Alt + body:radius.
set r2 to target_Alt + body:radius.
set Th to constant:pi * sqrt(((r1 + r2) ^ 3)/(8 * body:mu)). // период полуорбиты до Ap

set phaseAngStartBurn to 180 - (target_PhaseAng + Th * vel_grad). // расчет фазового угла начала маневра

clearscreen.

if target_Alt > cur_Alt {
		lock steering to prograde.
	} else if target_Alt < cur_Alt {
		lock steering to retrograde.
	} else {
		reboot.
	}

until ISH(phaseAngStartBurn,PHASEANGLE_TO_OBJ(target_obj:name),startBurnErr) {
	print "Time to reach " + target_obj:name + ": " + TIME_FORMAT(Th) at (0,1).
	print "Phase angle to start burn: " + phaseAngStartBurn at (0,2).
	print "Actual phase angle to " + target_obj:name + " : " + PHASEANGLE_TO_OBJ(target_obj:name) at (0,3).
} 

//================================== Maneuver =======================================


set dV_LIST to dV_CALC_HOHMANN(cur_Alt, target_Alt).
set Burn_Time TO Time_CALC_MNV(dV_LIST[0]).

clearscreen.

print "dV to Burn: " + dV_LIST[0] at (0,2).
print "From R1: " + cur_Alt at (0,3).
print "To R2: " + target_Alt at (0,4).
print "Burn time: " + Burn_Time at (0,5).

// Setup burn parameters / variables
set endBurnT to time:seconds + Burn_Time.
set endVel to velocity:orbit:mag + dV_LIST[0].
set done to false.

// Burn loop
until done {

	set remain_dV to endVel - velocity:orbit:mag.
	set max_acc to ship:maxthrust/ship:mass.
	set remain_T to endBurnT - time:seconds.
	
	print round(remain_T,3) + " seconds to burn " at (0,8).
	print round(remain_dV,3) + " dV to gain " at (0,9).
	print "endVel: " + round(endVel,3) at (0,10).
	print "velocity: " + round(velocity:orbit:mag,3) at (0,11).
	print "remain_dV/max_acc: " + round(remain_dV/max_acc,2) at (0,12).
	print "Throttle: " + throttle at (0,13).
	
	lock throttle to min(max(round(remain_dV/max_acc,2),0.05), 1).
	
	if round(remain_dV,1) <= 0.5 {set done to true.}
	wait 0.
}
	lock throttle to 0.
	
	WAIT_VISUAL(10,0,0).

print "Script execution completed." at (0,15).
lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
WAIT_VISUAL(10,0,0).