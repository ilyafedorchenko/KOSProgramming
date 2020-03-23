//

runpath("1:/libs.ks").
//IF EXISTS("0:/solar.ks") {COPYPATH("0:/solar.ks", "1:/").}
clearscreen.
lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
until false {
	print "Solar orientation..." at (0,1).
	WAIT_VISUAL(30,0,0).
}