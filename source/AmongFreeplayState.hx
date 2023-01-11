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
import RimlightShader;
import flixel.util.FlxTimer;
import ColorShader;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

enum RequireType{
	FROM_STORY_MODE;
	BEANS;
	SPECIAL;
}// g

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

	var lockMovement:Bool = false;

	var portraitArray:Int;

	var upScroll:Bool;
	var downScroll:Bool;

	var topBean:FlxSprite;
    var beanText:FlxText;

	var infoText:FlxText;

	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var rimlight:RimlightShader;
	var buttonTween:FlxTween;
	var lockTween:FlxTween;
    var textTween:FlxTween;

	var localBeans:Int;

	// someones dying for this
	// and its me!
	public static var weeks:Array<FreeplayWeek> = [];
	var hasSavedData:Bool = false;
	var localWeeks:Array<FreeplayWeek>;

	var listOfButtons:Array<FreeplayCard> = [];

	override function create()
	{
		super.create();

		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;	

		localBeans = ClientPrefs.beans;

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

		var songPortraitStuff:Array<String> = ['', 'red','yellow','green','tomo','ham','black','white','para','pink','maroon','grey','chef','tit','ellie','rhm','loggo','clow','ziffy','chips','oldposter','top','jorsawsee','warchief','redmungus','banananungus','powers','kills','jerma','who','monotone','charles','finale','pop','torture','dave','bpmar','grinch','redmunp','nuzzus','monotoner','idk','esculent'];
		for (i => name in songPortraitStuff){
			portrait.animation.addByIndices(name, 'Character', [i], null, 24, true);
		}
		// what the actual fuck
		portrait.animation.play('red');
		portrait.antialiasing = true;
		portrait.setPosition(304.65, -100);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		infoText = new FlxText(1071.05, 91, 0, '291921 \n Rating: 32 \n', 48);
		infoText.antialiasing = true;
		infoText.updateHitbox();
		infoText.scrollFactor.set();
		infoText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

		listOfButtons = [];
		weeks = addWeeks();

		if(ClientPrefs.forceUnlockedSongs != null){
			localWeeks = ClientPrefs.forceUnlockedSongs;
			hasSavedData = true;
			trace(localWeeks);
		}else{
			localWeeks = weeks;
		}

		for (i in 0...weeks.length)
		{
			// lolLOLLING IM LOLLING
			var prevI:Int = i;
			for (i in 0...weeks[i].songs.length)
			{
				if (weeks[prevI].section == curWeek)
				{
					if(hasSavedData){
						listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
							weeks[prevI].songs[i][2], weeks[prevI].songs[i][4], weeks[prevI].songs[i][5], weeks[prevI].songs[i][6], localWeeks[prevI].songs[i][7]));
					}else{
						listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
							weeks[prevI].songs[i][2], weeks[prevI].songs[i][4], weeks[prevI].songs[i][5], weeks[prevI].songs[i][6], weeks[prevI].songs[i][7]));
					}
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
			add(i.bean);
			add(i.lock);
			add(i.priceText);
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

		// var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		// textBG.alpha = 0.6;
		// add(textBG);

		// var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		// var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		// text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		// text.scrollFactor.set();
		// add(text);

		rimlight = new RimlightShader(315, 10, 0xFFFF6600, portrait);
		add(rimlight);
		portrait.shader = rimlight.shader;

		topBean = new FlxSprite(30, 100).loadGraphic(Paths.image('shop/bean', 'impostor'));
        topBean.antialiasing = true;
        topBean.cameras = [camUpper];
        topBean.updateHitbox();
		add(topBean);	

        beanText = new FlxText(110, 105, 200, '---', 35);
		beanText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        beanText.updateHitbox();
		beanText.borderSize = 3;
        beanText.scrollFactor.set();
        beanText.antialiasing = true;
        beanText.cameras = [camUpper];
        add(beanText);

        beanText.text = Std.string(localBeans);

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

			if(!lockMovement){
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
				ClientPrefs.beans = localBeans;
				ClientPrefs.forceUnlockedSongs = localWeeks;

				ClientPrefs.saveSettings();

				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			//
			if (accepted)
			{
				var pulseColor:FlxColor;

				if(listOfButtons[curSelected].locked){
					if(listOfButtons[curSelected].requirementtype == BEANS && localBeans >= listOfButtons[curSelected].price){
						for (i in 0...weeks.length)
						{
							for (g in 0...weeks[i].songs.length)
							{
								if(localWeeks[i].songs[g][7] == false && localWeeks[i].songs[g][0] == listOfButtons[curSelected].songName){
									localWeeks[i].songs[g][7] = true;
									listOfButtons[curSelected].unlockAnim();
									lockMovement = true;
									new FlxTimer().start(1.45, function(tmr:FlxTimer)
									{
										changePortrait(true);
										lockMovement = false;
									});
									localBeans -= listOfButtons[curSelected].price;
									beanText.text = Std.string(localBeans);
									trace(localWeeks[i].songs[g], localWeeks[i].songs[g][7], listOfButtons[curSelected].songName, localWeeks[i].songs[g][0]);
									return;
								} 
							}
						}
						return;
					}
					FlxG.sound.play(Paths.sound('locked', 'impostor'), 0.7);
					camUpper.shake(0.01, 0.35);
					FlxG.camera.shake(0.005, 0.35);
					pulseColor = 0xFFFF4444;

					if(buttonTween != null) buttonTween.cancel();
            		buttonTween = FlxTween.color(listOfButtons[curSelected].spriteOne, 0.6, pulseColor, 0xFF4A4A4A, { ease: FlxEase.sineOut });
					if(lockTween != null) lockTween.cancel();
            		lockTween = FlxTween.color(listOfButtons[curSelected].lock, 0.6, pulseColor, 0xFFFFFFFF, { ease: FlxEase.sineOut });
					if(textTween != null) textTween.cancel();
            		textTween = FlxTween.color(listOfButtons[curSelected].songText, 0.5, pulseColor, 0xFFFFFFFF, { ease: FlxEase.sineOut });
				}else{
					openSubState(new AmongDifficultySubstate(curWeek, listOfButtons[curSelected].songName));
					FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
					ClientPrefs.beans = localBeans;
					ClientPrefs.forceUnlockedSongs = localWeeks;

					ClientPrefs.saveSettings();
				}
			}
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
			changeWeek(-1);
			curSelected = listOfButtons.length - 1;
		}
		else if (curSelected > listOfButtons.length - 1)
		{
			changeWeek(1);
			curSelected = 0;
		}
		else
		{
			FlxG.sound.play(Paths.sound('hover', 'impostor'), 0.5);
		}

		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 2);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 2);

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

	public function goBack()
	{
		ClientPrefs.beans = localBeans;
		ClientPrefs.forceUnlockedSongs = localWeeks;

		ClientPrefs.saveSettings();

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
				["Sussus Moogus", "impostor", 'red', FlxColor.RED, FROM_STORY_MODE, ['sussus-moogus'], 0, false],
				["Sabotage", "impostor", 'red', FlxColor.RED, FROM_STORY_MODE, ['sabotage'], 0, false],
				["Meltdown", "impostor2", 'red', FlxColor.RED, FROM_STORY_MODE, ['meltdown'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Sussus Toogus", "crewmate", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['sussus-toogus'], 0, false],
				["Lights Down", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['lights-down'], 0, false],
				["Reactor", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['reactor'], 0, false],
				["Ejected", "parasite", 'para', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['ejected'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Mando", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), FROM_STORY_MODE, ['mando'], 0, false],
				["Dlow", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), FROM_STORY_MODE, ['dlow'], 0, false],
				["Oversight", "white", 'white', FlxColor.WHITE, FROM_STORY_MODE, ['oversight'], 0, false],
				["Danger", "black", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['danger'], 0, false],
				["Double Kill", "whiteblack", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['double-kill'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Defeat", "black", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['defeat'], 0, false],
				["Finale", "black", 'finale', FlxColor.fromRGB(179, 0, 255), SPECIAL, ['finale'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [["Identity Crisis", "monotone", 'monotone', FlxColor.BLACK, SPECIAL, ['meltdown', 'ejected', 'double-kill', 'defeat', 'boiling-point', 'neurotic', 'pretender'], 0, false]],
			section: 0
		});

		weeks.push({
			songs: [
				["Ashes", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['ashes'], 0, false],
				["Magmatic", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['magmatic'], 0, false],
				["Boiling Point", "boilingpoint", 'bpmar', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['boiling-point'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Delusion", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['delusion'], 0, false],
				["Blackout", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['blackout'], 0, false],
				["Neurotic", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['neurotic'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Heartbeat", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['heartbeat'], 0, false],
				["Pinkwave", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['pinkwave'], 0, false],
				["Pretender", "pretender", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['pretender'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [["Sauces Moogus", "chef", 'chef', FlxColor.fromRGB(242, 114, 28), SPECIAL, ['ashes', 'delusion', 'heartbeat'], 0, false]],
			section: 1
		});

		weeks.push({
			songs: [
				["O2", "jorsawsee", 'jorsawsee', FlxColor.fromRGB(38, 127, 230), FROM_STORY_MODE, ['o2'], 0],
				["Voting Time", "votingtime", 'warchief', FlxColor.fromRGB(153, 67, 196), FROM_STORY_MODE, ['voting-time'], 0, false],
				["Turbulence", "redmungus", 'redmunp', FlxColor.RED, FROM_STORY_MODE, ['turbulence'], 0, false],
				["Victory", "warchief", 'warchief', FlxColor.fromRGB(153, 67, 196), FROM_STORY_MODE, ['victory'], 0, false]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["ROOMCODE", "powers", 'powers', FlxColor.fromRGB(80, 173, 235), SPECIAL, ['victory'], 0, false]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["Sussy Bussy", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['sussy-bussy'], 0, false],
				["Rivals", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['rivals'], 0, false],
				["Chewmate", "hamster", 'ham', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['chewmate'], 0, false]
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Tomongus Tuesday", "tuesday", 'tomo', FlxColor.fromRGB(255, 90, 134), SPECIAL, ['chewmate'], 0, false],
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Christmas", "fella", 'loggo', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['christmas'], 0, false],
				["Spookpostor", "boo", 'loggo', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['spookpostor'], 0, false]
			],

			section: 4
		});

		weeks.push({
			songs: [
				["Titular", "henry", 'tit', FlxColor.ORANGE, FROM_STORY_MODE, ['titular'], 0, false],
				["Greatest Plan", "charles", 'charles', FlxColor.RED, FROM_STORY_MODE, ['greatest-plan'], 0, false],
				["Reinforcements", "ellie", 'ellie', FlxColor.ORANGE, FROM_STORY_MODE, ['reinforcements'], 0, false],
				["Armed", "rhm", 'rhm', FlxColor.ORANGE, FROM_STORY_MODE, ['armed'], 0, false]
			],

			section: 5
		});

		weeks.push({
			songs: [
				["Alpha Moogus", "oldpostor", 'oldpostor', FlxColor.RED, BEANS, [], 250, false],
				["Actin Sus", "oldpostor", 'oldpostor', FlxColor.RED, BEANS, [], 250, false]
			],

			section: 6
		});

		weeks.push({
			songs: [
				["Ow", "kills", 'kills', FlxColor.fromRGB(84, 167, 202), BEANS, [], 400, false],
				["Who", "whoguys", 'who', FlxColor.fromRGB(22, 65, 240), BEANS, [], 500, false],
				["Insane Streamer", "jerma", 'jerma', FlxColor.BLACK, BEANS, [], 400, false],
				["Sussus Nuzzus", "nuzzles", 'nuzzus', FlxColor.BLACK, BEANS, [], 400, false],
				["Idk", "idk", 'idk', FlxColor.fromRGB(255, 140, 177), BEANS, [], 350, false],
				["Esculent", "dead", 'esculent', FlxColor.BLACK, BEANS, [], 350, false],
				["Drippypop", "drippy", 'pop', FlxColor.fromRGB(188, 106, 223), BEANS, [], 425, false],
				["Crewicide", "dave", 'dave', FlxColor.BLUE, BEANS, [], 450, false],
				["Monotone Attack", "attack", 'monotoner', FlxColor.WHITE, BEANS, [], 400, false],
				["Top 10", "top", 'top', FlxColor.RED, BEANS, [], 200, false]
			],

			section: 7
		});

		weeks.push({
			songs: [
				["Chippin", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38), BEANS, [], 300, false],
				["Chipping", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38), BEANS, [], 300, false],
				["Torture", "ziffy", 'torture', FlxColor.fromRGB(188, 106, 223), SPECIAL, ['chippin', 'chipping'], 0, false]
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
			FlxTween.cancelTweensOf(listOfButtons[i]);
			FlxTween.cancelTweensOf(listOfButtons[i].spriteOne);
			FlxTween.cancelTweensOf(listOfButtons[i].icon);
			FlxTween.cancelTweensOf(listOfButtons[i].lock);
			FlxTween.cancelTweensOf(listOfButtons[i].songText);
			FlxTween.cancelTweensOf(listOfButtons[i].bean);
			FlxTween.cancelTweensOf(listOfButtons[i].priceText);
			listOfButtons[i].destroy();
			listOfButtons[i].spriteOne.destroy();
			listOfButtons[i].icon.destroy();
			listOfButtons[i].lock.destroy();
			listOfButtons[i].songText.destroy();
			listOfButtons[i].bean.destroy();
			listOfButtons[i].priceText.destroy();
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
					if(hasSavedData){
						listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
							weeks[prevI].songs[i][2], weeks[prevI].songs[i][4], weeks[prevI].songs[i][5], weeks[prevI].songs[i][6], localWeeks[prevI].songs[i][7]));
					}else{
						listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3],
							weeks[prevI].songs[i][2], weeks[prevI].songs[i][4], weeks[prevI].songs[i][5], weeks[prevI].songs[i][6], weeks[prevI].songs[i][7]));
					}
				}
			}
		}

		for (i in listOfButtons)
		{
			add(i);
			add(i.spriteOne);
			add(i.icon);
			add(i.songText);
			add(i.bean);
			add(i.lock);
			add(i.priceText);
			// trace('added button ' + i);
		}

		for (i in 0...listOfButtons.length)
		{
			listOfButtons[i].targetY = i;
			listOfButtons[i].spriteOne.alpha = 0;
			listOfButtons[i].songText.alpha = 0;
			listOfButtons[i].icon.alpha = 0;
			listOfButtons[i].lock.alpha = 0;
			listOfButtons[i].bean.alpha = 0;
			listOfButtons[i].priceText.alpha = 0;
			listOfButtons[i].spriteOne.setPosition((Math.abs(listOfButtons[i].targetY * 70) * -1) - 270,
				(FlxMath.remapToRange(listOfButtons[i].targetY, 0, 1, 0, 1.3) * 90) + (FlxG.height * 0.45));
		}

		curSelected = 0;

		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 2);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 2);

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

		if(listOfButtons[curSelected].locked){
			portrait.shader = rimlight.shader;
			portrait.color = FlxColor.BLACK;
		}else{
			portrait.shader = null;
			portrait.color = FlxColor.WHITE;
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
		rimlight.rimlightColor = listOfButtons[curSelected].coloring;
	}
}
