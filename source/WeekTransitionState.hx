package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;

using StringTools;

class WeekTransitionState extends MusicBeatState
{
    /*
        this state is probably rlly dumb but its used as a bridge between playstate and loading
        a different week,,, , its kinda shitty but it works??
    */

    public static var _difficulty:Int = 1;
    public static var _week:Int = 0;

	override function create()
	{
		super.create();
        WeekData.reloadWeekFiles(true);

        // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[_week]).songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;

		var diffic = CoolUtil.difficultyStuff[_difficulty][1];
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = _difficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = _week;
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		LoadingState.loadAndSwitchState(new PlayState(), true);

        trace('yes');
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}


}
