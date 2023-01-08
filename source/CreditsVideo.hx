package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

using StringTools;

class CreditsVideo extends FlxState
{
	override public function create():Void
	{
		super.create();

		#if VIDEOS_ALLOWED
		var video:VideoHandler = new VideoHandler();
		video.canSkip = false;
		video.finishCallback = next;
		video.playVideo(SUtil.getStorageDirectory() + Paths.video('credits'), false, false);
		#else
		next();
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function next():Void
	{
		FlxG.switchState(new TitleState());
	}
}
