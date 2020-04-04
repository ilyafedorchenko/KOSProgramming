// Adjust orbit period to target_Vess


RUNPATH ("1:/libs.ks").

set target_Vess to vessel("ComSat-3").


TUNE_ORB_T(target_Vess:orbit:period).

print "Script execution completed." at (0,15).
lock steering to prograde + R(-90,0,0). //Orient solar panels to the Kerbol-Sun
WAIT_VISUAL(10,0,0).