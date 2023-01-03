package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

using StringTools;

class CreditsVideo extends FlxState
{
	var oldFPS:Int = VideoHandler.MAX_FPS;
	var video:VideoHandler;
	var titleState = new TitleState();

	override public function create():Void
	{

		super.create();

		VideoHandler.MAX_FPS = 60;

		video = new VideoHandler();

		video.playMP4(Paths.video('credits'), function(){
			next();
			#if web
				VideoHandler.MAX_FPS = oldFPS;
			#end
		}, false, false);

		video.width = 1280;
		video.height = 720;
		video.updateHitbox();
		video.setPosition(0,0);

		add(video);
	}

	override public function update(elapsed:Float){

		super.update(elapsed);

	}

	function next():Void{
		FlxG.switchState(titleState);
	}
	
}
