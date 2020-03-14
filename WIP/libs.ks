// All handy functions

FUNCTION WAIT_VISUAL{	// Visualize waiting period [###....]
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

	LOCAL f IS ShipEngines[NumberOfEngines - 1]:POSSIBLETHRUST * 1000. // Engine Thrust in Newtons (kg * m/s^2)
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

FUNCTION WPT_COORD {

LOCAL my_WPS TO ALLWAYPOINTS().
		FOR t in my_WPS {
			IF t:ISSELECTED {
				RETURN (t).
			}
		}
}


FUNCTION ApoBurn	//Считает угол к горизонту в апоцентре при циркуляризации.
{
	set Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.	//Считаем горизонтальную скорость
	set Vz to ship:verticalspeed. // это вертикальная скорость
	set Rad to ship:body:radius+ship:altitude. // Радиус орбиты.
	set Vorb to sqrt(ship:body:Mu/Rad). //Это 1я косм. на данной высоте.
	set g_orb to ship:body:Mu/Rad^2. //Ускорение своб. падения на этой высоте.
	set ThrIsp to EngThrustIsp(). //EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
	set AThr to ThrIsp[0]*Throttle/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
	set ACentr to Vh^2/Rad. //Центростремительное ускорение.
	set DeltaA to g_orb-ACentr-Max(Min(Vz,2),-2). //Уск своб падения минус центр. ускорение с поправкой на гашение вертикальной скорости.
	set Fi to arcsin(DeltaA/AThr). // Считаем угол к горизонту так, чтобы держать вертикальную скорость = 0.
	set dVh to Vorb-Vh. //Дельта до первой косм.
	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).	//Возвращаем лист с данными.
}

FUNCTION ANBurn	//Считает угол к нормали и dV для маневра по наклонению орбиты.
{
	PARAMETER Vorb. 	//Текущая орбитальная скорость
	PARAMETER dINCL.	//Угол увеличения наклонения

	SET dVz TO sin(dINCL)*Vorb. //Вертиальный компонент изменения скорости
	SET dVretro TO (1-cos(dINCL))*Vorb. // Горизонтальный ретро компонент изменения скорости

	SET dVorb TO SQRT(dVz^2+dVretro^2).
	SET Fi TO arctan(dVretro/dVz).
	
	RETURN LIST(Fi, dVorb).	//Возвращаем лист с данными.
}

FUNCTION EngThrustIsp	//EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
{
	//создаем пустой лист ens
  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
	//запихиваем все движки в лист myengines
  list engines in myengines.
	
	//забираем все активные движки из myengines в ens.
  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
	//собираем суммарную тягу и Isp по всем активным движкам
  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }
  //Тягу возвращаем суммарную, а Isp средний.
  RETURN LIST(ens_thrust, ens_isp/ens:length).
}



