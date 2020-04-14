clearscreen.
RUNPATH ("1:/libs.ks").

set next_step to "Set target". // list of allwaypoints
//set next_step to "Launch".
//set next_step to "Wait approach".
//set next_step to "Adjust impact pos".
//set next_step to "Land".

until next_step = "Launch" {
	set spot to WPT_COORD().
	if spot:length <> 1 {
		clearscreen.
		print "Select waypoint..." at (0,2).
		set cursor to spot:iterator.
		until not cursor:next {
			print cursor:value at (0,cursor:index + 3).
		}
		WAIT_VISUAL(5,0,0).
	} else {
		clearscreen.
		print spot[0] at (0,2).
		addons:tr:settarget(spot[0]:geoposition).
		set next_step to "Launch".
	}
}

print next_step at (0,3).