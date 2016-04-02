//==============================================
//  traditional vocal beaming
//
//  Copyright (C)2016 Jörn Eichler (heuchi) 
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//==============================================

import QtQuick 2.0
import MuseScore 1.0

MuseScore {
    version:  "1.0"
    description: "This plugin creates traditional vocal beams, i.e. beams only on melismas."
    menuPath: "Plugins.Traditional Vocal Beaming"

    onRun: {
	if (typeof curScore === 'undefined')
	    Qt.quit();
	
	var cursor = curScore.newCursor();
	cursor.rewind(1);
	
	var startStaff;
	var endStaff;
	var endTick;
	var fullScore = false;
	
	if (!cursor.segment) { // no selection
	    fullScore = true;
	    startStaff = 0; // start with 1st staff
	    endStaff = curScore.nstaves - 1; // and end with last
	} else {
	    startStaff = cursor.staffIdx;
	    cursor.rewind(2);
	    if (cursor.tick == 0) {
		// this happens when the selection includes
		// the last measure of the score.
		// rewind(2) goes behind the last segment (where
		// there's none) and sets tick=0
		endTick = curScore.lastSegment.tick + 1;
	    } else {
		endTick = cursor.tick;
	    }
	    endStaff = cursor.staffIdx;
	}

	var hasLyrics;
	
	for (var staff = startStaff; staff <= endStaff; staff++) {
	    for (var voice = 0; voice < 4; voice++) {
		cursor.rewind(1); // sets voice to 0
		cursor.voice = voice; //voice has to be set after goTo
		cursor.staffIdx = staff;
		
		if (fullScore)
		    cursor.rewind(0) // if no selection, beginning of score
		
		var lastChord = null;
		hasLyrics = false;
		
		while (cursor.segment && (fullScore || cursor.tick < endTick)) {
		    if (cursor.element && cursor.element.type == Element.CHORD) {
			var lyrics = cursor.element.lyrics;

			if (lyrics.length == 0) {
			    if (lastChord != null && hasLyrics) {
				// set last chord to "BEGIN", if it existed
				lastChord.beamMode = 1;
			    }
			    // don't change anything for this chord
			    lastChord = null;
			} else {
			    hasLyrics = true;
			    // found lyrics
			    if (lastChord != null) {
				// set last chord to "BEGIN", if it existed
				lastChord.beamMode = 1;
			    }
			    // remember this chord
			    lastChord = cursor.element;
			}

			if (hasLyrics) {
			    // reset beaming to auto for current chord
			    cursor.element.beamMode = 0;
			}
		    }
		    cursor.next();
		}
		if (lastChord != null) {
		    // set last chord to "NONE", if it existed
		    lastChord.beamMode = 4;
		}
	    }
	}
	
	Qt.quit();
    }
}
