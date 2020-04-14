clearscreen.
RUNPATH ("1:/libs.ks").

//log "g;VelZ:mag;VelX:mag;VelY:mag;alt:radar;throt;thr;acc;twr_targ;_tti;tr:tti;tMNV" to "0:/upload.txt".
function logTLM {
	if addons:tr:hasimpact {
		set _ttiTR to addons:tr:timetillimpact.
	} else {set _ttiTR to 0.}
	set acc to thr[0]*throttle/(ship:mass).
	set _tti to tti(0).
	set tMNV to TIME_CALC_MNV(VelZ:mag).

	log g + ";"
		+ VelZ:mag + ";"
		+ VelX:mag + ";"
		+ VelY:mag + ";"
		+ alt:radar + ";"
		+ throt + ";"
		+ thr[0] + ";"
		+ acc + ";"
		+ twr_targ + ";"
		+ _tti + ";"
		+ _ttiTR + ";"
		+ tMNV
		to "0:/upload.txt".
}

//set reference vectors
set g to Constant:G * body:mass / (body:radius + ship:altitude) ^ 2.
set VZ to ship:up:vector.
set VY to ship:facing:topvector.
set VX to ship:facing:starvector.

lock VHor to vxcl(VZ, ship:velocity:surface).
lock VelZ to vxcl(VX, vxcl(VY, ship:velocity:surface)).
lock VelX to vxcl(VZ, vxcl(VY, ship:velocity:surface)).
lock VelY to vxcl(VZ, vxcl(VX, ship:velocity:surface)).

//lock steering to selected waypoint (spot)


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

set next_step to "Set target". // list of allwaypoints
//set next_step to "Launch".
//set next_step to "Wait approach".
//set next_step to "Adjust impact pos".
//set next_step to "Land".
//set next_step to "Landed".

// -------------------------- Waypoint selection ---------------------------------

until next_step = "Launch" {
	set wps to WPT_COORD().
	if wps:length <> 1 {
		clearscreen.
		print "Select waypoint..." at(0,2).
		set cursor to wps:iterator.
		until not cursor:next {
			print cursor:value at(0,cursor:index + 3).
		}
		WAIT_VISUAL(5,0,0).
	} else {
		clearscreen.
		set spot to wps[0].
		print spot at (0,2).
		addons:tr:settarget(spot:geoposition).
		set next_step to "Launch".
	}
}

// ------------------------------- "Launch" --------------------------------------

set throt to 1.
set pitch to 90.
set dS to 0.
lock throttle to throt.
lock steering to heading(spot:geoposition:heading,pitch).
stage.
set thr to ENGTHRUSTISP().
set twr_targ to thr[0].

until next_step = "Wait approach" {

	clearscreen.
	print "Current wpt name: "	+ spot:name at(0,1).
	print "Distance: " + spot:geoposition:distance at(0,2).
	print "Heading: " + spot:geoposition:heading at(0,3).
	print "Bearing: " + spot:geoposition:bearing at(0,4).

	if altitude < 50 {}
	else if altitude < 100 {
		set pitch to 85.		
	} else if altitude < 500 {
		set pitch to 45.
	} else if altitude < 5000 {
		set pitch to 45.
	} else if altitude < 10000 {
		set pitch to 40.
	} else {
		set next_step to "Wait approach".
	}

	if addons:tr:hasimpact {
		set dS to (spot:geoposition:distance - addons:tr:impactpos:distance).
	}

	wait 0.
}

// ---------------------------- "Wait approach" ----------------------------------

until next_step = "Adjust impact pos" {

	clearscreen.
	print "Current wpt name: "	+ spot:name at(0,1).
	print "Distance: " + spot:geoposition:distance at(0,2).
	print "Heading: " + spot:geoposition:heading at(0,3).
	print "Bearing: " + spot:geoposition:bearing at(0,4).
	print "Distance diff: ---" at(0,5).

	if addons:tr:hasimpact {
		set dS to (spot:geoposition:distance - addons:tr:impactpos:distance).
		print "Distance diff: " +  dS at(0,5).
		set throt to min(abs(dS)/5000,1). // ???? use PID to achieve 0 dS
		if abs(dS) <= 100 {
			set throt to 0.
			set next_step to "Adjust impact pos".
		}
	}
	wait 0.
}


// ------------------------- "Adjust impact pos" ---------------------------------

until next_step = "Land" {

	set tMNV to TIME_CALC_MNV(VelZ:mag).
	set _tti to 0.

	clearscreen.
	print "Current wpt name: "	+ spot:name at(0,1).
	print "Distance diff: ---" at(0,2).
	print "tMNV: " + tMNV at(0,3).
	print "TTI: ---" at(0,4).

	if addons:tr:hasimpact {
		set dS to (spot:geoposition:distance - addons:tr:impactpos:distance).
		set _tti to addons:tr:timetillimpact.
		print "Distance diff: " + dS at(0,2).
		print "TTI: " + _tti at(0,4).
	}

	if dS < -10 {
		lock steering to (-VHor).
		//set addons:tr:retrograde to true.
		wait until vang(-VHor, ship:facing:vector) < 0.5.
		set throt to min(abs(dS)/10,1). 
	} else if dS > 10 {
		lock steering to (VHor).
		//set addons:tr:prograde to true.
		wait until vang(VHor, ship:facing:vector) < 0.5.
		set throt to min(abs(dS)/10,1). 
	} else {set throt to 0.}
	
	if _tti <= tMNV {set next_step to "Land".}

	wait 0.
}

// -------------------------------- "Land" ---------------------------------------

until next_step = "Landed" {
	
	set gear to alt:radar<=30.

	clearscreen.
	print "Current wpt name: "	+ spot:name at(0,1).
	print "Altitude: "	+ alt:radar at(0,1).
	print "VZ mag: " + VelZ:mag at(0,3).
	
	if alt:radar > 50 {
		lock steering to srfretrograde.
		set twr_targ to throt_coeff(20.0).
	} else if alt:radar <= 50 and alt:radar > 10 {
		set twr_targ to throt_coeff(10.0).
	} else if alt:radar <= 10 and alt:radar > 5 {
		lock steering to VZ.
		set twr_targ to throt_coeff(2.0).
	} else if  alt:radar <= 5 {
		set done to true.
	}

	set twr to thr[0] / (ship:mass * g).
	set throt to min(twr_targ / twr, 1).

	if not addons:tr:hasimpact {
		set next_step to "Landed".
	}

}

// ------------------------------- "Landed" --------------------------------------

unlock steering.
lock throttle to 0.
WAIT_VISUAL(30,0,0).


//set done to false.
//until done {
//	//logTLM().
//	set gear to alt:radar<=30.
//
//	if alt:radar > 50 {
//		set twr_targ to throt_coeff(20.0).
//	} else if alt:radar <= 50 and alt:radar > 10 {
//			set twr_targ to throt_coeff(10.0).
//	} else if alt:radar <= 10 and alt:radar > 5 {
//		lock steering to VZ.
//		set twr_targ to throt_coeff(2.0).
//	} else if  alt:radar <= 5 {
//		set done to true.
//	}
//
//
//	set twr to thr[0] / (ship:mass * g).
//	set throt to min(twr_targ / twr, 1).
//
//	print "Distance: " + spot:geoposition:distance at (0,1).
////	print "dLAT :" + dLAT at (0,2).
////	print "dLNG :" + dLNG at (0,3).
//	set disDiff to (spot:geoposition:distance - addons:tr:impactpos:distance).
//	print "Distance TI: " + addons:tr:impactpos:distance at (0,4). // Print distance from vessel to impact pos
//	print "Distance dif: " +  disDiff at (0,5). // Print distance from vessel to impact pos
//	//print "VZ mag: " + VelZ:mag at (0,4).
//	//print "Throt * twr: " + throttle * twr at (0,6).
//	//print "Eng_Acc: " + throttle * thr[0] / ship:mass at (0,7).
//	//print "VelZ: " + VelZ:mag at (0,8).
//	//print "g: " + g at (0,9).
//	
//	//draw vectors
//	set ZVecDraw to vecdraw(V(3,0,0),VZ, rgb(1,0,0), "Z", VZ:mag, true,0.01).
//	set YVecDraw to vecdraw(V(3,0,0),VY, rgb(1,0,0), "Y", VY:mag, true,0.01).
//	set XVecDraw to vecdraw(V(3,0,0),VX, rgb(1,0,0), "X", VZ:mag, true,0.01).
//
//	set VelVecDraw to vecdraw(V(3,0,0),ship:velocity:surface, rgb(0,0,1), "Vel", ship:velocity:surface:mag,true,0.01).
//	//set H_VelVecDraw to vecdraw(V(3,0,0),VHor, rgb(1,1,0), "H_Vel", VHor:mag,true,0.01).
//	set Z_VelVecDraw to vecdraw(V(3,0,0),VelZ, rgb(0,1,0), "Z_Vel", VelZ:mag,true,0.01).
//	set X_VelVecDraw to vecdraw(V(3,0,0),VelX, rgb(0,1,0), "H_X_Vel", VelX:mag,true,0.01).
//	set Y_VelVecDraw to vecdraw(V(3,0,0),VelY, rgb(0,1,0), "H_Y_Vel", VelY:mag,true,0.01).
//
//	//wait 0.
//}