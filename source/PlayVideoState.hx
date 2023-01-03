package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if sys
import sys.FileSystem;
#end

class PlayVideoState extends MusicBeatState
{

	public static var videoID:String = 'credits3';

	override function create()
	{
		super.create();

        startVideo(videoID);
    }

   function goToMenu(){
        LoadingState.loadAndSwitchState(new AmongStoryMenuState(), true);
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
   }

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}


    public function startVideo(name:String):Void {

        var finishCallback:Void->Void;

		finishCallback = goToMenu; 
        
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
                finishCallback();
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
	}


}
