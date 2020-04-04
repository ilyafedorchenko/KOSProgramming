// This scrip calculates phase angle

function PHASEANGLE_TO_VESS { // Returns phase angle from current vessel to targe vessel, orbiting the same body
	parameter targ_ves_name.

	set targ_Vess to vessel(targ_ves_name).
	set a to ship:orbit:position - ship:orbit:body:position.
	set b to targ_Vess:orbit:position - targ_Vess:orbit:body:position.
	set ab_cross to vcrs(a,b).

	set ship_vel to ship:velocity:orbit.
	set ship_vel_normal to vcrs(ship_vel,a).
	set PhaseAngle to vang(a,b).

	if vdot(ab_cross,ship_vel_normal) > 0 {set PhaseAngle to 360 - PhaseAngle.}

  	return PhaseAngle.
}

clearscreen.

until false {
	set ang to PHASEANGLE_TO_VESS("ComSat-4").
	print ang.
	wait 0.001.
}
