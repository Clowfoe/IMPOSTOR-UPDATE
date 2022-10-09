package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var ROWS_PER_BEAT = 48; // from Stepmania
	public static var BEATS_PER_MEASURE = 4; // TODO: time sigs
	public static var ROWS_PER_MEASURE = ROWS_PER_BEAT * BEATS_PER_MEASURE; // from Stepmania
	public static var MAX_NOTE_ROW = 1 << 30; // from Stepmania

	public inline static function beatToRow(beat:Float):Int
		return Math.round(beat * ROWS_PER_BEAT);

	public inline static function rowToBeat(row:Int):Float
		return row / ROWS_PER_BEAT;

	public inline static function secsToRow(sex:Float):Int
		return Math.round(getBeat(sex) * ROWS_PER_BEAT);

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function getBPMFromStep(step:Float)
		{
			var lastChange:BPMChangeEvent = {
				stepTime: 0,
				songTime: 0,
				bpm: bpm
			}
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (Conductor.bpmChangeMap[i].stepTime <= step)
					lastChange = Conductor.bpmChangeMap[i];
			}
	
			return lastChange;
		}
		
		public static function getBPMFromSeconds(time:Float)
		{
			var lastChange:BPMChangeEvent = {
				stepTime: 0,
				songTime: 0,
				bpm: bpm
			}
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (time >= Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];
			}
	
			return lastChange;
		}
	
		
		public static function stepToSeconds(step:Float)
		{
			var lastChange = getBPMFromStep(step);
			return step * (((60 / lastChange.bpm) * 1000) / 4); // TODO: make less shit and take BPM into account PROPERLY
		}
	
		public static function beatToSeconds(beat:Float)
		{
			var step = beat * 4;
			var lastChange = getBPMFromStep(step);
			return lastChange.songTime
				+
				((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000; // step * (lastChange.stepCrochet*4); // TODO: make less shit and take BPM into account PROPERLY
		}
	
		public static function getStep(time:Float)
		{
			var lastChange = getBPMFromSeconds(time);
			return lastChange.stepTime + (time - lastChange.songTime) / (((60 / lastChange.bpm) * 1000) / 4);
		}
	
		public static function getStepRounded(time:Float)
		{
			var lastChange = getBPMFromSeconds(time);
			return lastChange.stepTime + Math.floor(time - lastChange.songTime) / (((60 / lastChange.bpm) * 1000) / 4);
		}
	
		public static function getBeat(time:Float)
		{
			return getStep(time) / 4;
		}
	
		// public static function judgeNote(note:Note, diff:Float=0) //STOLEN FROM KADE ENGINE (bbpanzu) - I had to rewrite it later anyway after i added the custom hit windows lmao (Shadow Mario)
		// {
		// 	//tryna do MS based judgment due to popular demand
		// 	var timingWindows:Array<Int> = [ClientPrefs.sickWindow, ClientPrefs.goodWindow, ClientPrefs.badWindow];
		// 	var windowNames:Array<String> = ['sick', 'good', 'bad'];
	
		// 	// var diff = Math.abs(note.strumTime - Conductor.songPosition) / (PlayState.songMultiplier >= 1 ? PlayState.songMultiplier : 1);
		// 	for(i in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		// 	{
		// 		if (diff <= timingWindows[Math.round(Math.min(i, timingWindows.length - 1))])
		// 		{
		// 			return windowNames[i];
		// 		}
		// 	}
		// 	return 'shit';
		// }
		
	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
