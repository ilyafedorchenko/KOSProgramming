
//=============================================
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

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

FUNCTION HAS_FILE_EXECUTE {	//result - true or false whether update file exists in CommandCenter
							//empty param HAS_FILE_EXECUTE("","")
	PARAMETER file_path. 	//path "execute_on_ship/shipname.execute.ks"
	PARAMETER vol.			// 1 or 0(Archive)
	
	LOCAL file_path_ IS "execute_on_ship/" + execute_script.
	LOCAL vol_ IS "0".

	IF file_path <> "" {
		SET file_path_ TO file_path.
		SET vol_ TO vol.
	}
	RETURN EXISTS(vol_+":/"+file_path_).
}

FUNCTION DOWNLOAD_UPDATE{	//result - file 1:/execute.ks ready for execution
							//empty param HAS_FILE_EXECUTE("","")
	PARAMETER file_path. 	//path "execute_on_ship/shipname.execute.ks"
	PARAMETER vol.			// 1 or 0(Archive)
	
	LOCAL file_path_ IS "execute_on_ship/" + execute_script.
	LOCAL vol_ IS "0".

	IF file_path <> "" {
		SET file_path_ TO file_path.
		SET vol_ TO vol.
	}
	MOVEPATH(vol_ + ":/" + file_path_, "1:/execute.ks").
}

FUNCTION UPLOAD{	//result - file uploaded to recieved_from_ship/ in CommandCenter
	PARAMETER file_path. 	//path "anydir/upload.txt"
	
	MOVEPATH("1:/" + file_path, "0:/recieved_from_ship/" + SHIP:NAME + ".upload.txt").
}

// First-pass at introducing artificial delay. ADDONS:RT:DELAY(SHIP) represents
// the line-of-site latency to KSC, as per RemoteTech
FUNCTION DELAY{
  SET dTime TO ADDONS:RT:DELAY(SHIP) * 3. // Total delay time
  SET accTime TO 0.                       // Accumulated time

  UNTIL accTime >= dTime {
    SET start TO TIME:SECONDS.
    WAIT UNTIL (TIME:SECONDS - start) > (dTime - accTime) OR NOT ADDONS:RT:HASCONNECTION(SHIP).
    SET accTime TO accTime + TIME:SECONDS - start.
  }
}

//============================MAIN LOOP=========================================

SET execute_script TO SHIP:NAME + ".execute.ks".
SWITCH TO 1.

// Cleanup local disk after reboot
IF HAS_FILE_EXECUTE("execute.ks", 1){
	DELETEPATH("1:/execute.ks").
}

CLEARSCREEN.
PRINT "Waiting for execution script." AT(0,1).
PRINT "Local scripts:" AT(0,2).
LIST.

IF ADDONS:RT:HASCONNECTION(SHIP) {
	PRINT "Scripts in archive:".
	CD("0:/execute_on_ship/").
	LIST.
	SWITCH TO 1.
}

ON Abort {
    clearscreen.
    print "Aborting!" AT(0,1).
    unlock all.
    runpath("1:/abort.ks").
    return false.
}

// If we have a connection, see if there are new instructions. If so, download
// and run them.

IF ADDONS:RT:HASCONNECTION(SHIP) {
	IF EXISTS("0:/abort.ks") {COPYPATH("0:/abort.ks", "1:/").}
	IF EXISTS("0:/libs.ks") {COPYPATH("0:/libs.ks", "1:/").}
	IF EXISTS("0:/exec_node.ks") {COPYPATH("0:/exec_node.ks", "1:/").}
	IF EXISTS("0:/solar.ks") {COPYPATH("0:/solar.ks", "1:/").}
	IF HAS_FILE_EXECUTE("","") {
		DOWNLOAD_UPDATE("","").
		RUNPATH("1:/execute.ks").
		DELETEPATH("1:/execute.ks").
	}
}

WAIT_VISUAL(10,0,0). 	// Avoid thrashing the CPU (when no startup.ks, but we have a
        				// persistent connection, it will continually reboot).

WAIT UNTIL ADDONS:RT:HASCONNECTION(SHIP).
REBOOT.