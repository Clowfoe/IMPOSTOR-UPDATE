package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import ClientPrefs;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '4.1.0'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var localFinaleState:FinaleState;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;

	var optionShit:Array<String> = ['Story Mode', 'Freeplay', 'Gallery', 'Credits', 'Options', 'Shop', 'Innersloth'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;
	var redImpostor:FlxSprite;
	var greenImpostor:FlxSprite;
	var vignette:FlxSprite;
	var glowyThing:FlxSprite;

	override function create()
	{
		super.create();

		// localFinaleState = ClientPrefs.finaleState;

		localFinaleState = ClientPrefs.finaleState;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		if (localFinaleState == NOT_PLAYED)
			FlxG.sound.playMusic(Paths.music('finaleMenu'));

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = #if mobile false #else true #end;

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		if (FlxG.save.data.antialiasing)
		{
			bg.antialiasing = !ClientPrefs.lowQuality;
		}
		add(bg);

		starFG = new FlxBackdrop(Paths.image('menuBooba/starFG', 'impostor'), 1, 1, true, true);
		starFG.updateHitbox();
		starFG.antialiasing = !ClientPrefs.lowQuality;
		starFG.scrollFactor.set();
		add(starFG);

		starBG = new FlxBackdrop(Paths.image('menuBooba/starBG', 'impostor'), 1, 1, true, true);
		starBG.updateHitbox();
		starBG.antialiasing = !ClientPrefs.lowQuality;
		starBG.scrollFactor.set();
		add(starBG);

		redImpostor = new FlxSprite(350, -160);
		redImpostor.frames = Paths.getSparrowAtlas('menuBooba/redmenu', 'impostor');
		redImpostor.animation.addByPrefix('idle', 'red idle', 24, true);
		redImpostor.animation.addByPrefix('select', 'red select', 24, false);
		redImpostor.animation.play('idle');
		redImpostor.antialiasing = !ClientPrefs.lowQuality;
		redImpostor.updateHitbox();
		redImpostor.active = true;
		redImpostor.scale.set(0.7, 0.7);
		redImpostor.scrollFactor.set();
		add(redImpostor);

		greenImpostor = new FlxSprite(-300, -60);
		greenImpostor.frames = Paths.getSparrowAtlas('menuBooba/greenmenu', 'impostor');
		greenImpostor.animation.addByPrefix('idle', 'green idle', 24, true);
		greenImpostor.animation.addByPrefix('select', 'green select', 24, false);
		greenImpostor.animation.play('idle');
		greenImpostor.antialiasing = !ClientPrefs.lowQuality;
		greenImpostor.updateHitbox();
		greenImpostor.active = true;
		greenImpostor.scale.set(0.7, 0.7);
		greenImpostor.scrollFactor.set();
		add(greenImpostor);

		if (localFinaleState == NOT_PLAYED)
		{
			greenImpostor.visible = false;
			redImpostor.visible = false;
		}

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuBooba/vignette', 'impostor'));
		vignette.antialiasing = !ClientPrefs.lowQuality;
		vignette.updateHitbox();
		vignette.active = false;
		vignette.scrollFactor.set();
		add(vignette);

		glowyThing = new FlxSprite(361, 438).loadGraphic(Paths.image('menuBooba/buttonglow', 'impostor'));
		glowyThing.antialiasing = !ClientPrefs.lowQuality;
		glowyThing.scale.set(0.51, 0.51);
		glowyThing.updateHitbox();
		glowyThing.active = false;
		glowyThing.scrollFactor.set();
		if (localFinaleState != NOT_PLAYED)
			glowyThing.visible = false;
		add(glowyThing);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var testButton:FlxSprite = new FlxSprite(0, 130);
			testButton.ID = i;
			if (i > 3)
				testButton.frames = Paths.getSparrowAtlas('menuBooba/Buttons_UI', 'impostor');
			else
				testButton.frames = Paths.getSparrowAtlas('menuBooba/Big_Buttons_UI', 'impostor');
			testButton.animation.addByPrefix('idle', optionShit[i] + ' Button', 24, true);
			testButton.animation.addByPrefix('hover', optionShit[i] + ' Select', 24, true);
			testButton.animation.play('idle');
			testButton.antialiasing = !ClientPrefs.lowQuality;
			testButton.scale.set(0.50, 0.50);
			testButton.updateHitbox();
			testButton.screenCenter(X);
			testButton.scrollFactor.set();
			// brian was here

			// hi
			switch (i)
			{
				case 0:
					testButton.setPosition(400, 475);
				case 1:
					testButton.setPosition(633, 475);
				case 2:
					testButton.setPosition(400, 580);
				case 3:
					testButton.setPosition(633, 580);
				case 4:
					testButton.setPosition(455, 640);
				case 5:
					testButton.setPosition(590, 640);
				case 6:
					testButton.setPosition(725, 640);
			}
			menuItems.add(testButton);
		}

		add(menuItems);

		var logo:FlxSprite = new FlxSprite(0, 100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.screenCenter();
		logo.updateHitbox();
		logo.antialiasing = !ClientPrefs.lowQuality;
		logo.scale.set(0.65, 0.65);
		logo.y -= 160;
		add(logo);

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "VS Impostor v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18)
		{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;

	function giveAchievement()
	{
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	var canClick:Bool = true;
	var usingMouse:Bool = false;

	var timerThing:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		timerThing += elapsed;
		glowyThing.alpha = Math.sin(timerThing) + 0.4;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (usingMouse)
			{
				if (!FlxG.mouse.overlaps(spr))
					spr.animation.play('idle');
			}

			if (FlxG.mouse.overlaps(spr))
			{
				if (canClick)
				{
					curSelected = spr.ID;
					usingMouse = true;
					spr.animation.play('hover');
				}

				if (FlxG.mouse.pressed && canClick)
				{
					switch (optionShit[curSelected])
					{
						case 'Gallery':
							FlxG.openURL('https://vsimpostor.com/');
						case 'Innersloth':
							FlxG.openURL('https://www.innersloth.com/');
						default:
							selectSomething();
					}
				}
			}

			starFG.x -= 0.03;
			starBG.x -= 0.01;

			spr.updateHitbox();
		});

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
		});*/
	}

	function selectSomething()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		greenImpostor.animation.play('select');
		redImpostor.animation.play('select');

		canClick = false;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(starFG, {y: starFG.y + 500}, 0.7, {ease: FlxEase.quadInOut});
				FlxTween.tween(starBG, {y: starBG.y + 500}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.2});
				FlxTween.tween(greenImpostor, {y: greenImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.24});
				FlxTween.tween(redImpostor, {y: redImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.3});
				FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
				FlxTween.tween(spr, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				FlxTween.tween(starFG, {y: starFG.y + 500}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(starBG, {y: starBG.y + 500}, 1, {ease: FlxEase.quadInOut, startDelay: 0.2});
				FlxTween.tween(greenImpostor, {y: greenImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.24});
				FlxTween.tween(redImpostor, {y: redImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.3});
				FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					goToState();
				});
			}
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'Story Mode':
				FlxG.switchState(new AmongStoryMenuState());
				trace("Story Menu Selected");
			case 'Freeplay':
				FlxG.switchState(new AmongFreeplayState());
				trace("Freeplay Menu Selected");
			case 'Shop':
				FlxG.switchState(new ShopState());
				trace("Shop Menu Selected");
			case 'Options':
				FlxG.switchState(new OptionsState());
				trace("Options Menu Selected");
			case 'Credits':
				FlxG.switchState(new AmongCreditsState());
				trace("Gallery Menu Selected");
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('hover');
			}

			spr.updateHitbox();
		});
	}
}
