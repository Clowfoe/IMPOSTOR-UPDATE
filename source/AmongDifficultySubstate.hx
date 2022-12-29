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
	private static var curDifficulty:Int = 1;

	var panel:FlxSprite;
	var blackPanel:FlxSprite;

	private var selectedSong:String;
	private var curWeek:Int;

	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;

	// hey please automate this sometime soon I'm not a fan of hardcoding this
	public static var songsWithMissLimits:Array<String> = ['defeat', 'insane streamer'];

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

		blackPanel = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackPanel.antialiasing = false;
		blackPanel.updateHitbox();
		blackPanel.alpha = 0;
		add(blackPanel);

		// difficulty stuff

		panel = new FlxSprite();
		panel.frames = Paths.getSparrowAtlas('freeplay/difficultyPanel', 'impostor');
		panel.animation.addByPrefix('idle', 'DifficultyScreenIdle', 24, false);
		panel.animation.addByPrefix('left', 'DifficultyScreenLeft', 24, false);
		panel.animation.addByPrefix('right', 'DifficultyScreenRight', 24, false);
		panel.animation.play('idle');
		panel.antialiasing = true;
		panel.updateHitbox();
		panel.scrollFactor.set();
		panel.screenCenter();
		panel.visible = false;
		panel.scale.set(0, 0);
		add(panel);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		for (i in 0...3)
		{
			var sprDifficulty:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficulty.updateHitbox();
			sprDifficulty.screenCenter();
			sprDifficulty.scale.set(0, 0);
			sprDifficultyGroup.add(sprDifficulty);
		}

		panel.visible = true;
		FlxTween.tween(blackPanel, {alpha: 0.4}, 0.25, {ease: FlxEase.circOut});
		FlxTween.tween(panel.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.circOut});
		sprDifficultyGroup.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.circOut});
		});
		curDifficulty = 1;
		changeDiff(0);

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
			if (accepted)
			{
				if (!songsWithMissLimits.contains(selectedSong.toLowerCase()) || hasEnteredMissSelection)
				{
					var songLowercase:String = Paths.formatToSongPath(selectedSong.toLowerCase());
					trace(selectedSong);

					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.storyWeek = curWeek;

					var diffic:String = '';
					switch (curDifficulty)
					{
						case 0:
							diffic = '-easy';
						case 2:
							diffic = '-hard';
					}
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

			//
			if (controls.BACK)
			{
				if (hasEnteredMissSelection)
					closeMissLimit();
				else
					closeDiff(true);
				FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.5);
			}

			//
			if (rightP)
			{
				if (hasEnteredMissSelection)
					changeMissAmount(-1);
				else
					changeDiff(1);
				FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
			}
			//
			if (leftP)
			{
				if (hasEnteredMissSelection)
					changeMissAmount(1);
				else
					changeDiff(-1);
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

		sprDifficultyGroup.forEach(function(spr:FlxSprite)
		{
			spr.visible = false;
			if (curDifficulty == spr.ID)
			{
				spr.visible = true;
				if (change == 1)
				{
					spr.alpha = 0;
					spr.screenCenter();
					spr.x -= 15;
					FlxTween.tween(spr, {x: spr.x + 15, alpha: 1}, 0.1, {ease: FlxEase.circOut});
					panel.animation.play('right', true);
				}
				else if (change == -1)
				{
					spr.alpha = 0;
					spr.screenCenter();
					spr.x += 15;
					panel.animation.play('left', true);
					FlxTween.tween(spr, {x: spr.x - 15, alpha: 1}, 0.1, {ease: FlxEase.circOut});
				}
			}
		});
	}

	function openMissLimit()
	{
		closeDiff(false);
		FlxTween.tween(missAmountArrow, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missTxt, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		dummySprites.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		});
		hasEnteredMissSelection = true;
	}

	function closeMissLimit()
	{
		isClosing = true;
		FlxTween.tween(missAmountArrow, {alpha: 0}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missTxt, {alpha: 0}, 0.25, {ease: FlxEase.circIn});
		dummySprites.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0}, 0.25, {ease: FlxEase.circOut});
		});
		//
		FlxTween.tween(blackPanel, {alpha: 0}, 0.25, {
			ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				close();
			}
		});
	}

	function closeDiff(shouldClose:Bool)
	{
		panel.visible = true;
		if (shouldClose)
		{
			FlxTween.tween(blackPanel, {alpha: 0}, 0.25, {ease: FlxEase.circOut});
			isClosing = true;
		}
		FlxTween.tween(panel.scale, {x: 0, y: 0}, 0.25, {
			ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				if (shouldClose)
					close();
			}
		});
		sprDifficultyGroup.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr.scale, {x: 0, y: 0}, 0.25, {ease: FlxEase.circOut});
		});
	}
}
