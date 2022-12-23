package;

import FreeplayState.SongMetadata;
import WeekData;
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.zip.Compress;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

typedef FreeplayWeek =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var section:Int;
}

class AmongFreeplayState extends MusicBeatState
{
	var space:FlxSprite;
	var starsBG:FlxBackdrop;
	var starsFG:FlxBackdrop;
	var upperBar:FlxSprite;
	var upperBarOverlay:FlxSprite;
	var portrait:FlxSprite;
	var porGlow:FlxSprite;

	public var camGame:FlxCamera;
	public var camUpper:FlxCamera;
	public var camOther:FlxCamera;

	var crossImage:FlxSprite;

	private static var curWeek:Int = 0;
	private static var curSelected:Int = 0;

	private var portraitTween:FlxTween;
	private var portraitAlphaTween:FlxTween;
	private var colorTween:FlxTween;

	private var portraitOffset:Array<Dynamic> = [];

	private var curInSongSelection:Int = 0;

	var prevSel:Int;
	var prevWeek:Int;
	var prevPort:Dynamic;

	var portraitArray:Int;

	var upScroll:Bool;
	var downScroll:Bool;

	var infoText:FlxText;

	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	// someones dying for this
	// and its me!
	public static var weeks:Array<FreeplayWeek> = [];

	var listOfButtons:Array<FreeplayCard> = [];

	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;

		// i dont care
		camGame = new FlxCamera();
		camUpper = new FlxCamera();
		camOther = new FlxCamera();
		camUpper.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUpper);
		FlxG.cameras.add(camOther);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		space = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		space.antialiasing = true;
		space.updateHitbox();
		space.scrollFactor.set();
		add(space);

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

		porGlow = new FlxSprite(-11.1, -12.65).loadGraphic(Paths.image('freeplay/backGlow', 'impostor'));
		porGlow.antialiasing = true;
		porGlow.updateHitbox();
		porGlow.scrollFactor.set();
		porGlow.color = FlxColor.RED;
		add(porGlow);

		portrait = new FlxSprite();
		portrait.frames = Paths.getSparrowAtlas('freeplay/portraits', 'impostor');

		var walker:WalkingCrewmate = new WalkingCrewmate(0, [0 - 200, FlxG.width + 200], 800, 0.8);
		add(walker);

		portrait.animation.addByIndices('red', 'Character', [1], null, 24, true);
		portrait.animation.addByIndices('yellow', 'Character', [2], null, 24, true);
		portrait.animation.addByIndices('green', 'Character', [3], null, 24, true);
		portrait.animation.addByIndices('tomo', 'Character', [4], null, 24, true);
		portrait.animation.addByIndices('ham', 'Character', [5], null, 24, true);
		portrait.animation.addByIndices('black', 'Character', [6], null, 24, true);
		portrait.animation.addByIndices('white', 'Character', [7], null, 24, true);
		portrait.animation.addByIndices('para', 'Character', [8], null, 24, true);
		portrait.animation.addByIndices('pink', 'Character', [9], null, 24, true);
		portrait.animation.addByIndices('maroon', 'Character', [10], null, 24, true);
		portrait.animation.addByIndices('grey', 'Character', [11], null, 24, true);
		portrait.animation.addByIndices('chef', 'Character', [12], null, 24, true);
		portrait.animation.addByIndices('tit', 'Character', [13], null, 24, true);
		portrait.animation.addByIndices('ellie', 'Character', [14], null, 24, true);
		portrait.animation.addByIndices('rhm', 'Character', [15], null, 24, true);
		portrait.animation.addByIndices('loggo', 'Character', [16], null, 24, true);
		portrait.animation.addByIndices('clow', 'Character', [17], null, 24, true);
		portrait.animation.addByIndices('ziffy', 'Character', [18], null, 24, true);
		portrait.animation.addByIndices('chips', 'Character', [19], null, 24, true);
		portrait.animation.addByIndices('oldpostor', 'Character', [20], null, 24, true);
		portrait.animation.addByIndices('top', 'Character', [21], null, 24, true);
		portrait.animation.addByIndices('jorsawsee', 'Character', [22], null, 24, true);
		portrait.animation.addByIndices('warchief', 'Character', [23], null, 24, true);
		portrait.animation.addByIndices('redmungus', 'Character', [24], null, 24, true);
		portrait.animation.addByIndices('bananungus', 'Character', [25], null, 24, true);
		portrait.animation.addByIndices('powers', 'Character', [26], null, 24, true);
		portrait.animation.addByIndices('kills', 'Character', [27], null, 24, true);
		portrait.animation.addByIndices('jerma', 'Character', [28], null, 24, true);
		portrait.animation.addByIndices('who', 'Character', [29], null, 24, true);
		portrait.animation.addByIndices('monotone', 'Character', [30], null, 24, true);
		portrait.animation.addByIndices('charles', 'Character', [31], null, 24, true);
		portrait.animation.addByIndices('finale', 'Character', [32], null, 24, true);
		portrait.animation.addByIndices('pop', 'Character', [33], null, 24, true);
		portrait.animation.addByIndices('torture', 'Character', [34], null, 24, true);
		portrait.animation.addByIndices('dave', 'Character', [35], null, 24, true);
		portrait.animation.addByIndices('bpmar', 'Character', [36], null, 24, true);
		portrait.animation.addByIndices('grinch', 'Character', [37], null, 24, true);
		portrait.animation.play('red');
		portrait.antialiasing = true;
		portrait.setPosition(304.65, -100);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		infoText = new FlxText(1071.05, 91, 0, '291921 \n 2:32 \n', 48);
		infoText.antialiasing = true;
		infoText.updateHitbox();
		infoText.scrollFactor.set();
		infoText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

		listOfButtons = [];
		weeks = addWeeks();

		for (i in 0...weeks.length)
		{
			// lolLOLLING IM LOLLING
			var prevI:Int = i;
			for (i in 0...weeks[i].songs.length)
			{
				if (weeks[prevI].section == curWeek)
				{
					listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
						weeks[prevI].songs[i][2]));
				}
			}
		}

		trace('created Weeks');

		trace('pushed list of buttons with ' + listOfButtons.length + ' buttons');

		for (i in listOfButtons)
		{
			add(i);
			add(i.spriteOne);
			add(i.icon);
			add(i.songText);
		}

		for (i in 0...listOfButtons.length)
		{
			listOfButtons[i].targetY = i;
			listOfButtons[i].spriteOne.setPosition(10, (120 * i) + 100);
		}

		upperBar = new FlxSprite(-2, -1.4).loadGraphic(Paths.image('freeplay/topBar', 'impostor'));
		upperBar.antialiasing = true;
		upperBar.updateHitbox();
		upperBar.scrollFactor.set();
		upperBar.cameras = [camUpper];
		add(upperBar);

		crossImage = new FlxSprite(12.50, 8.05).loadGraphic(Paths.image('freeplay/menuBack', 'impostor'));
		crossImage.antialiasing = true;
		crossImage.scrollFactor.set();
		crossImage.updateHitbox();
		crossImage.cameras = [camUpper];
		add(crossImage);
		FlxMouseEventManager.add(crossImage, function onMouseDown(s:FlxSprite)
		{
			goBack();
		}, null, null);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		changeWeek(0);
		changeSelection(0);
		changePortrait();

		CustomFadeTransition.nextCamera = camOther;
	}

	public var inSubstate:Bool = false;

	override function openSubState(SubState:FlxSubState)
	{
		inSubstate = true;
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		inSubstate = false;
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
		starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

		if (!inSubstate)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var rightP = controls.UI_RIGHT_P;
			var leftP = controls.UI_LEFT_P;
			var accepted = controls.ACCEPT;
			upScroll = FlxG.mouse.wheel > 0;
			downScroll = FlxG.mouse.wheel < 0;

			lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
			lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;
			if (Math.abs(lerpRating - intendedRating) <= 0.01)
				lerpRating = intendedRating;

			infoText.text = "Score: " + lerpScore + '\n' + "Rating: " + Math.floor(lerpRating * 100) + '\n';

			if (upScroll)
				changeSelection(-1);
			if (downScroll)
				changeSelection(1);
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);
			//
			if (rightP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
			}
			if (leftP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.5);
			}
			//
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			//
			if (accepted)
			{
				openSubState(new AmongDifficultySubstate(curWeek, listOfButtons[curSelected].songName));
				FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
			}
		}
		infoText.x = FlxG.width - infoText.width - 6;

		super.update(elapsed);
	}

	function changeSelection(change:Int)
	{
		prevSel = curSelected;
		curSelected += change;
		if (curSelected < 0)
		{
			curSelected = 0;
		}
		else if (curSelected > listOfButtons.length - 1)
		{
			curSelected = listOfButtons.length - 1;
		}
		else
		{
			FlxG.sound.play(Paths.sound('hover', 'impostor'), 0.5);
		}

		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 1);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 1);

		var bullShit:Int = 0;

		if (listOfButtons.length > 0)
		{
			for (i in 0...listOfButtons.length)
			{
				listOfButtons[i].targetY = bullShit - curSelected;

				bullShit++;
			}
		}

		changePortrait();
	}

	function Hover()
	{
	}

	function UnHover()
	{
	}

	public static function goBack()
	{
		MusicBeatState.switchState(new MainMenuState());
		FlxG.sound.play(Paths.sound('select', 'impostor'), 0.5);
	}

	public static function addWeeks():Array<FreeplayWeek>
	{
		weeks = [];
		// im just like putting this in its own function because
		// jesus christ man this cant get near the coherent code
		weeks.push({
			songs: [
				["Sussus Moogus", "impostor", 'red', FlxColor.RED],
				["Sabotage", "impostor", 'red', FlxColor.RED],
				["Meltdown", "impostor2", 'red', FlxColor.RED]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Sussus Toogus", "crewmate", 'green', FlxColor.fromRGB(0, 255, 0)],
				["Lights Down", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0)],
				["Reactor", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0)],
				["Ejected", "parasite", 'para', FlxColor.fromRGB(0, 255, 0)],
				["Double Trouble", 'dt', 'para', FlxColor.fromRGB(0, 255, 0)]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Mando", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67)],
				["Dlow", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67)],
				["Oversight", "white", 'white', FlxColor.WHITE],
				["Danger", "black", 'black', FlxColor.fromRGB(179, 0, 255)],
				["Double Kill", "whiteblack", 'black', FlxColor.fromRGB(179, 0, 255)]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Defeat", "black", 'black', FlxColor.fromRGB(179, 0, 255)],
				["Finale", "black", 'finale', FlxColor.fromRGB(179, 0, 255)]
			],

			section: 0
		});

		weeks.push({
			songs: [["Identity Crisis", "monotone", 'monotone', FlxColor.BLACK]],
			section: 0
		});

		weeks.push({
			songs: [
				["Ashes", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0)],
				["Magmatic", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0)],
				["Boiling Point", "boilingpoint", 'bpmar', FlxColor.fromRGB(181, 0, 0)]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Delusion", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)],
				["Blackout", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)],
				["Neurotic", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Heartbeat", "pink", 'pink', FlxColor.fromRGB(255, 0, 222)],
				["Pinkwave", "pink", 'pink', FlxColor.fromRGB(255, 0, 222)],
				["Pretender", "pretender", 'pink', FlxColor.fromRGB(255, 0, 222)]
			],

			section: 1
		});

		weeks.push({
			songs: [["Sauces Moogus", "chef", 'chef', FlxColor.fromRGB(242, 114, 28)]],
			section: 1
		});

		weeks.push({
			songs: [
				["Lotowncorry", "jorsawsee", 'jorsawsee', FlxColor.fromRGB(22, 65, 240)],
				["O2", "o2", 'jorsawsee', FlxColor.fromRGB(22, 65, 240)],
				["Voting Time", "votingtime", 'warchief', FlxColor.fromRGB(153, 67, 196)],
				["Turbulence", "redmungus", 'redmungus', FlxColor.RED],
				["Victory", "warchief", 'warchief', FlxColor.fromRGB(153, 67, 196)]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["ROOMCODE", "powers", 'powers', FlxColor.fromRGB(80, 173, 235)],
				["Posussium", "bananungus", 'bananungus', FlxColor.fromRGB(235, 188, 80)],
				["Kyubism", "kyubi", 'warchief', FlxColor.PURPLE]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["Sussy Bussy", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134)],
				["Rivals", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134)],
				["Chewmate", "hamster", 'ham', FlxColor.fromRGB(255, 90, 134)]
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Tomongus Tuesday", "tuesday", 'tomo', FlxColor.fromRGB(255, 90, 134)],
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Christmas", "fella", 'loggo', FlxColor.fromRGB(0, 255, 0)],
				["Spookpostor", "boo", 'loggo', FlxColor.fromRGB(0, 255, 0)]
			],

			section: 4
		});

		weeks.push({
			songs: [
				["Titular", "henry", 'tit', FlxColor.ORANGE],
				["Greatest Plan", "charles", 'charles', FlxColor.RED],
				["Reinforcements", "ellie", 'ellie', FlxColor.ORANGE],
				["Armed", "rhm", 'rhm', FlxColor.ORANGE]
			],

			section: 5
		});

		weeks.push({
			songs: [
				["Alpha Moogus", "oldpostor", 'oldpostor', FlxColor.RED],
				["Actin Sus", "oldpostor", 'oldpostor', FlxColor.RED]
			],

			section: 6
		});

		weeks.push({
			songs: [
				["Ow", "kills", 'kills', FlxColor.fromRGB(84, 167, 202)],
				["Who", "whoguys", 'who', FlxColor.fromRGB(22, 65, 240)],
				["Insane Streamer", "jerma", 'jerma', FlxColor.BLACK],
				["Drippypop", "drippy", 'pop', FlxColor.fromRGB(188, 106, 223)],
				["Crewicide", "dave", 'dave', FlxColor.BLUE],
				["Triple Trouble", "placeholder", 'red', FlxColor.fromRGB(84, 167, 202)],
				["Monochrome", "dead", 'red', FlxColor.fromRGB(84, 167, 202)],
				["Top 10", "top", 'top', FlxColor.RED]
			],

			section: 7
		});

		weeks.push({
			songs: [
				["Chippin", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38)],
				["Chipping", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38)],
				["Torture", "ziffy", 'torture', FlxColor.fromRGB(188, 106, 223)]
			],

			section: 8
		});

		return weeks;
	}

	function changeWeek(change:Int)
	{
		prevWeek = curWeek;

		curWeek += change;

		if (curWeek > 8)
		{
			curWeek = 0;
		}
		if (curWeek < 0)
		{
			curWeek = 8;
		}

		trace(curWeek + ' ' + weeks.length);

		trace('created Weeks');

		for (i in 0...listOfButtons.length)
		{
			listOfButtons[i].destroy();
			listOfButtons[i].spriteOne.destroy();
			listOfButtons[i].icon.destroy();
			listOfButtons[i].songText.destroy();
		}

		listOfButtons = [];

		for (i in 0...weeks.length)
		{
			// lolLOLLING IM LOLLING
			var prevI:Int = i;
			for (i in 0...weeks[i].songs.length)
			{
				if (weeks[prevI].section == curWeek)
				{
					listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
						weeks[prevI].songs[i][2]));
				}
			}
		}

		for (i in listOfButtons)
		{
			add(i);
			add(i.spriteOne);
			add(i.icon);
			add(i.songText);
			trace('added button ' + i);
		}

		for (i in 0...listOfButtons.length)
		{
			listOfButtons[i].targetY = i;
			listOfButtons[i].spriteOne.alpha = 0;
			listOfButtons[i].songText.alpha = 0;
			listOfButtons[i].icon.alpha = 0;
			listOfButtons[i].spriteOne.setPosition((Math.abs(listOfButtons[i].targetY * 70) * -1) - 270,
				(FlxMath.remapToRange(listOfButtons[i].targetY, 0, 1, 0, 1.3) * 90) + (FlxG.height * 0.45));
		}

		curSelected = 0;

		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 1);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 1);

		changePortrait(true);
	}

	function changePortrait(?reset:Bool = false)
	{
		prevPort = portrait.animation.name;
		switch (listOfButtons[curSelected].portrait)
		{
			default:
				portrait.animation.play(listOfButtons[curSelected].portrait);
		}

		trace(portrait.animation.name);

		if (!reset)
		{
			if (prevSel != curSelected)
			{
				if (prevPort != portrait.animation.name)
				{
					if (portraitTween != null)
					{
						portraitTween.cancel();
					}
					if (portraitAlphaTween != null)
					{
						portraitAlphaTween.cancel();
					}
					if (colorTween != null)
					{
						colorTween.cancel();
					}
					portrait.x = 504.65;
					portrait.alpha = 0;
					colorTween = FlxTween.color(porGlow, 0.2, porGlow.color, listOfButtons[curSelected].coloring);
					portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
					portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
				}
			}
		}
		else
		{
			if (portraitTween != null)
			{
				portraitTween.cancel();
			}
			if (portraitAlphaTween != null)
			{
				portraitAlphaTween.cancel();
			}
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			portrait.x = 504.65;
			portrait.alpha = 0;
			colorTween = FlxTween.color(porGlow, 0.2, porGlow.color, listOfButtons[curSelected].coloring);
			portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
			portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		}
	}
}
