package;

#if desktop
import Discord.DiscordClient;
#end
import WeekData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class AmongStoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var curDifficulty:Int = 2;

	var txtWeekTitle:FlxText;
	var txtWeekNumber:FlxText;

	private static var curWeek:Int = 0;
	private static var curSection:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var selectingDifficulty:Bool = false;
	var panel:FlxSprite;
	var blackPanel:FlxSprite;

	var weekHealthIcon:HealthIcon;
	var weekHealthIconLose:HealthIcon;

	var starsBG:FlxBackdrop;
	var starsFG:FlxBackdrop;
	var ship:FlxSprite;
	var weekCircles:FlxTypedGroup<FlxSprite>;
	var weekLines:FlxTypedGroup<FlxSprite>;
	var weekXvalues:Array<Float> = [];

	public var camSpace:FlxCamera;
	public var camScreen:FlxCamera;

	override function create()
	{
		super.create();
		var curWeeks = AmongFreeplayState.addWeeks();
		// WeekData.reloadWeekFiles(true)

		// my shitty temporary hack
		

		persistentUpdate = persistentDraw = true;

		camSpace = new FlxCamera(0, 100);
		camScreen = new FlxCamera();
		camScreen.bgColor.alpha = 0;

		FlxG.cameras.reset(camSpace);
		FlxG.cameras.add(camScreen);

		FlxCamera.defaultCameras = [camSpace];

		starsBG = new FlxBackdrop(Paths.image('freeplay/starBG', 'impostor'), 1, 1, true, true);
		starsBG.setPosition(111.3, 67.95);
		starsBG.antialiasing = true;
		starsBG.updateHitbox();
		starsBG.scrollFactor.set();
		add(starsBG);

		starsFG = new FlxBackdrop(Paths.image('freeplay/starFG', 'impostor'), 1, 1, true, true);
		starsFG.setPosition(54.3, 59.45);
		starsFG.updateHitbox();
		starsFG.antialiasing = true;
		starsFG.scrollFactor.set();
		add(starsFG);

		ship = new FlxSprite().loadGraphic(Paths.image('storymenu/ship'));
		ship.antialiasing = ClientPrefs.globalAntialiasing;
		ship.cameras = [camSpace];

		weekCircles = new FlxTypedGroup<FlxSprite>();
		add(weekCircles);

		weekLines = new FlxTypedGroup<FlxSprite>();
		add(weekLines);

		scoreText = new FlxText(100, 10, 0, "SCORE: 49324858");
		scoreText.setFormat(Paths.font('AmaticSC-Bold.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.6;
		scoreText.cameras = [camScreen];

		txtWeekNumber = new FlxText(FlxG.width / 2.4 - 10, 40, 0, "");
		txtWeekNumber.setFormat(Paths.font('AmaticSC-Bold.ttf'), 111, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekNumber.borderSize = 2.6;
		txtWeekNumber.cameras = [camScreen];

		txtWeekTitle = new FlxText(FlxG.width / 2.6, txtWeekNumber.y + 110, 0, "");
		txtWeekTitle.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekTitle.borderSize = 3;
		txtWeekTitle.cameras = [camScreen];

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		weekHealthIcon = new HealthIcon('impostor', true);
		weekHealthIcon.x = FlxG.width / 2.4 - 150;
		weekHealthIcon.y = 50;
		weekHealthIcon.flipX = true;
		weekHealthIcon.cameras = [camScreen];

		weekHealthIconLose = new HealthIcon('impostor', true);
		weekHealthIconLose.x = FlxG.width / 2.4 + 200;
		weekHealthIconLose.y = 50;
		weekHealthIconLose.flipX = true;
		weekHealthIconLose.cameras = [camScreen];

		blackPanel = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackPanel.antialiasing = false;
		blackPanel.updateHitbox();
		blackPanel.cameras = [camScreen];
		blackPanel.alpha = 0;
		add(blackPanel);

		panel = new FlxSprite();
		panel.frames = Paths.getSparrowAtlas('freeplay/difficultyPanel', 'impostor');
		panel.animation.addByPrefix('idle', 'DifficultyScreenIdle', 24, false);
		panel.animation.addByPrefix('left', 'DifficultyScreenLeft', 24, false);
		panel.animation.addByPrefix('right', 'DifficultyScreenRight', 24, false);
		panel.animation.play('idle');
		panel.antialiasing = true;
		panel.updateHitbox();
		panel.scrollFactor.set();
		panel.cameras = [camScreen];
		panel.screenCenter();
		panel.visible = false;
		panel.scale.set(0, 0);
		add(panel);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);
		grpWeekText.cameras = [camScreen];

		var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/border'));
		add(border);
		border.cameras = [camScreen];

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		switch (curSection)
		{
			case 0:
				for (i in 0...5)
				{
					WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));

					var weekCircle:FlxSprite = new FlxSprite(i * 400, 50).loadGraphic(Paths.image('storymenu/circle'));
					weekCircle.antialiasing = ClientPrefs.globalAntialiasing;
					weekCircles.add(weekCircle);
					weekXvalues.push(weekCircle.x);

					weekCircle.x += 100;

					if (i < 4)
					{
						var weekLine:FlxSprite = new FlxSprite(weekCircle.x + 95, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine.antialiasing = ClientPrefs.globalAntialiasing;

						var weekLine2:FlxSprite = new FlxSprite(weekCircle.x + 195, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine2.antialiasing = ClientPrefs.globalAntialiasing;

						var weekLine3:FlxSprite = new FlxSprite(weekCircle.x + 295, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine3.antialiasing = ClientPrefs.globalAntialiasing;

						weekLines.add(weekLine);
						weekLines.add(weekLine2);
						weekLines.add(weekLine3);
					}

					if (weekIsLocked(i))
					{
						// ill code l8r
					}
				}
			case 1:
				for (i in 0...4)
				{
					if (i == 0)
						WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
					else
						WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i + 4]));

					var weekCircle:FlxSprite = new FlxSprite(i * -400, 50).loadGraphic(Paths.image('storymenu/circle'));
					weekCircle.antialiasing = ClientPrefs.globalAntialiasing;
					weekCircles.add(weekCircle);
					weekXvalues.push(weekCircle.x);

					weekCircle.x += 100;

					if (i + 1 < WeekData.weeksList.length - 1)
					{
						var weekLine:FlxSprite = new FlxSprite(weekCircle.x + 105, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine.antialiasing = ClientPrefs.globalAntialiasing;

						var weekLine2:FlxSprite = new FlxSprite(weekCircle.x + 205, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine2.antialiasing = ClientPrefs.globalAntialiasing;

						var weekLine3:FlxSprite = new FlxSprite(weekCircle.x + 305, 72).loadGraphic(Paths.image('storymenu/line'));
						weekLine3.antialiasing = ClientPrefs.globalAntialiasing;

						weekLines.add(weekLine);
						weekLines.add(weekLine2);
						weekLines.add(weekLine3);
					}

					if (weekIsLocked(i))
					{
						// ill code l8r
					}
				}
		}

		add(ship);

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		for (i in 0...CoolUtil.difficultyStuff.length)
		{
			var sprDifficulty:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		txtTracklist = new FlxText(FlxG.width * 0.75, 55, 0);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtTracklist.borderSize = 1.6;
		txtTracklist.cameras = [camScreen];
		add(txtTracklist);

		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(txtWeekNumber);

		add(weekHealthIcon);
		add(weekHealthIconLose);

		FlxG.camera.follow(ship, LOCKON, 1);

		changeWeek();
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if (Math.abs(intendedScore - lerpScore) < 10)
			lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		ship.x = FlxMath.lerp(ship.x, weekXvalues[curWeek], 0.06);
		starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
		starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

		// difficultySelectors.visible = !weekIsLocked(curWeek);
		sprDifficultyGroup.visible = false;

		var accepted = controls.ACCEPT;

		if (!movedBack && !selectedWeek)
		{
			if (!selectingDifficulty)
			{
				if (controls.UI_LEFT_P)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (controls.UI_RIGHT_P)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (controls.ACCEPT && curWeek != 0)
				{
					selectWeek();
				}
				else if (controls.RESET && curWeek != 0)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else
			{
				if (controls.UI_RIGHT_P)
					changeDifficulty(1);

				if (controls.UI_LEFT_P)
					changeDifficulty(-1);

				if (controls.ACCEPT && curWeek != 0)
				{
					openDiff();
					FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
					selectingDifficulty = true;
				}
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length - 1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		switch (curSection)
		{
			case 0:
				if (curWeek >= 5)
					curWeek = 0;
				if (curWeek < 0)
					curWeek = 4;

			case 1:
				if (curWeek >= 9)
					curWeek = 4;
				if (curWeek < 4)
					curWeek = 8;
		}

		if (curWeek == 0)
		{
			txtTracklist.visible = false;
			txtWeekNumber.visible = false;
			txtWeekTitle.visible = false;
			weekHealthIcon.visible = false;
			weekHealthIconLose.visible = false;
		}
		else
		{
			txtTracklist.visible = true;
			txtWeekNumber.visible = true;
			txtWeekTitle.visible = true;
			weekHealthIcon.visible = true;
			weekHealthIconLose.visible = true;
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		var leWeekName:String = leWeek.weekName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekNumber.text = leWeekName.toUpperCase();

		weekHealthIcon.changeIcon(leWeek.songs[0][1]);
		weekHealthIconLose.changeIcon(leWeek.songs[0][1]);
		weekHealthIcon.animation.curAnim.curFrame = 0;
		weekHealthIconLose.animation.curAnim.curFrame = 1;

		switch (leWeek.songs.length)
		{
			case 3:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 4:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 34, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 5:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 26, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		switch (curWeek)
		{
			case 1:
				txtTracklist.x = FlxG.width * 0.75 - 17;
				txtTracklist.y = 65;
			case 2:
				txtTracklist.x = FlxG.width * 0.75 - 10;
				txtTracklist.y = 55;
			case 3:
				txtTracklist.x = FlxG.width * 0.75 + 23;
				txtTracklist.y = 58;
			case 4:
				txtTracklist.x = FlxG.width * 0.75 + 15;
				txtTracklist.y = 65;
		}

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}
		updateText();
	}

	function weekIsLocked(weekNum:Int)
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;
		for (i in 0...grpWeekCharacters.length)
		{
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
		{
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	function openDiff()
	{
		panel.visible = true;
		FlxTween.tween(blackPanel, {alpha: 0.4}, 0.25, {ease: FlxEase.circOut});
		FlxTween.tween(panel.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.circOut});
		sprDifficultyGroup.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.circOut});
		});
		curDifficulty = 1;
		changeDifficulty(0);
	}
}
