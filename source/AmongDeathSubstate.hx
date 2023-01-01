import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

class AmongDeathSubstate extends MusicBeatSubstate
{
	public static var songsWithMissLimits:Array<String> = ['defeat'];

	var missAmountArrow:FlxSprite;
	var missTxt:FlxText;
	public var dummySprites:FlxTypedGroup<FlxSprite>;
	public var maximumMissLimit:Int = 5;

	public var camUpper:FlxCamera;
	public var camOther:FlxCamera;

	public function new()
	{
		super();

		camUpper = new FlxCamera();
		camOther = new FlxCamera();
		camUpper.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camUpper);
		FlxG.cameras.add(camOther);

		cameras = [camUpper];
		CustomFadeTransition.nextCamera = camOther;

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
		openMissLimit();
	}

	public var canControl:Bool = false;
	public var hasEnteredMissSelection:Bool = false;
	public var isClosing:Bool = false;

	override public function update(elapsed:Float)
	{	
		var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
		var accepted = controls.ACCEPT;

		if(accepted && hasEnteredMissSelection == true)
		{
			FlxG.sound.play(Paths.sound('amongkill', 'impostor'), 0.9);
			hasEnteredMissSelection = false;
			close();

			var blackScreen:FlxSprite = new FlxSprite().makeGraphic(1920, 1080, FlxColor.BLACK);
			add(blackScreen);

			missTxt.alpha = 0;
		 	missAmountArrow.alpha = 0;

		 	dummySprites.forEach(function(spr:FlxSprite)
			{
				spr.alpha = 0;	
			});
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[AmongStoryMenuState.curWeek]).songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;

			var diffic = CoolUtil.difficultyStuff[AmongStoryMenuState.curDifficulty][1];
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = AmongStoryMenuState.curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = AmongStoryMenuState.curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			
			FlxTween.tween(camUpper, {alpha: 0}, 0.25, {
				ease: FlxEase.circOut,
				onComplete: function(tween:FlxTween)
				{
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
					LoadingState.loadAndSwitchState(new PlayState());
				}
			});
		}
		if (rightP)
		{
			if (hasEnteredMissSelection)
				changeMissAmount(-1);
			
			FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
		}

		if (leftP)
		{
			if (hasEnteredMissSelection)
				changeMissAmount(1);
	
			FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.5);
		}
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

	function openMissLimit()
	{
		missAmountArrow.alpha = 1;
		missTxt.alpha = 1;
		dummySprites.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 1;
		});
		hasEnteredMissSelection = true;
	}
}
