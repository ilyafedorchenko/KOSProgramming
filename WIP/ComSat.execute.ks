CLEARSCREEN.

PRINT "Found execution file".

LOG "Hello" to mylog.ks.    // logs to "mylog.txt".
LOG 4+1 to "mylog".         // logs to "mylog.ks" because .ks is the default extension.
LOG "4 times 8 is: " + (4*8) to mylog.   // logs to mylog.ks because .ks is the default extension.

LIST.

DOWNLOAD("mylog.ks").