// All handy functions

FUNCTION WAIT_VISUAL{	// Visualize waiting period in seconds [###....]
	PARAMETER t. //How much seconds to wait
	PARAMETER col_. // AT (col_,)
	PARAMETER row_. // AT (,row_)

	LOCAL scale IS "".

	FROM {LOCAL x IS 0.} UNTIL x = t STEP {SET x TO x + 1.} DO {
		SET scale TO scale + ".".
	}

	PRINT "[" + scale + "]" AT (col_, row_). // draw scale to fill

	FROM {LOCAL x IS 1.} UNTIL x = t+1 STEP {SET x TO x + 1.} DO {
		PRINT "#" AT (col_ + x, row_).
		WAIT 1.
	}
}

FUNCTION ISH {	// RETURNS TRUE if actual value is within tolerance delat (in %) of target value
	PARAMETER target_value.		// 
	PARAMETER actual_value.		// 
	PARAMETER error_tolerance.	// in %

	IF ABS(target_value - actual_value)/target_value < error_tolerance {
		RETURN TRUE.
	} ELSE {
		RETURN FALSE.
	}
}

FUNCTION ORB_VEL {	//Orbital velocity for specific height of the orbit
	PARAMETER targeted_h.
	RETURN ROUND(SQRT(BODY:Mu / (BODY:RADIUS + targeted_h)), 2).
}

FUNCTION dV_CALC_HOHMANN {	// Calcs dV for to consecutive burns to reach desired orbit altitude
	PARAMETER r1. // initial orbit
	PARAMETER r2. // target orbit
	
	// Mu - gravetational parameter of the body
	

	LOCAL dV1 IS ORB_VEL(r1) * (SQRT(2 * (r2 + BODY:RADIUS)/(r1 + r2 + 2 * BODY:RADIUS)) - 1).
	LOCAL dV2 IS ORB_VEL(r2) * (1 - SQRT(2 * (r1 + BODY:RADIUS)/(r1 + r2 + 2 * BODY:RADIUS))).

	RETURN LIST(dV1, dV2).
}

FUNCTION r2_CALC_HOHMANN { 	// Calcs new Ap/Pe (r2) to change orbit half-period to desired Th
	parameter r1. // initial orbit - ship:altitude
	parameter Th. // target Th half-period
	
	// Mu - gravetational parameter of the body
	
	local r2 is 2 * (ship:body:Mu * (Th / constant:pi)^2)^(1/3) - (ship:body:radius + r1).

	return (r2 - ship:body:radius).
}

FUNCTION TIME_CALC_MNV {	// Calc time in sec to burn for given dV
	parameter dV.

	set ActiveEngThrustIsp to ENGTHRUSTISP().

	local f is ActiveEngThrustIsp[0] * 1000. // Engine Thrust in Newtons (kg * m/s^2)
	local m is ship:mass * 1000.	// Staring mass (kg)
	local e is constant:e.			// Base of natural log
	local p is ActiveEngThrustIsp[1].	// Engines Isp (s)
	local g is constant:g0.			// Grav accel consdtant

	return g * m * p * (1 - e^(-abs(dV) / (g * p))) / f.
}

FUNCTION dV_CALC_SHIP {	// Calc total dV for current first Engine of all Engines. Engine should be activated
	LIST ENGINES IN ShipEngines.
	LOCAL NumberOfEngines IS ShipEngines:LENGTH.

	LOCAL DryMass IS SHIP:MASS - ((SHIP:LIQUIDFUEL + SHIP:OXIDIZER) * 0.005).
	RETURN ROUND(ShipEngines[NumberOfEngines - 1]:ISP * CONSTANT:g0 * LN(SHIP:MASS / SHIP:DryMass), 2).
}

FUNCTION TIMER { // Returns TRUE when some time in future reached
	PARAMETER t1. // time in future
	IF (t1 - TIME:SECONDS <= 0) {
		RETURN TRUE.
	} ELSE {
		RETURN FALSE.
	}
}

FUNCTION WPT_COORD { // Returns WAYPOINT structure for selected WAYPOINT

	LOCAL my_WPS TO ALLWAYPOINTS().
			FOR t in my_WPS {
				IF t:ISSELECTED {
					RETURN (t).
				}
			}
}

FUNCTION APOBURN {	// Считает угол к горизонту в апоцентре при циркуляризации.
	set Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.	// Считаем горизонтальную скорость
	set Vz to ship:verticalspeed. 								// это вертикальная скорость
	set Rad to ship:body:radius+ship:altitude. 					// Радиус орбиты.
	set Vorb to sqrt(ship:body:Mu/Rad).							// Это 1я косм. на данной высоте.
	set g_orb to ship:body:Mu/Rad^2.							// Ускорение своб. падения на этой высоте.
	set ThrIsp to EngThrustIsp().								// EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
	set AThr to ThrIsp[0]*Throttle/(ship:mass).					// Ускорение, которое сообщают ракете активные двигатели при тек. массе.
	set ACentr to Vh^2/Rad.										// Центростремительное ускорение.
	set DeltaA to g_orb-ACentr-Max(Min(Vz,2),-2).				// Уск своб падения минус центр. ускорение с поправкой на гашение вертикальной скорости.
	if AThr = 0 
		set Fi to 0. 
	else 
		set Fi to arcsin(DeltaA/AThr).							// Считаем угол к горизонту так, чтобы держать вертикальную скорость = 0.
	set dVh to Vorb-Vh.											// Дельта до первой косм.
	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).					// Возвращаем лист с данными.
}

FUNCTION ANBURN	{	// Считает угол к нормали и dV для маневра по наклонению орбиты. Работает пока не очень (не удается сохранить окружность орбиты, апоцентр растет, надо тестировать)
	PARAMETER Vorb. 											// Текущая орбитальная скорость
	PARAMETER dINCL.											// Угол увеличения наклонения

	SET dVz TO -VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION).		// Вектор нормаль к плоскости орбиты
	SET dVz:MAG TO sin(dINCL)*Vorb.								// Вертиальный компонент изменения скорости
	SET dVretro TO SHIP:RETROGRADE:VECTOR.
	SET dVretro:MAG TO (1-cos(dINCL))*Vorb.						// Горизонтальный ретро компонент изменения скорости
	SET dVorb TO dVz + dVretro.									// Вектор для маневра
	SET Fi TO arctan(dVretro:MAG/dVz:MAG).						// Угол отклонения от нормали
	
	RETURN LIST(Fi, dVorb).										// Возвращаем лист с данными.
}

FUNCTION TAGGEDTANKSRESCOUNT { // Returns amount of resources[0] in tanks with givven tag
	PARAMETER _tag.

	SET FuelAmount TO 0.
	SET ASC_TANKS TO SHIP:PARTSTAGGED("ascent").
	FOR TNK IN ASC_TANKS {
		SET FuelAmount TO FuelAmount + TNK:RESOURCES[0]:AMOUNT.
	}
	RETURN FuelAmount.
}

FUNCTION ENGTHRUSTISP {	// EngThrustIsp возвращает list(суммарную тягу, средний Isp) по всем активным двигателям.
	//создаем пустой лист ens
  set ens to ACTIVEENGINES().
  set ens_thrust to 0.
  set ens_isp to 0.
  
	//собираем суммарную тягу и Isp по всем активным движкам
  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }
  //Тягу возвращаем суммарную, а Isp средний.
  RETURN LIST(ens_thrust, ens_isp/ens:length).
}

FUNCTION CIRC_MNV {	// Функция завершения вывода корабля на орбиту планеты - скругления орбиты
		
	//Ждем апоапсиса
	clearscreen.
	UNTIL ETA:APOAPSIS < 1 {PRINT "ETA:Apo: " + ETA:APOAPSIS AT (0,1).}
		
	//Начинаем циркуляризацию
	LOCK THROTTLE to 1.
	set CircData to APOBurn(). //Достаем данные по тангажу и прочее из функции ApoBurn 
	set StopBurn to false.

	UNTIL CircData[4]<0.01 {
		
		set CircData to ApoBurn(). //Достаем данные по тангажу и прочее из функции ApoBurn

		LOCK THROTTLE to MIN (CircData[4]/100, 1). // Управляем тягой, если осталось меньше 100dV, то снижаем пропорционально
		LOCK STEERING to PROGRADE + R(0,CircData[0],0). //Угол тагажа выставляем по данным, возвращенным функцией

		print "Fi: "		+	CircData[0] AT(0,3).	
		print "Vh: "		+	CircData[1] AT(0,4).
		print "Vz: "		+	CircData[2] AT(0,5).	
		print "Vorb: "		+	CircData[3] AT(0,6).	
		print "dVh: "		+	CircData[4] AT(0,7).		
		print "DeltaA: "	+	CircData[5] AT(0,8).

		// Что возвращает ApoBurn
		//				0	1	2   3     4    5 			
		//	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).

		WAIT 0.
	}
	
	unlock all.
	LOCK Throttle to 0. //Мы на орбите, выключаем тягу.
}

FUNCTION ACTIVEENGINES { //Returns list() of active engines
	set ens to list().

	ens:clear.
	list engines in myengines.
	
	//забираем все активные движки из myengines в ens.
	for en in myengines {
		if en:ignition = true and en:flameout = false {
		ens:add(en).
		}
	}

	return ens.
}

FUNCTION ACTIVEENGINES_THR_LIM { //Adjust thr limit for all active engines [0..100]
	parameter thr_lim.

	set ens to ACTIVEENGINES().

	for en in ens {
		set en:thrustlimit to thr_lim.
	}
}

FUNCTION PHASEANGLE_TO_VESS { // Returns phase angle from scurrent vessel to targe vessel, orbiting the same body
	parameter targ_ves_name. // target name - string

	set targ_Vess to vessel(targ_ves_name).
	set a to ship:orbit:position - ship:orbit:body:position.
	set b to targ_Vess:orbit:position - targ_Vess:orbit:body:position.
	set ab_cross to vcrs(a,b).

	set ship_vel to ship:velocity:orbit.
	set ship_vel_normal to vcrs(ship_vel,a).
	set PhaseAngle to vang(a,b).

	if vdot(ab_cross,ship_vel_normal) > 0 {set PhaseAngle to 360 - PhaseAngle.}

  	return PhaseAngle. // degrees
}

FUNCTION TUNE_ORB_T { // Tune orbit period T to target value in sec. Precision 0.001 sec

	parameter _targetT. // parameter target orbit period in seconds

	clearscreen.
	
	if _targetT > ship:orbit:period {
		lock steering to prograde.	
	} else if _targetT < ship:orbit:period {
		lock steering to retrograde.	
	} else {
		reboot.
	}
	
	WAIT_VISUAL(20,0,0).
	
	print "Orbite period	 : " + ship:orbit:period at (0,1).
	print "Target orb period : " + _targetT at (0,2).
	
	set dTcoeff to 100. //abs(ship:orbit:period - _targetT) / ship:orbit:period.
	set enlist to ACTIVEENGINES().
	for en in enlist {
		set en:thrustlimit to dTcoeff.
	}
	
	lock throttle to 1.
	
	until ISH(_targetT, ship:orbit:period, 0.0000001){
		print "Orbite period: " + ship:orbit:period at (0,3).
		print "Err: " + abs(ship:orbit:period - _targetT) at (0,4).
	
		if abs(ship:orbit:period - _targetT) < 1 {
			lock throttle to 0.1.//round(abs(ship:orbit:period - _targetT),1).
			
			if abs(ship:orbit:period - _targetT) < 0.1 {
				lock throttle to 0.01.//round(abs(ship:orbit:period - _targetT),1).
			}
		}
	
		wait 0.
	}
	
	lock throttle to 0.	
}