runpath("1:/libs.ks").

lock throttle to prograde.

// increase orbit period 1 minute

set dT to 5. // seconds
set targetT to ship:orbit:period + dT.
lock max_acc to ship:maxthrust/ship:mass.  // ship accel

print "Orbite period: " + ship:orbit:period at (0,1).
print "Increase up to:" + targetT at (0,2).

set enlist to ACTIVEENGINES().
set enlist[0]:thrustlimit to 1.

lock throttle to 1.
wait until ISH(targetT, ship:orbit:period, 0.000001).

print "Orbite period: " + ship:orbit:period at (0,3).
print "Err: " + abs(ship:orbit:period - targetT) at (0,4).

WAIT_VISUAL(30,0,0).