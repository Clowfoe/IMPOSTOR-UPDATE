package;

import flixel.FlxBasic;
import flixel.FlxG;
import sys.FileSystem;

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

		if (FileSystem.exists(SUtil.getStorageDirectory() + path))
			video.playVideo(SUtil.getStorageDirectory() + path, false, false);
		else
		{
			if (finishCallback != null)
				finishCallback();
		}
		#else
		if (finishCallback != null)
			finishCallback();
		#end
	}
}
