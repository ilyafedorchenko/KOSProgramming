RUNPATH ("1:/libs.ks").

SET my_WPS TO ALLWAYPOINTS().

UNTIL FALSE {

		FOR t in my_WPS {
			IF t:ISSELECTED {
				CLEARSCREEN.
				PRINT "Name: " 							+ t:NAME.
				PRINT "GEOPOSITION LAT: " 				+ t:GEOPOSITION:LAT.
				PRINT "GEOPOSITION LNG: " 				+ t:GEOPOSITION:LNG.
				PRINT "GEOPOSITION DISTANCE: " 			+ t:GEOPOSITION:DISTANCE.
				PRINT "GEOPOSITION TERRAINHEIGHT: " 	+ t:GEOPOSITION:TERRAINHEIGHT.
				PRINT "GEOPOSITION HEADING: " 			+ t:GEOPOSITION:HEADING.
				PRINT "GEOPOSITION BEARING: " 			+ t:GEOPOSITION:BEARING.
			}
		}

WAIT 1.
}
