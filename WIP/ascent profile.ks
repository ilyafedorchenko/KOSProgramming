//

FUNCTION BURN_CLEAR {
	PARAMETER start_thrott

	// start burn with thrott.
	// when for stage empty
	// check if next stage has throttle (ship total throttle > 0)
	// stage.


}

FUNCTION EXEC_ASC_PROFILE {
	PARAMETER profile_list
	// call BURN_CLEAR(start_thrott)

	//		set profile_line to 0
	//		set proflie_col_num to 4
	//		set alt_col to 0
	//		set bear_col to 1
	//		set incl_col to 2 
	//		set throt_col to 3
	//
	// loop checking ALT according to proflist[alt_col+line]
	//		check existance of nex_alt if ok - set next_alt to proflist[alt_col+line+1]	
	//		lock STEERING to HEADING(proflist[bear_col+line],proflist[incl_col+line]))
	//		lock throttle to profilelist[throt_col+line]
	//		
	//		
	// wait 
	// throt to 0
	// print end asc profile


}

SET ASCENT_PROFILE TO LIST (
//ALT, 	BEARING,	INCLINATION,	THROT
0,			0,			90,				1.0,
10000,		0,			80,				1.0,
30000,		0,			70,				0.5,
60000,		0,			40,				0.3,
70000,		0,			0,				0.1,
).





