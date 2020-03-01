
//=============================================
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

FUNCTION ABORT_FUNC {
	LOCK THROTTLE TO 0.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	UNTIL stage:nextDecoupler = "None" {
    	STAGE.
    }
    STAGE.
    LOCK STEERING TO SRFRETROGRADE.
    WHEN (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") THEN { 	//Didn't work, I guess, reboot was the cause
    	UNLOCK ALL.														// Check if call of separate script will work better
    	PRINT "Flight complete".

    }
}

FUNCTION HAS_FILE_EXECUTE{	//result - true or false whether update file exists in CommandCenter
							//empty param HAS_FILE_EXECUTE("","")
	PARAMETER file_path. 	//path "execute_on_ship/shipname.execute.ks"
	PARAMETER vol.			// 1 or 0(Archive)
	
	IF file_path = "" {
		SET file_path_ TO "execute_on_ship/" + execute_script.
		SET vol_ to "0".
	} ELSE {
		SET file_path_ TO file_path.
		SET vol_ to vol.
	}
	RETURN EXISTS(vol_+":/"+file_path_).
}

FUNCTION DOWNLOAD_UPDATE{	//result - file 1:/execute.ks ready for execution
							//empty param HAS_FILE_EXECUTE("","")
	PARAMETER file_path. 	//path "execute_on_ship/shipname.execute.ks"
	PARAMETER vol.			// 1 or 0(Archive)
	
	IF file_path = "" {
		SET file_path_ TO "execute_on_ship/" + execute_script.
		SET vol_ to "0".
	} ELSE {
		SET file_path_ TO file_path.
		SET vol_ to vol.
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

//==============================================

SET execute_script TO SHIP:NAME + ".execute.ks".
SWITCH TO 1.

// Cleanup local disk after reboot
IF HAS_FILE_EXECUTE("execute.ks", 1){
	DELETEPATH("1:/execute.ks").
}

PRINT "Waiting for execution script.".

IF ABORT {
    PRINT "Aborting!".
    ABORT_FUNC().
}

// If we have a connection, see if there are new instructions. If so, download
// and run them.

IF ADDONS:RT:HASCONNECTION(SHIP) {
	IF HAS_FILE_EXECUTE("","") {
		DOWNLOAD_UPDATE("","").
		RUNPATH("1:/execute.ks").
		DELETEPATH("1:/execute.ks").
	}
}

// If a startup.ks file exists on the disk, run that.
IF HAS_FILE_EXECUTE("startup.ks", 1) {
  RUNPATH("1:/startup.ks").
} ELSE {
  WAIT UNTIL ADDONS:RT:HASCONNECTION(SHIP).
  WAIT 10. // Avoid thrashing the CPU (when no startup.ks, but we have a
           // persistent connection, it will continually reboot).
  REBOOT.
}