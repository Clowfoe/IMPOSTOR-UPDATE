package;

import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic
{
	public var finishCallback:Void->Void = null;

	public function new(path:String)
	{
		super();

		#if VIDEOS_ALLOWED
		var video:VideoHandler = new VideoHandler();
		video.canSkip = false;
		video.finishCallback = function()
		{
			if (finishCallback != null)
				finishCallback();
		}
		video.playVideo(SUtil.getStorageDirectory() + path, false, false);
		#else
		if (finishCallback != null)
			finishCallback();
		#end
	}
}
