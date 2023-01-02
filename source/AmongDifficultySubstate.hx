import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

class AmongDifficultySubstate extends MusicBeatSubstate
{
	private static var curDifficulty:Int = 2;

	private var selectedSong:String;
	private var curWeek:Int;

	// hey please automate this sometime soon I'm not a fan of hardcoding this
	public static var songsWithMissLimits:Array<String> = ['defeat'];

	var blackBG:FlxSprite;
	var missAmountArrow:FlxSprite;
	var missTxt:FlxText;
	public var dummySprites:FlxTypedGroup<FlxSprite>;
	public var maximumMissLimit:Int = 5;

	public var camUpper:FlxCamera;
	public var camOther:FlxCamera;

	public function new(curWeek:Int, selectedSong:String)
	{
		super();

		this.curWeek = curWeek;
		this.selectedSong = selectedSong;

		camUpper = new FlxCamera();
		camOther = new FlxCamera();
		camUpper.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camUpper);
		FlxG.cameras.add(camOther);

		cameras = [camUpper];
		CustomFadeTransition.nextCamera = camOther;

		curDifficulty = 2;
		changeDiff(0);
		
		blackBG = new FlxSprite().makeGraphic(1400, 1400, 0xFF000000);
		blackBG.screenCenter(XY);
		blackBG.alpha = 0;
		add(blackBG);

		// miss limit stuff
		dummySprites = new FlxTypedGroup<FlxSprite>();
		for (i in 0...6)
		{
			var dummypostor:FlxSprite = new FlxSprite((i * 150) + 200, 450).loadGraphic(Paths.image('freeplay/dummypostor${i + 1}', 'impostor'));
			dummypostor.alpha = 0;
			dummypostor.ID = i;
			dummySprites.add(dummypostor);
			switch(i){
				case 2 | 3:
					dummypostor.y += 40;
				case 4 | 5:
					dummypostor.y += 65;
			}
		}
		add(dummySprites);

		missAmountArrow = new FlxSprite(0, 400).loadGraphic(Paths.image('freeplay/missAmountArrow', 'impostor'));
		missAmountArrow.alpha = 0;
		add(missAmountArrow);

		missTxt = new FlxText(0, 150, FlxG.width, "", 20);
		missTxt.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.antialiasing = false;
        missTxt.scrollFactor.set();
		missTxt.alpha = 0;
		missTxt.borderSize = 3;
        add(missTxt);

		changeMissAmount(0);

		if (!songsWithMissLimits.contains(selectedSong.toLowerCase()))
		{
			var songLowercase:String = Paths.formatToSongPath(selectedSong.toLowerCase());
			trace(selectedSong);

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = curWeek;

			var diffic:String = '-hard';
				
			var poop:String = Highscore.formatSong(songLowercase, 1);
			PlayState.SONG = Song.loadFromJson(poop + diffic, songLowercase);

			FlxTween.tween(camUpper, {alpha: 0}, 0.25, {
				ease: FlxEase.circOut,
				onComplete: function(tween:FlxTween)
				{
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
					LoadingState.loadAndSwitchState(new PlayState());
				}
			});
		}
		else
			openMissLimit();
	}

	public var canControl:Bool = false;
	public var hasEnteredMissSelection:Bool = false;
	public var isClosing:Bool = false;

	override public function update(elapsed:Float)
	{
		if (canControl && !isClosing)
		{
			var rightP = controls.UI_RIGHT_P;
			var leftP = controls.UI_LEFT_P;
			var accepted = controls.ACCEPT;
			//

			if(accepted){
				if(!songsWithMissLimits.contains(selectedSong.toLowerCase()) || hasEnteredMissSelection){
					var songLowercase:String = Paths.formatToSongPath(selectedSong.toLowerCase());
					trace(selectedSong);

					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					PlayState.storyWeek = curWeek;

					var diffic:String = '-hard';
						
					var poop:String = Highscore.formatSong(songLowercase, 1);
					PlayState.SONG = Song.loadFromJson(poop + diffic, songLowercase);

					FlxTween.tween(camUpper, {alpha: 0}, 0.25, {
						ease: FlxEase.circOut,
						onComplete: function(tween:FlxTween)
						{
							trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
							LoadingState.loadAndSwitchState(new PlayState());
						}
					});
				}
			}

			if (rightP)
			{
				if (hasEnteredMissSelection)
					changeMissAmount(-1);
				FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
			}
			//
			if (leftP)
			{
				if (hasEnteredMissSelection)
					changeMissAmount(1);
				FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.5);
			}
		}
		else
			canControl = true;
	}

	function changeMissAmount(change:Int)
	{
		PlayState.missLimitCount += change;
		if (PlayState.missLimitCount > maximumMissLimit)
			PlayState.missLimitCount = 0;
		if (PlayState.missLimitCount < 0)
			PlayState.missLimitCount = maximumMissLimit;

		dummySprites.forEach(function(spr:FlxSprite)
		{
			if((5 - spr.ID) == PlayState.missLimitCount){
				missAmountArrow.x = spr.x;
				missTxt.text = '${PlayState.missLimitCount}/5 COMBO BREAKS';
				missTxt.x = ((FlxG.width / 2) - (missTxt.width / 2));
			}
		});
	}

	function changeDiff(change:Int)
	{
		curDifficulty += change;

		if (curDifficulty > 2)
			curDifficulty = 0;
		if (curDifficulty < 0)
			curDifficulty = 2;
	}

	function openMissLimit()
	{
		FlxTween.tween(blackBG, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missAmountArrow, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missTxt, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		dummySprites.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		});
		hasEnteredMissSelection = true;
	}
}
