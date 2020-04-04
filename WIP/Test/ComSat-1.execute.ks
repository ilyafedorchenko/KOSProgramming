//Test orb period T change

runpath("1:/libs.ks").

set dT to 2. // seconds
set targetT to ship:orbit:period + dT.
TUNE_ORB_T(targetT).

WAIT_VISUAL(30,0,0).