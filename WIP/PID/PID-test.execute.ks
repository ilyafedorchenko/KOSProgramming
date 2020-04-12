clearscreen.
stage.
RUNPATH ("1:/libs.ks").

set g to Constant:G * body:mass / (body:radius + ship:altitude) ^ 2.
set VZ to ship:up:vector.
set VY to ship:facing:topvector.
set VX to ship:facing:starvector.
//lock VHor to vxcl(VZ,ship:velocity:surface).
lock VelZ to vxcl(VX, vxcl(VY, ship:velocity:surface)).
lock VelX to vxcl(VZ, vxcl(VY, ship:velocity:surface)).
lock VelY to vxcl(VZ, vxcl(VX, ship:velocity:surface)).

function tti {
	parameter margin.

	set g to Constant:G * body:mass / (body:radius + ship:altitude) ^ 2.
	set v0 to VelZ:mag. //ship:verticalspeed.
	set h to alt:radar - margin.

	return (sqrt(v0^2 + 2 * g * h) - v0) / g.

}

function throt_coeff {
	parameter p.
	
	if vdot(VZ,VelZ) < 0 {
		return VelZ:mag / p.
	} else {
		return p / VelZ:mag.
	}
	
}

set throt to 1.

lock steering to heading(150,75).
lock throttle to throt.

set thr to ENGTHRUSTISP().
set twr_targ to thr[0]/4.

wait until alt:radar > 1000.
set throt to 0.

wait until vdot(VZ,VelZ) < 0.
lock steering to srfretrograde.

set done to false.
until done {
	set _tti to tti(0).
	set tMNV to TIME_CALC_MNV(VelZ:mag).
	print "Alt: " + alt:radar at (0,1).
	print "tti: " + _tti at (0,2).
	print "tMNV: " + tMNV at (0,3).
	print "VZ mag: " + VelZ:mag at (0,4).
	if _tti <= tMNV {set done to true.}
}

	
set done to false.
until done {
	
	set gear to alt:radar<=30.

	if alt:radar > 50 {
		set twr_targ to throt_coeff(30.0).
	} else if alt:radar <= 50 and alt:radar > 10 {
			set twr_targ to throt_coeff(10.0).
	} else if alt:radar <= 10 and alt:radar > 5 {
		lock steering to VZ.
		set twr_targ to throt_coeff(2.0).
	} else if  alt:radar <= 5 {
		set done to true.
	}



	//if alt:radar < 200 and alt:radar > 30  {
	//	set twr_targ to throt_coeff(10.0).
	//} else if  alt:radar < 30 and alt:radar > 5 {
	//	lock steering to VZ.
	//	set twr_targ to throt_coeff(2.0).
	//} else if  alt:radar < 5{
	//	set done to true.
	//} else {
	//	set twr_targ to 0.1.
	//}

	set twr to thr[0] / (ship:mass * g).
	set throt to min(twr_targ / twr, 1).

	print "Alt: " + alt:radar at (0,1).
	print "VZ mag: " + VelZ:mag at (0,4).
	//print "Throt * twr: " + throttle * twr at (0,6).
	//print "Eng_Acc: " + throttle * thr[0] / ship:mass at (0,7).
	//print "VelZ: " + VelZ:mag at (0,8).
	//print "g: " + g at (0,9).
	
	//draw vectors
	set ZVecDraw to vecdraw(V(3,0,0),VZ, rgb(1,0,0), "Z", VZ:mag, true,0.01).
	set YVecDraw to vecdraw(V(3,0,0),VY, rgb(1,0,0), "Y", VY:mag, true,0.01).
	set XVecDraw to vecdraw(V(3,0,0),VX, rgb(1,0,0), "X", VZ:mag, true,0.01).

	set VelVecDraw to vecdraw(V(3,0,0),ship:velocity:surface, rgb(0,0,1), "Vel", ship:velocity:surface:mag,true,0.01).
	//set H_VelVecDraw to vecdraw(V(3,0,0),VHor, rgb(1,1,0), "H_Vel", VHor:mag,true,0.01).
	set Z_VelVecDraw to vecdraw(V(3,0,0),VelZ, rgb(0,1,0), "Z_Vel", VelZ:mag,true,0.01).
	set X_VelVecDraw to vecdraw(V(3,0,0),VelX, rgb(0,1,0), "H_X_Vel", VelX:mag,true,0.01).
	set Y_VelVecDraw to vecdraw(V(3,0,0),VelY, rgb(0,1,0), "H_Y_Vel", VelY:mag,true,0.01).

	//wait 0.
}

unlock steering.
lock throttle to 0.