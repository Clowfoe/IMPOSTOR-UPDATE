package;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
#if desktop
import Discord.DiscordClient;
#end
import WalkingCrewmate;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import openfl.Lib;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;

import openfl8.blends.*;
import openfl8.effects.*;
import openfl8.effects.WiggleEffect.WiggleEffectType;
import openfl8.effects.BlendModeEffect.BlendModeShader;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import openfl.filters.ShaderFilter;

import flixel.text.FlxText;


#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
var wiggleEffect:WiggleEffect;
	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var momMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var momMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var MOM_X:Float = 100;
	public var MOM_Y:Float = 100;
	//var wiggleEffect:WiggleEffect;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var momGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character;
	public var mom:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public var bfLegs:Boyfriend;
	public var dadlegs:Character;

	var bfAnchorPoint:Array<Float> = [0, 0];
	var dadAnchorPoint:Array<Float> = [0, 0];

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;

	var cameraLocked:Bool = false;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;
	var bfStartpos:FlxPoint;
	var dadStartpos:FlxPoint;
	var gfStartpos:FlxPoint;

	var tests:CCShader;
// ejected SHIT
	var cloudScroll:FlxTypedGroup<FlxSprite>;
	var farClouds:FlxTypedGroup<FlxSprite>;
	var middleBuildings:Array<FlxSprite>;
	var rightBuildings:Array<FlxSprite>;
	var leftBuildings:Array<FlxSprite>;
	var fgCloud:FlxSprite;
	var speedLines:FlxBackdrop;
	var speedPass:Array<Float> = [11000, 11000, 11000, 11000];
	var farSpeedPass:Array<Float> = [11000, 11000, 11000, 11000, 11000, 11000, 11000];
	var plat:FlxSprite;

	var airshipPlatform:FlxTypedGroup<FlxSprite>;
	var airFarClouds:FlxTypedGroup<FlxSprite>;
	var airMidClouds:FlxTypedGroup<FlxSprite>;
	var airCloseClouds:FlxTypedGroup<FlxSprite>;
	var airBigCloud:FlxSprite;
	var bigCloudSpeed:Float = 10;
	var airSpeedlines:FlxTypedGroup<FlxSprite>;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var snow:FlxSprite;
	var snow2:FlxSprite;
	var crowd:FlxSprite = new FlxSprite();
	var gray:FlxSprite = new FlxSprite();
	var neato:FlxSprite = new FlxSprite();
	var saster:FlxSprite = new FlxSprite();
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;
	//guh
	var loBlack:FlxSprite;
	//defeat
	var defeatthing:FlxSprite;
	var defeatblack:FlxSprite;
	var bodiesfront:FlxSprite;
	//loggo
	var peopleloggo:FlxSprite;
	var toogusblue:FlxSprite;
	var toogusorange:FlxSprite;
	var tooguswhite:FlxSprite;
	var speaker:FlxSprite;
	var thebackground:FlxSprite;
	var fireloggo:FlxSprite;
	var mapthing:FlxSprite;
	//reactor
	var amogus:FlxSprite;
	var dripster:FlxSprite;
	var yellow:FlxSprite;
	var brown:FlxSprite;
	var ass2:FlxSprite;
	var ass3:FlxSprite;
	var orb:FlxSprite = new FlxSprite();
	
	//pink
	var cloud1:FlxBackdrop;
	var cloud2:FlxBackdrop;
	var cloud3:FlxBackdrop;
	var cloud4:FlxBackdrop;
	var cloudbig:FlxBackdrop;
	var greymira:FlxSprite;
	var cyanmira:FlxSprite;
	var limemira:FlxSprite;
	var bluemira:FlxSprite;
	var oramira:FlxSprite;
	var vines:FlxSprite;

	//who
	var space:FlxSprite;
    var starsBG:FlxBackdrop;
    var starsFG:FlxBackdrop;
	var meeting:FlxSprite;

	//jorsawsee
	var loungebg:FlxSprite;

	//votingtime
	var table:FlxSprite;
	var votingbg:FlxSprite;
	var otherroom:FlxSprite;
	var chairs:FlxSprite;
	var vt_light:FlxSprite;
	var bars:FlxSprite;

	//bananungus
	var bananas:FlxSprite;
	var bunches:FlxSprite;
	var leaves:FlxSprite;

	//toogus
	var saxguy:FlxSprite;
	var lightoverlay:FlxSprite;
	var mainoverlay:FlxSprite;
	var crowd2:FlxSprite;
	var walker:WalkingCrewmate;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public var tweeningChar:Bool = false;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;
	var songLength:Float = 0;

	private var task:TaskSong;

	var curPortrait:String = "";
	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var luaArray:Array<FunkinLua> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	var opponent2sing:Bool = false;
	var bothOpponentsSing:Bool = false;

	// Lua shit
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';
	//hardcoded flashes because my ass aint redoing them as an event then retiming them all fuck that
	var _cb = 0;
	var flashSprite:FlxSprite = new FlxSprite(0, 0).makeGraphic(1920, 1080, 0xFFb30000);
	var stageFront2:FlxSprite;
	var stageFront3:FlxSprite;
	var overlay:FlxSprite;

	var charShader:BWShader;

	override public function create()
	{
		super.create();

		resetSpriteCache = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if(PlayState.SONG.stage.toLowerCase() == 'airship') {
			camGame.height = FlxG.height + 200;
			camGame.y -= 100;
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null
		 || PlayState.SONG.stage.length < 1) {
				curStage = 'stage';
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
				
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				secondopp: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		MOM_X = stageData.secondopp[0];
		MOM_Y = stageData.secondopp[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		momGroup = new FlxSpriteGroup(MOM_X, MOM_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'plantroom': //pink stage
				var bg:FlxSprite = new FlxSprite(-1500, -800).loadGraphic(Paths.image('mira/bg sky', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);
				var bg:FlxSprite = new FlxSprite(-1300, -100).loadGraphic(Paths.image('mira/cloud fathest', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);
				
				var bg:FlxSprite = new FlxSprite(-1300, 0).loadGraphic(Paths.image('mira/cloud front', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

				cloud1 = new FlxBackdrop(Paths.image('mira/cloud 1', 'impostor'), 1, 1, true, true);
						cloud1.setPosition(0, -1000);
						cloud1.updateHitbox();
						cloud1.antialiasing = true;
						cloud1.scrollFactor.set(1, 1);
						add(cloud1);

				cloud2 = new FlxBackdrop(Paths.image('mira/cloud 2', 'impostor'), 1, 1, true, true);
						cloud2.setPosition(0, -1200);
						cloud2.updateHitbox();
						cloud2.antialiasing = true;
						cloud2.scrollFactor.set(1, 1);
						add(cloud2);
						
				cloud3 = new FlxBackdrop(Paths.image('mira/cloud 3', 'impostor'), 1, 1, true, true);
						cloud3.setPosition(0, -1400);
						cloud3.updateHitbox();
						cloud3.antialiasing = true;
						cloud3.scrollFactor.set(1, 1);
						add(cloud3);

				cloud4 = new FlxBackdrop(Paths.image('mira/cloud 4', 'impostor'), 1, 1, true, true);
						cloud4.setPosition(0, -1600);
						cloud4.updateHitbox();
						cloud4.antialiasing = true;
						cloud4.scrollFactor.set(1, 1);
						add(cloud4);
					
				cloudbig = new FlxBackdrop(Paths.image('mira/bigcloud', 'impostor'), 1, 1, true, true);
						cloudbig.setPosition(0, -1200);
						cloudbig.updateHitbox();
						cloudbig.antialiasing = true;
						cloudbig.scrollFactor.set(1, 1);
						add(cloudbig);
	
				var bg:FlxSprite = new FlxSprite(-1200, -750).loadGraphic(Paths.image('mira/glasses', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

				greymira = new FlxSprite(0, -100);
						greymira.frames = Paths.getSparrowAtlas('mira/crew', 'impostor');	
						greymira.animation.addByPrefix('bop', 'skrunk', 24, true);
						greymira.animation.play('bop');
						greymira.antialiasing = true;
						greymira.scrollFactor.set(1, 1);
						greymira.active = true;
						add(greymira);

				var bg:FlxSprite = new FlxSprite(0, -710).loadGraphic(Paths.image('mira/what is this', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

				cyanmira = new FlxSprite(800, 100);
						cyanmira.frames = Paths.getSparrowAtlas('mira/crew', 'impostor');	
						cyanmira.animation.addByPrefix('bop', 'cyan', 24, true);
						cyanmira.animation.play('bop');
						cyanmira.antialiasing = true;
						cyanmira.scrollFactor.set(1, 1);
						cyanmira.active = true;
						add(cyanmira);
					
				limemira = new FlxSprite(1300, -300);
						limemira.frames = Paths.getSparrowAtlas('mira/crew', 'impostor');	
						limemira.animation.addByPrefix('bop', 'lmao 2', 24, true);
						limemira.animation.play('bop');
						limemira.antialiasing = true;
						limemira.scrollFactor.set(1, 1);
						limemira.active = true;
						add(limemira);
				
				oramira = new FlxSprite(1000, 450);
						oramira.frames = Paths.getSparrowAtlas('mira/crew', 'impostor');	
						oramira.animation.addByPrefix('bop', 'orange', 24, true);
						oramira.animation.play('bop');
						oramira.antialiasing = true;
						oramira.scrollFactor.set(1.2, 1);
						oramira.active = true;
						add(oramira);

				var bg:FlxSprite = new FlxSprite(-800, -10).loadGraphic(Paths.image('mira/lmao', 'impostor'));
						bg.antialiasing = true;
						bg.setGraphicSize(Std.int(bg.width * 0.9));
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

				bluemira = new FlxSprite(-1400, 0);
						bluemira.frames = Paths.getSparrowAtlas('mira/crew', 'impostor');	
						bluemira.animation.addByPrefix('bop', 'lmao 3', 24, true);
						bluemira.animation.play('bop');
						bluemira.antialiasing = true;
						bluemira.scrollFactor.set(1.2, 1);
						bluemira.active = true;
						add(bluemira);
					
				vines = new FlxSprite(-1400, -800);
						vines.frames = Paths.getSparrowAtlas('mira/vines', 'impostor');	
						vines.animation.addByPrefix('bop', 'green', 24, true);
						vines.animation.play('bop');
						vines.antialiasing = true;
						vines.scrollFactor.set(1.4, 1);
						vines.active = true;
		
			case 'cargo': //double kill
				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('airship/cargo', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

			case 'lounge': //lotowncorry + 02
				var loungebg:FlxSprite = new FlxSprite(-264.6, -66.25).loadGraphic(Paths.image('airship/lounge', 'impostor'));
						loungebg.antialiasing = true;
						loungebg.scrollFactor.set(1, 1);
						loungebg.active = false;
						add(loungebg);

			case 'voting': //lotowncorry + 02
				var otherroom:FlxSprite = new FlxSprite(387.3, 194.1).loadGraphic(Paths.image('airship/backer_groung_voting', 'impostor'));
					otherroom.antialiasing = true;
					otherroom.scrollFactor.set(0.8, 0.8);
					otherroom.active = false;
						add(otherroom);

				var votingbg:FlxSprite = new FlxSprite(-315.15, 52.85).loadGraphic(Paths.image('airship/main_bg_meeting', 'impostor'));
					votingbg.antialiasing = true;
					votingbg.scrollFactor.set(0.95, 0.95);
					votingbg.active = false;
						add(votingbg);

				var chairs:FlxSprite = new FlxSprite(-7.9, 644.85).loadGraphic(Paths.image('airship/CHAIRS!!!!!!!!!!!!!!!', 'impostor'));
					chairs.antialiasing = true;
					chairs.scrollFactor.set(1.0, 1.0);
					chairs.active = false;
						add(chairs);

				table = new FlxSprite(209.4, 679.55).loadGraphic(Paths.image('airship/table_voting', 'impostor'));
				table.antialiasing = true;
				table.scrollFactor.set(1.0, 1.0);
				table.active = false;

			case 'banana': //ra ra rasputin
				var sky:FlxSprite = new FlxSprite(-221.85, -167.85).loadGraphic(Paths.image('banana/sky', 'impostor'));
						sky.antialiasing = true;
						sky.scrollFactor.set(0.5, 0.5);
						sky.active = false;
						add(sky);

				var hills:FlxSprite = new FlxSprite(-358, 438.4).loadGraphic(Paths.image('banana/mountains', 'impostor'));
						hills.antialiasing = true;
						hills.scrollFactor.set(0.8, 0.8);
						hills.active = false;
						add(hills);

				var ground:FlxSprite = new FlxSprite(-331.95, 608.9).loadGraphic(Paths.image('banana/ground', 'impostor'));
						ground.antialiasing = true;
						ground.scrollFactor.set(1.0, 1.0);
						ground.active = false;
						add(ground);

				bananas = new FlxSprite(117.7, 928.4).loadGraphic(Paths.image('banana/bananas', 'impostor'));
				bananas.antialiasing = true;
				bananas.scrollFactor.set(1.1, 1.1);
				bananas.active = false;

				bunches = new FlxSprite(-284.55, -168).loadGraphic(Paths.image('banana/bananabunches', 'impostor'));
				bunches.antialiasing = true;
				bunches.scrollFactor.set(1.3, 1.3);
				bunches.active = false;

				leaves = new FlxSprite(-78.2, -293.9).loadGraphic(Paths.image('banana/leaves', 'impostor'));
				leaves.antialiasing = true;
				leaves.scrollFactor.set(1.5, 1.5);
				leaves.active = false;

			case 'who': //dead dead guy
				var bg:FlxSprite = new FlxSprite(0, 100).loadGraphic(Paths.image('polus/deadguy', 'impostor'));
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);
				
				meeting = new FlxSprite(0, -360);
						meeting.frames = Paths.getSparrowAtlas('polus/meeting', 'impostor');	
						meeting.animation.addByPrefix('bop', 'meeting buzz', 24, false);
						meeting.antialiasing = true;
						meeting.scrollFactor.set(1, 1);
						meeting.active = true;
						meeting.visible = false;
						add(meeting);
						meeting.setGraphicSize(Std.int(meeting.width * 0.5));
						//meeting.screenCenter();
				
				space = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height* 3, FlxColor.BLACK);
						space.antialiasing = true;
						space.updateHitbox();
						space.scrollFactor.set();
						add(space);
						space.visible = false;
				
				starsBG = new FlxBackdrop(Paths.image('freeplay/starBG', 'impostor'), 1, 1, true, true);
						starsBG.setPosition(111.3, 67.95);
						starsBG.antialiasing = true;
						starsBG.updateHitbox();
						starsBG.scrollFactor.set();
						add(starsBG);
						starsBG.visible = false;
						
				starsFG = new FlxBackdrop(Paths.image('freeplay/starFG', 'impostor'), 5, 5, true, true);
						starsFG.setPosition(54.3, 59.45);
						starsFG.updateHitbox();
						starsFG.antialiasing = true;
						starsFG.scrollFactor.set();
						add(starsFG);
						starsFG.visible = false;
			
			case 'airshipRoom': //thanks fabs

				var skyyellow:FlxSprite = new FlxSprite(-1858.33333333333, -2161.66666666667).loadGraphic(Paths.image('airship/Sky_Yellow', 'impostor'));
						skyyellow.antialiasing = true;
						skyyellow.scrollFactor.set(0.2, 0.2);
						skyyellow.active = false;
						add(skyyellow);

				var bluechair:FlxSprite = new FlxSprite(0, 1).loadGraphic(Paths.image('airship/Blu_Chair_Yellow', 'impostor'));
						bluechair.antialiasing = true;
						bluechair.scrollFactor.set(1, 1);
						bluechair.active = false;
						add(bluechair);

				var cloudyellow:FlxSprite = new FlxSprite(-2175, -163.666666666667).loadGraphic(Paths.image('airship/Clouds_Yellow', 'impostor'));
						cloudyellow.antialiasing = true;
						cloudyellow.scrollFactor.set(0.6, 0.6);
						cloudyellow.active = false;
						add(cloudyellow);
				
				var bottomyellow:FlxSprite = new FlxSprite(-2287.5, -1873).loadGraphic(Paths.image('airship/Bottom_Floor_Yellow', 'impostor'));
						bottomyellow.antialiasing = true;
						bottomyellow.scrollFactor.set(1, 1);
						bottomyellow.active = false;
						add(bottomyellow);
				
				var topyellow:FlxSprite = new FlxSprite(-2050, 6).loadGraphic(Paths.image('airship/Top_Floor_Yellow', 'impostor'));
						topyellow.antialiasing = true;
						topyellow.scrollFactor.set(1, 1);
						topyellow.active = false;
						add(topyellow);

				var cpyellow:FlxSprite = new FlxSprite(-300, -33.5).loadGraphic(Paths.image('airship/Control_Panel_Yellow', 'impostor'));
						cpyellow.antialiasing = true;
						cpyellow.scrollFactor.set(1, 1);
						cpyellow.active = false;
						add(cpyellow);

				mapthing = new FlxSprite(0, -360);
						mapthing.frames = Paths.getSparrowAtlas('airship/Map_Bounce', 'impostor');	
						mapthing.animation.addByPrefix('bop', 'Map  instance 1', 24, true);
						mapthing.animation.play('bop');
						mapthing.antialiasing = false;
						mapthing.scrollFactor.set(1, 1);
						mapthing.active = true;
						add(mapthing);

			case 'loggo': //loggo normal

				var bg:BGSprite = new BGSprite('space', 0, 200, 0.8, 0.8);
				add(bg);
				bg.setGraphicSize(Std.int(bg.width * 3));
				bg.antialiasing = false;

				var stageFront:BGSprite = new BGSprite('normalOne', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 3));
				stageFront.updateHitbox();
				add(stageFront);
				stageFront.antialiasing = false;

				peopleloggo = new FlxSprite(150, 1200);
								peopleloggo.frames = Paths.getSparrowAtlas('people');
								peopleloggo.animation.addByPrefix('bop', 'the guys', 24, false);
								peopleloggo.animation.play('bop');
								peopleloggo.setGraphicSize(Std.int(peopleloggo.width * 3));
								peopleloggo.antialiasing = false;
								peopleloggo.scrollFactor.set(0.9, 0.9);
								peopleloggo.active = true;
								add(peopleloggo);
				
				fireloggo = new FlxSprite(150, 1200);
								fireloggo.frames = Paths.getSparrowAtlas('stockingFire');
								fireloggo.animation.addByPrefix('bop', 'stocking fire', 24, true);
								fireloggo.animation.play('bop');
								fireloggo.setGraphicSize(Std.int(fireloggo.width * 3));
								fireloggo.antialiasing = false;
								fireloggo.scrollFactor.set(0.9, 0.9);
								fireloggo.active = true;
								add(fireloggo);

			case 'loggo2': //dark loggo
				var bg:BGSprite = new BGSprite('space', 0, 200, 0.8, 0.8);
				add(bg);
				bg.setGraphicSize(Std.int(bg.width * 3));
				bg.antialiasing = false;

				var stageFront:BGSprite = new BGSprite('placeholder Hell', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 3));
				stageFront.updateHitbox();
				add(stageFront);
				stageFront.antialiasing = false;

				peopleloggo = new FlxSprite(150, 1200);
								peopleloggo.frames = Paths.getSparrowAtlas('people');
								peopleloggo.animation.addByPrefix('bop', 'the guys', 24, false);
								peopleloggo.animation.play('bop');
								peopleloggo.setGraphicSize(Std.int(peopleloggo.width * 3));
								peopleloggo.antialiasing = false;
								peopleloggo.scrollFactor.set(0.9, 0.9);
								peopleloggo.active = true;
								add(peopleloggo);

			case 'chef': //mayhew has gone mad	
						var wall:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chef/Back Wall Kitchen', 'impostor'));
						wall.antialiasing = true;
						wall.scrollFactor.set(1, 1);
						wall.setGraphicSize(Std.int(wall.width * 0.8));
						wall.active = false;
						add(wall);	

						var floor:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chef/Chef Floor', 'impostor'));
						floor.antialiasing = true;
						floor.scrollFactor.set(1, 1);
						floor.setGraphicSize(Std.int(floor.width * 0.8));
						floor.active = false;
						add(floor);	

						var backshit:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chef/Back Table Kitchen', 'impostor'));
						backshit.antialiasing = true;
						backshit.scrollFactor.set(1, 1);
						backshit.setGraphicSize(Std.int(backshit.width * 0.8));
						backshit.active = false;
						add(backshit);				

						gray = new FlxSprite(1000, 525);
						gray.frames = Paths.getSparrowAtlas('chef/Boppers', 'impostor');
						gray.animation.addByPrefix('bop', 'Gray bop', 24, false);
						gray.animation.play('bop');
						gray.antialiasing = true;
						gray.scrollFactor.set(1, 1);
						gray.setGraphicSize(Std.int(gray.width * 0.8));
						gray.active = true;
						add(gray);

						saster = new FlxSprite(1300, 525);
						saster.frames = Paths.getSparrowAtlas('chef/Boppers', 'impostor');
						saster.animation.addByPrefix('bop', 'Sas bop', 24, false);
						saster.animation.play('bop');
						saster.antialiasing = true;
						saster.scrollFactor.set(1, 1);
						saster.setGraphicSize(Std.int(saster.width * 1.2));
						saster.active = true;
						add(saster);

						neato = new FlxSprite(1900, 625);
						neato.frames = Paths.getSparrowAtlas('chef/Boppers', 'impostor');
						neato.animation.addByPrefix('bop', 'neato bop', 24, false);
						neato.animation.play('bop');
						neato.antialiasing = true;
						neato.scrollFactor.set(1, 1);
						neato.setGraphicSize(Std.int(neato.width * 1.2));
						neato.active = true;
						add(neato);

						var frontable:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chef/Kitchen Counter', 'impostor'));
						frontable.antialiasing = true;
						frontable.scrollFactor.set(1, 1);
						frontable.setGraphicSize(Std.int(frontable.width * 0.8));
						frontable.active = false;
						add(frontable);		
		
						

				case 'ejected':
					
						defaultCamZoom = 0.45;
						curStage = 'ejected';
						cloudScroll = new FlxTypedGroup<FlxSprite>();
						farClouds = new FlxTypedGroup<FlxSprite>();
						var sky:FlxSprite = new FlxSprite(-2372.25, -4181.7).loadGraphic(Paths.image('ejected/sky', 'impostor'));
						sky.antialiasing = true;
						sky.updateHitbox();
						sky.scrollFactor.set(0, 0);			
						add(sky);

						fgCloud = new FlxSprite(-2660.4, -402).loadGraphic(Paths.image('ejected/fgClouds', 'impostor'));
						fgCloud.antialiasing = true;
						fgCloud.updateHitbox();
						fgCloud.scrollFactor.set(0.2, 0.2);
						add(fgCloud);

						for(i in 0...farClouds.members.length) {
							add(farClouds.members[i]);
						}
						add(farClouds);

						rightBuildings = [];
						leftBuildings = [];
						middleBuildings = [];
						for(i in 0...2) {
							var rightBuilding = new FlxSprite(1022.3, -390.45);
							rightBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							rightBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
							rightBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
							rightBuilding.animation.play('1');
							rightBuilding.antialiasing = true;
							rightBuilding.updateHitbox();
							rightBuilding.scrollFactor.set(0.5, 0.5);
							add(rightBuilding);
							rightBuildings.push(rightBuilding);
						}
						
						for(i in 0...2) {
							var middleBuilding = new FlxSprite(-76.15, 1398.5);
							middleBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							middleBuilding.animation.addByPrefix('1', 'BuildingA1', 24, false);
							middleBuilding.animation.addByPrefix('2', 'BuildingA2', 24, false);
							middleBuilding.animation.play('1');
							middleBuilding.antialiasing = true;
							middleBuilding.updateHitbox();
							middleBuilding.scrollFactor.set(0.5, 0.5);
							add(middleBuilding);
							middleBuildings.push(middleBuilding);
						}
						
						for(i in 0...2) {
							var leftBuilding = new FlxSprite(-1099.3, 7286.55);
							leftBuilding.frames = Paths.getSparrowAtlas('ejected/buildingSheet', 'impostor');
							leftBuilding.animation.addByPrefix('1', 'BuildingB1', 24, false);
							leftBuilding.animation.addByPrefix('2', 'BuildingB2', 24, false);
							leftBuilding.animation.play('1');
							leftBuilding.antialiasing = true;
							leftBuilding.updateHitbox();
							leftBuilding.scrollFactor.set(0.5, 0.5);
							add(leftBuilding);
							leftBuildings.push(leftBuilding);
						}

						rightBuildings[0].y = 6803.1;
						middleBuildings[0].y = 8570.5;
						leftBuildings[0].y = 14050.2;

						for(i in 0...3) {
							//now i could add the clouds manually
							//but i wont!!! trolled
							var newCloud:FlxSprite = new FlxSprite();
							newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds', 'impostor');
							newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
							newCloud.animation.play('idle');
							newCloud.updateHitbox();
							newCloud.alpha = 1;
							
							switch(i) {
								case 0:
									newCloud.setPosition(-9.65, -224.35);
									newCloud.scrollFactor.set(0.8, 0.8);
								case 1:
									newCloud.setPosition(-1342.85, -350.45);
									newCloud.scrollFactor.set(0.6, 0.6);
								case 2:
									newCloud.setPosition(1784.65, -957.05);
									newCloud.scrollFactor.set(1.3, 1.3);
								case 3:
									newCloud.setPosition(-2217.45, -1377.65);
									newCloud.scrollFactor.set(1, 1);
							}
							cloudScroll.add(newCloud);								
						}

						for(i in 0...7) {
							var newCloud:FlxSprite = new FlxSprite();
							newCloud.frames = Paths.getSparrowAtlas('ejected/scrollingClouds', 'impostor');
							newCloud.animation.addByPrefix('idle', 'Cloud' + i, 24, false);
							newCloud.animation.play('idle');
							newCloud.updateHitbox();
							newCloud.alpha = 0.5;
							
							switch(i) {
								case 0:
									newCloud.setPosition(-1308, -1039.9);
								case 1:
									newCloud.setPosition(464.3, -890.5);
								case 2:
									newCloud.setPosition(2458.45, -1085.85);
								case 3:
									newCloud.setPosition(-666.95, -172.05);
								case 4:
									newCloud.setPosition(-1616.6, 1016.95);
								case 5:
									newCloud.setPosition(1714.25, 200.45);
								case 6:
									newCloud.setPosition(-167.05, 710.25);
							}
							farClouds.add(newCloud);								
						}

						plat = new FlxSprite();
						plat.frames = Paths.getSparrowAtlas('airship/floating_platform', 'impostor');
						plat.animation.addByPrefix('the', 'floating copy', 24, true);
						plat.animation.play('the');
						plat.updateHitbox();
						add(plat);

						speedLines = new FlxBackdrop(Paths.image('ejected/speedLines', 'impostor'), 1, 1, true, true);
						speedLines.antialiasing = true;
						speedLines.updateHitbox();
						speedLines.scrollFactor.set(1.3, 1.3);
						speedLines.alpha = 0.3;



			case 'alpha': //SHIT ASS
				curStage = 'alpha';				
				var bg:BGSprite = new BGSprite('HOTASS', -600, -200, 0.9, 0.9);
				add(bg);

			case 'dave': //crewicide
				curStage = 'dave';				
				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/DAVE', 'impostor'));
						bg.updateHitbox();
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);

			case 'grey': //SHIT ASS
				curStage = 'grey';				
				var thebackground = new FlxSprite(0, 0);
				thebackground.frames = Paths.getSparrowAtlas('airship/Gray_BG', 'impostor');
				thebackground.animation.addByPrefix('bop', 'BG', 24, true);
				thebackground.animation.play('bop');
				thebackground.antialiasing = true;
				thebackground.scrollFactor.set(1, 1);
				thebackground.setGraphicSize(Std.int(thebackground.width * 0.8));
				thebackground.active = true;
				add(thebackground);

			case 'drippypop': //SHIT ASS
				curStage = 'drippypop';	
				
				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('drip/dripfloor', 'impostor'));
						bg.updateHitbox();
						bg.antialiasing = true;
						bg.scrollFactor.set(1, 1);
						bg.active = false;
						add(bg);	

				var thebackground = new FlxSprite(0, 0);
				thebackground.frames = Paths.getSparrowAtlas('drip/drippers', 'impostor');
				thebackground.animation.addByPrefix('bop', 'dripbop', 24, false);
				thebackground.animation.play('bop');
				thebackground.antialiasing = true;
				thebackground.scrollFactor.set(1, 1);
				thebackground.active = true;
				add(thebackground);

				

			case 'henry': //stick Min
				var bg:BGSprite = new BGSprite('stagehenry', -1600, -300, 1, 1);
				add(bg);
			
			case 'charles': //harles
				GameOverSubstate.deathSoundName = 'henryDeath';
				GameOverSubstate.loopSoundName = 'deathHenryMusicLoop';
				GameOverSubstate.endSoundName = 'deathHenryMusicEnd';
				GameOverSubstate.characterName = 'henryphone';
				var bg:BGSprite = new BGSprite('stagehenry', -1600, -300, 1, 1);
				add(bg);

			case 'jerma': //fuck you neato
				var bg:BGSprite = new BGSprite('jerma', 0, 0, 1, 1);
				add(bg);

			//	var stageFront:BGSprite = new BGSprite('wall', 0, 0, 1, 1);
			//	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			//	stageFront.updateHitbox();
			//	add(stageFront);

			case 'polus': 
						curStage = 'polus';
						
 
						var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('polus/polus_custom_sky', 'impostor'));
						sky.antialiasing = true;
						sky.scrollFactor.set(0.5, 0.5);
						sky.setGraphicSize(Std.int(sky.width * 1.4));
						sky.active = false;
						add(sky);		
		
						var rocks:FlxSprite = new FlxSprite(-700, -300).loadGraphic(Paths.image('polus/polusrocks', 'impostor'));
						rocks.updateHitbox();
						rocks.antialiasing = true;
						rocks.scrollFactor.set(0.6, 0.6);
						rocks.active = false;
						add(rocks);	
						
						var hills:FlxSprite = new FlxSprite(-1050, -180.55).loadGraphic(Paths.image('polus/polusHills', 'impostor'));
						hills.updateHitbox();
						hills.antialiasing = true;
						hills.scrollFactor.set(0.9, 0.9);
						hills.active = false;
						add(hills);

						var warehouse:FlxSprite = new FlxSprite(50, -400).loadGraphic(Paths.image('polus/polus_custom_lab', 'impostor'));
						warehouse.updateHitbox();
						warehouse.antialiasing = true;
						warehouse.scrollFactor.set(1, 1);
						warehouse.active = false;
						add(warehouse);

						
						
						var ground:FlxSprite = new FlxSprite(-1350, 80).loadGraphic(Paths.image('polus/polus_custom_floor', 'impostor'));
						ground.updateHitbox();
						ground.antialiasing = true;
						ground.scrollFactor.set(1, 1);
						ground.active = false;
						add(ground);

						speaker = new FlxSprite(300, 185);
						speaker.frames = Paths.getSparrowAtlas('polus/speakerlonely', 'impostor');
						speaker.animation.addByPrefix('bop', 'speakers lonely', 24, false);
						speaker.animation.play('bop');
						speaker.setGraphicSize(Std.int(speaker.width * 1));
						speaker.antialiasing = false;
						speaker.scrollFactor.set(1, 1);
						speaker.active = true;
						speaker.antialiasing = true;
						if(SONG.song.toLowerCase() == 'sabotage') {
							add(speaker);
						}
						if(SONG.song.toLowerCase() == 'meltdown') {
							add(speaker);
						}
						
						

			
			case 'polus2': 
						curStage = 'polus2';
						 
						
 
						var sky:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newsky', 'impostor'));
						sky.antialiasing = true;
						sky.scrollFactor.set(1, 1);
						sky.active = false;
						sky.setGraphicSize(Std.int(sky.width * 0.75));
						add(sky);		

						var cloud:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newcloud', 'impostor'));
						cloud.antialiasing = true;
						cloud.scrollFactor.set(1, 1);
						cloud.active = false;
						cloud.setGraphicSize(Std.int(cloud.width * 0.75));
						cloud.alpha = 0.59;
						add(cloud);		

						var rocks:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newrocks', 'impostor'));
						rocks.antialiasing = true;
						rocks.scrollFactor.set(1, 1);
						rocks.active = false;
						rocks.setGraphicSize(Std.int(rocks.width * 0.75));
						rocks.alpha = 0.49;
						add(rocks);		

						var backwall:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/backwall', 'impostor'));
						backwall.antialiasing = true;
						backwall.scrollFactor.set(1, 1);
						backwall.active = false;
						backwall.setGraphicSize(Std.int(backwall.width * 0.75));
						add(backwall);		

						var stage:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newstage', 'impostor'));
						stage.antialiasing = true;
						stage.scrollFactor.set(1, 1);
						stage.active = false;
						stage.setGraphicSize(Std.int(stage.width * 0.75));
						add(stage);		

						


						


			case 'polus3': 
						curStage = 'polus3';
						 
						
 
				//		var sky:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/SkyPolusLol', 'impostor'));
				//		sky.antialiasing = true;
				//		sky.scrollFactor.set(0.5, 0.5);
				//		sky.active = false;
				//		sky.setGraphicSize(Std.int(sky.width * 1));
				//		add(sky);		

				//		var rocksbg:FlxSprite = new FlxSprite(-250, -400).loadGraphic(Paths.image('polus/Back_Rocks', 'impostor'));
				//		rocksbg.updateHitbox();
				//		rocksbg.antialiasing = true;
				//		rocksbg.setGraphicSize(Std.int(rocksbg.width * 1));
					//	rocksbg.scrollFactor.set(0.7, 0.7);
				//		rocksbg.active = false;
					//	add(rocksbg);	
		
				//		var rocks:FlxSprite = new FlxSprite(-100, 0).loadGraphic(Paths.image('polus/polus2rocks', 'impostor'));
				//		rocks.updateHitbox();
				//		rocks.antialiasing = true;
				//		rocks.setGraphicSize(Std.int(rocks.width * 1));
				//		rocks.scrollFactor.set(0.8, 0.8);
				//		rocks.active = false;
				//		add(rocks);	
						var edge:FlxSprite = new FlxSprite(750, -400).loadGraphic(Paths.image('polus/Edge', 'impostor'));
						edge.updateHitbox();
						edge.setGraphicSize(Std.int(edge.width * 1));
						edge.antialiasing = true;
						edge.scrollFactor.set(1, 1);
						edge.active = false;
						add(edge);

						var lava = new FlxSprite(450, 300);
						lava.frames = Paths.getSparrowAtlas('polus/lava', 'impostor');
						lava.animation.addByPrefix('bop', 'lava', 24, true);
						lava.animation.play('bop');
						lava.setGraphicSize(Std.int(lava.width * 1));
						lava.antialiasing = false;
						lava.scrollFactor.set(1, 1);
						lava.active = true;
						add(lava);
						
						var ground:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/platform', 'impostor'));
						ground.updateHitbox();
						ground.setGraphicSize(Std.int(ground.width * 0.4));
						ground.antialiasing = true;
						ground.scrollFactor.set(1, 1);
						ground.active = false;
						add(ground);

						var bubbles = new FlxSprite(900, 400);
						bubbles.frames = Paths.getSparrowAtlas('polus/bubbles', 'impostor');
						bubbles.animation.addByPrefix('bop', 'Lava Bubbles', 24, true);
						bubbles.animation.play('bop');
						bubbles.setGraphicSize(Std.int(bubbles.width * 1));
						bubbles.antialiasing = false;
						bubbles.scrollFactor.set(1, 1);
						bubbles.active = true;
						add(bubbles);

						

						

			case 'toogus':
						
								curStage = 'toogus';
								var bg:FlxSprite = new FlxSprite(-1600 ,50).loadGraphic(Paths.image('mirabg'));
								bg.setGraphicSize(Std.int(bg.width * 1.06));
								bg.antialiasing = true;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

							//	bgDark = new FlxSprite(0,50).loadGraphic(Paths.image('MiraDark'));
							//	bgDark.setGraphicSize(Std.int(bgDark.width * 1.4));
							//	bgDark.antialiasing = true;
							//	bgDark.scrollFactor.set(1, 1);
							//	bgDark.active = false;
							//	bgDark.alpha = 0;
							//	add(bgDark);

								var fg:FlxSprite = new FlxSprite(-1600 ,50).loadGraphic(Paths.image('mirafg'));
								fg.setGraphicSize(Std.int(fg.width * 1.06));
								fg.antialiasing = true;
								fg.scrollFactor.set(1, 1);
								fg.active = false;
								add(fg);
							
							//	machineDark = new FlxSprite(1000, 150).loadGraphic(Paths.image('vending_machineDark'));
							//	machineDark.updateHitbox();
							//	machineDark.antialiasing = true;
							///	machineDark.scrollFactor.set(1, 1);
							//	machineDark.active = false;
							//	machineDark.alpha = 0;
							//	add(machineDark);
							
							if(SONG.song.toLowerCase() == 'sussus toogus') {
								walker = new WalkingCrewmate(FlxG.random.int(0, 6), [-700, 1850], 70, 0.8);
								add(walker);

								var walker2:WalkingCrewmate = new WalkingCrewmate(FlxG.random.int(0, 6), [-700, 1850], 70, 0.8);
								add(walker2);

								var walker3:WalkingCrewmate = new WalkingCrewmate(FlxG.random.int(0, 6), [-700, 1850], 70, 0.8);
								add(walker3);
							}

							if(SONG.song.toLowerCase() == 'lights-down') {
								toogusblue = new FlxSprite(1200, 250);
								toogusblue.frames = Paths.getSparrowAtlas('mira/mirascaredmates', 'impostor' );
								toogusblue.animation.addByPrefix('bop', 'blue', 24, false);
								toogusblue.animation.addByPrefix('bop2', '1body', 24, false);
								toogusblue.animation.play('bop');
								toogusblue.setGraphicSize(Std.int(toogusblue.width * 0.7));
								toogusblue.scrollFactor.set(1, 1);
								toogusblue.active = true;
								toogusblue.antialiasing = true;
								toogusblue.flipX = true;
								add(toogusblue);

								toogusorange = new FlxSprite(-300, 250);
								toogusorange.frames = Paths.getSparrowAtlas('mira/mirascaredmates', 'impostor' );
								toogusorange.animation.addByPrefix('bop', 'orange', 24, false);
								toogusorange.animation.addByPrefix('bop2', '2body', 24, false);
								toogusorange.animation.play('bop');
								toogusorange.setGraphicSize(Std.int(toogusorange.width * 0.7));
								toogusorange.scrollFactor.set(1, 1);
								toogusorange.active = true;
								toogusorange.antialiasing = true;
								
							

								tooguswhite = new FlxSprite(1350, 200);
								tooguswhite.frames = Paths.getSparrowAtlas('mira/mirascaredmates', 'impostor' );
								tooguswhite.animation.addByPrefix('bop', 'white', 24, false);
								tooguswhite.animation.addByPrefix('bop2', '3body', 24, false);
								tooguswhite.animation.play('bop');
								tooguswhite.setGraphicSize(Std.int(tooguswhite.width * 0.9));
								tooguswhite.scrollFactor.set(1, 1);
								tooguswhite.active = true;
								tooguswhite.antialiasing = true;
								tooguswhite.flipX = true;
								add(tooguswhite);
							
							}

								
							


								var tbl:FlxSprite = new FlxSprite(-1600 ,50).loadGraphic(Paths.image('table_bg'));
								tbl.setGraphicSize(Std.int(tbl.width * 1.06));
								tbl.antialiasing = true;
								tbl.scrollFactor.set(1, 1);
								tbl.active = false;
								add(tbl);

							

								

							//	lightsOutSprite.alpha = 0;
							//	flashSprite.scrollFactor.set(0, 0);
							//	add(lightsOutSprite); // lights out stuff
			
							//	add(stageCurtains);
			case 'reactor':
					
							curStage = 'reactor';
							var bg:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/reactor background', 'impostor'));
							bg.setGraphicSize(Std.int(bg.width * 0.7));
							bg.antialiasing = true;
							bg.scrollFactor.set(1, 1);
							bg.active = false;
							add(bg);
							yellow = new FlxSprite(-400, 150);
							yellow.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
							yellow.animation.addByPrefix('bop', 'yellow sus', 24, false);
							yellow.animation.play('bop');
							yellow.setGraphicSize(Std.int(yellow.width * 0.7));
							yellow.antialiasing = true;
							yellow.scrollFactor.set(1, 1);
							yellow.active = true;
							add(yellow);
							var pillar1:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/back pillars', 'impostor'));
							pillar1.setGraphicSize(Std.int(pillar1.width * 0.7));
							pillar1.antialiasing = true;
							pillar1.scrollFactor.set(1, 1);
							pillar1.active = false;
							add(pillar1);
							dripster = new FlxSprite(1375, 150);
							dripster.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
							dripster.animation.addByPrefix('bop', 'blue sus', 24, false);
							dripster.animation.play('bop');
							dripster.setGraphicSize(Std.int(dripster.width * 0.7));
							dripster.antialiasing = true;
							dripster.scrollFactor.set(1, 1);
							dripster.active = true;
							add(dripster);
							var pillar2:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/middle pillars', 'impostor'));
							pillar2.setGraphicSize(Std.int(pillar2.width * 0.7));
							pillar2.antialiasing = true;
							pillar2.scrollFactor.set(1, 1);
							pillar2.active = false;
							add(pillar2);
							amogus = new FlxSprite(1670, 250);
							amogus.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
							amogus.animation.addByPrefix('bop', 'white sus', 24, false);
							amogus.animation.play('bop');
							amogus.setGraphicSize(Std.int(amogus.width * 0.7));
							amogus.antialiasing = true;
							amogus.scrollFactor.set(1, 1);
							amogus.active = true;
							add(amogus);
							brown = new FlxSprite(-850, 190);
							brown.frames = Paths.getSparrowAtlas('reactor/susBoppers', 'impostor');
							brown.animation.addByPrefix('bop', 'brown sus', 24, false);
							brown.animation.play('bop');
							brown.setGraphicSize(Std.int(brown.width * 0.7));
							brown.antialiasing = true;
							brown.scrollFactor.set(1, 1);
							brown.active = true;
							add(brown);
							var pillar3:FlxSprite = new FlxSprite(-2300,-1700).loadGraphic(Paths.image('reactor/front pillars', 'impostor'));
							pillar3.setGraphicSize(Std.int(pillar3.width * 0.7));
							pillar3.antialiasing = true;
							pillar3.scrollFactor.set(1, 1);
							pillar3.active = false;
							add(pillar3);
							orb = new FlxSprite(-460,-1300).loadGraphic(Paths.image('reactor/ball of big ol energy', 'impostor'));
							orb.setGraphicSize(Std.int(orb.width * 0.7));
							orb.antialiasing = true;
							orb.scrollFactor.set(1, 1);
							orb.active = false;
							add(orb);
							var cranes:FlxSprite = new FlxSprite(-735, -1500).loadGraphic(Paths.image('reactor/upper cranes', 'impostor'));
							cranes.setGraphicSize(Std.int(cranes.width * 0.7));
							cranes.antialiasing = true;
							cranes.scrollFactor.set(1, 1);
							cranes.active = false;
							add(cranes);
							var console1:FlxSprite = new FlxSprite(-260,150).loadGraphic(Paths.image('reactor/center console', 'impostor'));
							console1.setGraphicSize(Std.int(console1.width * 0.7));
							console1.antialiasing = true;
							console1.scrollFactor.set(1, 1);
							console1.active = false;
							add(console1);
							
							var console2:FlxSprite = new FlxSprite(-1380,450).loadGraphic(Paths.image('reactor/side console', 'impostor'));
							console2.setGraphicSize(Std.int(console2.width * 0.7));
							console2.antialiasing = true;
							console2.scrollFactor.set(1, 1);
							console2.active = false;
							add(console2);						
								

			
							//	add(stageCurtains);
						
											
			case 'defeat':
					
						
						curStage = 'defeat';
						

						defeatthing = new FlxSprite(-400, -150);
							defeatthing.frames = Paths.getSparrowAtlas('defeat');
							defeatthing.animation.addByPrefix('bop', 'defeat', 24, false);
							defeatthing.animation.play('bop');
							defeatthing.setGraphicSize(Std.int(defeatthing.width * 1.3));
							defeatthing.antialiasing = true;
							defeatthing.scrollFactor.set(0.8, 0.8);
							defeatthing.active = true;
							add(defeatthing);

							var bodies:FlxSprite = new FlxSprite(-2760,0).loadGraphic(Paths.image('deadBG'));
							bodies.setGraphicSize(Std.int(bodies.width * 0.4));
							bodies.antialiasing = true;
							bodies.scrollFactor.set(0.9, 0.9);
							bodies.active = false;
							add(bodies);

							defeatblack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height + 700, FlxColor.BLACK);
							defeatblack.alpha = 0;
							defeatblack.screenCenter(X);
							defeatblack.screenCenter(Y);
							add(defeatblack);

							bodiesfront = new FlxSprite(-2830,0).loadGraphic(Paths.image('deadFG'));
							bodiesfront.setGraphicSize(Std.int(bodiesfront.width * 0.4));
							bodiesfront.antialiasing = true;
							bodiesfront.scrollFactor.set(0.5, 1);
							bodiesfront.active = false;
					

			case 'tripletrouble':
					
						
						curStage = 'tripletrouble';

							var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('ttv4'));
							bg.setGraphicSize(Std.int(bg.width * 1));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);

							var fg:FlxSprite = new FlxSprite(300,300).loadGraphic(Paths.image('ttv4fg'));
							fg.setGraphicSize(Std.int(fg.width * 1));
							fg.antialiasing = true;
							fg.scrollFactor.set(1, 1);
							fg.active = false;
							add(fg);

							wiggleEffect = new WiggleEffect();
							wiggleEffect.effectType = WiggleEffectType.DREAMY;
							wiggleEffect.waveAmplitude = 0.1;
							wiggleEffect.waveFrequency = 5;
							wiggleEffect.waveSpeed = 1;
							bg.shader = wiggleEffect.shader;

		
			case 'airship':

				airshipPlatform = new FlxTypedGroup<FlxSprite>();
				airFarClouds = new FlxTypedGroup<FlxSprite>();
				airMidClouds = new FlxTypedGroup<FlxSprite>();
				airCloseClouds = new FlxTypedGroup<FlxSprite>();
				airSpeedlines = new FlxTypedGroup<FlxSprite>();

				var sky:FlxSprite = new FlxSprite(-1404, -897.55).loadGraphic(Paths.image('airship/sky', 'impostor'));
				sky.antialiasing = true;
				sky.updateHitbox();
				sky.scale.set(1.5, 1.5);
				sky.scrollFactor.set(0, 0);
				add(sky);

				for(i in 0...2) {
					var cloud:FlxSprite = new FlxSprite(-1148.05, -142.2).loadGraphic(Paths.image('airship/farthestClouds', 'impostor'));
					switch(i) {
						case 1:
							cloud.setPosition(-5678.95, -142.2);
						case 2:
							cloud.setPosition(3385.95, -142.2);
					}
					cloud.antialiasing = true;
					cloud.updateHitbox();
					cloud.scrollFactor.set(0.1, 0.1);
					airFarClouds.add(cloud);
				}
				add(airFarClouds);			


				for(i in 0...2) {
					var cloud:FlxSprite = new FlxSprite(-1162.4, 76.55).loadGraphic(Paths.image('airship/backClouds', 'impostor'));
					switch(i) {
						case 1:
							cloud.setPosition(3352.4, 76.55);
						case 2:
							cloud.setPosition(-5651.4, 76.55);
					}
					cloud.antialiasing = true;
					cloud.updateHitbox();
					cloud.scrollFactor.set(0.2, 0.2);
					airMidClouds.add(cloud);
				}
				add(airMidClouds);

				var airship:FlxSprite = new FlxSprite(1114.75, -873.05).loadGraphic(Paths.image('airship/airship', 'impostor'));
				airship.antialiasing = true;
				airship.updateHitbox();
				airship.scrollFactor.set(0.25, 0.25);
				add(airship);

				var fan:FlxSprite = new FlxSprite(2285.4, 102);
				fan.frames = Paths.getSparrowAtlas('airship/airshipFan', 'impostor');
				fan.animation.addByPrefix('idle', 'ala avion instance 1', 24, true);
				fan.animation.play('idle');
				fan.updateHitbox();
				fan.antialiasing = true;
				fan.scrollFactor.set(0.27, 0.27);
				add(fan);

				airBigCloud = new FlxSprite(3507.15, -744.2).loadGraphic(Paths.image('airship/bigCloud', 'impostor'));
				airBigCloud.antialiasing = true;
				airBigCloud.updateHitbox();
				airBigCloud.scrollFactor.set(0.4, 0.4);
				add(airBigCloud);

				for(i in 0...2) {
					var cloud:FlxSprite = new FlxSprite(-1903.9, 422.15).loadGraphic(Paths.image('airship/frontClouds', 'impostor'));
					switch(i) {
						case 1:
							cloud.setPosition(-9900.2, 422.15);
						case 2:
							cloud.setPosition(6092.2, 422.15);
					}
					cloud.antialiasing = true;
					cloud.updateHitbox();
					cloud.scrollFactor.set(0.3, 0.3);
					airCloseClouds.add(cloud);
				}
				add(airCloseClouds);

				for(i in 0...2) {					
					var platform:FlxSprite = new FlxSprite(-1454.2, 282.25).loadGraphic(Paths.image('airship/fgPlatform', 'impostor'));
					switch(i) {
						case 1:							
							platform.setPosition(-7184.8, 282.25);
							
						case 2:
							platform.setPosition(4275.15, 282.25);
					}
					platform.antialiasing = true;
					platform.updateHitbox();
					platform.scrollFactor.set(1, 1);
					add(platform);
					airshipPlatform.add(platform);
				}

				


			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgStreet.width * 6);

				bgStreet.setGraphicSize(widShit);
				bgStreet.updateHitbox();
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		loBlack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height + 700, FlxColor.BLACK);
		loBlack.alpha = 0;
		loBlack.screenCenter(X);
		loBlack.screenCenter(Y);
		add(loBlack);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (curSong == 'armed')
			add(momGroup);
		
		switch(curStage.toLowerCase()){
			case 'cargo':
				add(momGroup);
				

		}

	//	if (curStage == 'charles')
	//	{
	//		add(boyfriendGroup);
	//		add(dadGroup);
			//add(momGroup);
			
//		}
	//	else
//		{	
		if (curSong == 'voting')
			add(momGroup);

			add(dadGroup);
			//add(momGroup);
			add(boyfriendGroup);
//		}	

		if (curStage == 'defeat')
			add(bodiesfront);

		if (curStage == 'voting')
			add(table);

		if (curStage == 'banana')
			add(bananas);
			add(bunches);
			add(leaves);
		
		switch(curStage) {
			case 'plantroom':
				add(vines);
			case 'ejected':
				bfStartpos = new FlxPoint(1008.6, 504);
				gfStartpos = new FlxPoint(114.4, 78.45);
				dadStartpos = new FlxPoint(-775.75, 274.3);
				for(i in 0...cloudScroll.members.length) {
					add(cloudScroll.members[i]);
				}
				add(cloudScroll);
				add(speedLines);

			case 'polus':
				snow = new FlxSprite(0, -250);
				snow.frames = Paths.getSparrowAtlas('polus/snow', 'impostor');
				snow.animation.addByPrefix('cum', 'cum', 24);
				snow.animation.play('cum');
				snow.scrollFactor.set(1, 1);
				snow.antialiasing = true;
				snow.updateHitbox();
				snow.setGraphicSize(Std.int(snow.width * 2));


				
				add(snow);
				crowd2 = new FlxSprite(-900, 150);
				crowd2.frames = Paths.getSparrowAtlas('polus/boppers_meltdown', 'impostor');
				crowd2.animation.addByPrefix('bop', 'BoppersMeltdown', 24, false);
				crowd2.animation.play('bop');
				crowd2.scrollFactor.set(1.5, 1.5);
				crowd2.antialiasing = true;
				crowd2.updateHitbox();
				crowd2.scale.set(1, 1);
				if(SONG.song.toLowerCase() == 'meltdown') {
						add(crowd2);
					}
			case 'toogus':
				saxguy = new FlxSprite(0, 0);
				saxguy.frames = Paths.getSparrowAtlas('mira/cyan_toogus', 'impostor');
				saxguy.animation.addByPrefix('bop', 'Cyan Dancy', 24, true);
				saxguy.animation.play('bop');
				saxguy.updateHitbox();
				saxguy.antialiasing = true;
				saxguy.scrollFactor.set(1, 1);					
				saxguy.setGraphicSize(Std.int(saxguy.width * 0.9));
				saxguy.active = true;
			case 'cargo':
				var lightoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('airship/lights help', 'impostor'));
				lightoverlay.antialiasing = true;
				lightoverlay.scrollFactor.set(1, 1);
				lightoverlay.active = false;
				lightoverlay.alpha = 0.51;
				lightoverlay.blend = ADD;
				add(lightoverlay);

				var mainoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('airship/lights help', 'impostor'));
				mainoverlay.antialiasing = true;
				mainoverlay.scrollFactor.set(1, 1);
				mainoverlay.active = false;
				mainoverlay.alpha = 0.6;
				mainoverlay.blend = ADD;
				add(mainoverlay);
			case 'lounge':
				var loungelight:FlxSprite = new FlxSprite(-368.5, -135.55).loadGraphic(Paths.image('airship/loungelight', 'impostor'));
				loungelight.antialiasing = true;
				loungelight.scrollFactor.set(1, 1);
				loungelight.active = false;
				loungelight.alpha = 0.33;
				loungelight.blend = ADD;
				add(loungelight);
			case 'banana':
					var lightoverlay:FlxSprite = new FlxSprite(-221.85, -167.7).loadGraphic(Paths.image('banana/LIGHTSOURCE', 'impostor'));
					lightoverlay.antialiasing = true;
					lightoverlay.scrollFactor.set(1, 1);
					lightoverlay.active = false;
					lightoverlay.alpha = 0.41;
					lightoverlay.blend = ADD;
					add(lightoverlay);
			case 'grey':
				var lightoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('airship/coolthing', 'impostor'));
				lightoverlay.antialiasing = true;
				lightoverlay.scrollFactor.set(1, 1);
				lightoverlay.active = false;
				lightoverlay.alpha = 0.83;
				lightoverlay.blend = MULTIPLY;
				add(lightoverlay);


			case 'polus2':

				snow2 = new FlxSprite(1150, 600);
				snow2.frames = Paths.getSparrowAtlas('polus/snowback', 'impostor');
				snow2.animation.addByPrefix('cum', 'Snow group instance 1', 24);
				snow2.animation.play('cum');
				snow2.scrollFactor.set(1, 1);
				snow2.antialiasing = true;
				snow2.alpha = 0.53;
				snow2.updateHitbox();
				snow2.setGraphicSize(Std.int(snow2.width * 2));

				snow = new FlxSprite(1150, 800);
				snow.frames = Paths.getSparrowAtlas('polus/snowfront', 'impostor');
				snow.animation.addByPrefix('cum', 'snow fall front instance 1', 24);
				snow.animation.play('cum');
				snow.scrollFactor.set(1, 1);
				snow.antialiasing = true;
				snow.alpha = 0.37;
				snow.updateHitbox();
				snow.setGraphicSize(Std.int(snow.width * 2));
				
				var mainoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newoverlay', 'impostor'));
				mainoverlay.antialiasing = true;
				mainoverlay.scrollFactor.set(1, 1);
				mainoverlay.active = false;
				mainoverlay.setGraphicSize(Std.int(mainoverlay.width * 0.75));
				mainoverlay.alpha = 0.44;
				mainoverlay.blend = ADD;
				add(mainoverlay);		

				var lightoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('polus/newoverlay', 'impostor'));
				lightoverlay.antialiasing = true;
				lightoverlay.scrollFactor.set(1, 1);
				lightoverlay.active = false;
				lightoverlay.setGraphicSize(Std.int(lightoverlay.width * 0.75));
				lightoverlay.alpha = 0.21;
				lightoverlay.blend = ADD;
				add(lightoverlay);		



				add(snow2);
				add(snow);
			case 'chef':
				
				
			
			case 'polus3':
				
			case 'spooky':
				add(halloweenWhite);
			case 'airship':
				for(i in 0...2) {
					var speedline:FlxSprite = new FlxSprite(-912.75, -1035.95).loadGraphic(Paths.image('airship/speedlines', 'impostor'));
					switch(i) {
						case 1:
							speedline.setPosition(3352.1, -1035.95);
						case 2:
							speedline.setPosition(-5140.05, -1035.95);
					}
					speedline.antialiasing = true;
					speedline.alpha = 0.2;
					speedline.updateHitbox();
					speedline.scrollFactor.set(1.3, 1.3);
					add(speedline);
					airSpeedlines.add(speedline);
				}
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			} else if(members.indexOf(momGroup) < position) {
				position = members.indexOf(momGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;
		#end

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		if(curSong == 'Ejected') {
			gf.scrollFactor.set(0.7, 0.7);
		}
		else {
			gf.scrollFactor.set(1, 1);
		}

		
		
		gfGroup.add(gf);

		if(SONG.player2 == 'black-run')
			{
				dadlegs = new Character(0, 0, 'blacklegs');
				dadGroup.add(dadlegs);
			}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		if(SONG.player2 == 'black-run')
			{
				dadlegs.x = dad.x;
				dadlegs.y = dad.y;
			}

		mom = new Character(0, 0, SONG.player4);
		startCharacterPos(mom, true);
		momGroup.add(mom);

		if(SONG.player1 == 'bf-running')
		{
			bfLegs = new Boyfriend(0, 0, 'bf-legs');
			boyfriendGroup.add(bfLegs);
		}
		
		if(ClientPrefs.charOverride != ''){
			SONG.player1 = ClientPrefs.charOverride;
		}
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		if(SONG.player1 == 'bf-running')
		{
			bfLegs.x = boyfriend.x;
			bfLegs.y = boyfriend.y;
		}	

		bfAnchorPoint[0] = boyfriend.x;
		bfAnchorPoint[1] = boyfriend.y;
		dadAnchorPoint[0] = boyfriend.x;
		dadAnchorPoint[1] = boyfriend.y;
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 585, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 1;
		timeTxt.visible = !ClientPrefs.hideTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;

		vt_light = new FlxSprite(0, 0).loadGraphic(Paths.image('airship/light_voting', 'impostor'));
		vt_light.updateHitbox();
		vt_light.antialiasing = true;
		vt_light.scrollFactor.set(1, 1);
		vt_light.active = false;
		vt_light.blend = 'add';
		vt_light.alpha = 0.46;

		bars = new FlxSprite(0, 0).loadGraphic(Paths.image('bars')); 
		bars.scrollFactor.set();
		bars.screenCenter();

		if (songName == 'voting-time')
			{
				add(vt_light);
				add(bars);
			}

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		//timeBarBG.color = FlxColor.BLACK;
		timeBarBG.antialiasing = false;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF2e412e, 0xFF44d844);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		timeTxt.x += 10;
		timeTxt.y += 4;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		for (event in eventPushedMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		if(Assets.exists(Paths.txt(SONG.song.toLowerCase().replace(' ', '-') + "/info"))){
			trace('it exists');
			task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'));
			task.cameras = [camHUD];
			add(task);
		}
		
		ass2 = new FlxSprite(0, FlxG.height * 1).loadGraphic(Paths.image('vignette')); 
		ass2.scrollFactor.set();
		ass2.screenCenter();
		
		overlay = new FlxSprite(-1000, -2000).loadGraphic(Paths.image('polus/overlay', 'impostor'));
		overlay.updateHitbox();
		overlay.setGraphicSize(Std.int(overlay.width * 0.4));
		overlay.antialiasing = true;
		overlay.scrollFactor.set(1, 1);
		overlay.active = false;
		overlay.blend = 'add';
		overlay.alpha = 0.5;
		

		if (curSong == 'Reactor')
		{
			add(ass2);
		}

		if (curSong == 'Insane Streamer')
			{
				add(ass2);
			}
	

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		flashSprite.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		ass2.cameras = [camHUD];
		vt_light.cameras = [camHUD];
		bars.cameras = [camHUD];
//		ass3.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'data/' + Paths.formatToSongPath(SONG.song) + '/script.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'sussus-moogus':
					startVideo('polus1');
				
				/*case 'mando':
					startVideo('polus1');

				case 'titular':
					startVideo('polus1');*/

				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		Paths.clearUnusedMemory();

		if(ClientPrefs.charOverride != ''){
			trace(ClientPrefs.charOverride);
		}

		
		//tests = new CCShader(-10,50,0,0,0x00FFFFFF,-0.0039,-0.0039,0xFFFFFFFF,boyfriend);
		//boyfriend.shader = tests.shader;

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		
		#end
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.destroy();
	}


	public function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !cpuControlled
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable) {
							goodNoteHit(coolNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!ClientPrefs.ghostTapping)
						noteMissPress(key, true);
				Conductor.songPosition = previousTime;
			}

			if (playerStrums.members[key] != null 
			&& playerStrums.members[key].animation.curAnim.name != 'confirm')
				playerStrums.members[key].playAnim('pressed');
		}

		if(key == 2){
			if(boyfriend.animation.curAnim.name == 'idle' && boyfriend.curCharacter == 'greenp'){
				boyfriend.playAnim('singUP', true);
				boyfriend.animation.curAnim.curFrame = 5;
				boyfriend.heyTimer = 0.6;
			}
		}
		if(key == 1){
			if(boyfriend.animation.curAnim.name == 'idle' && boyfriend.curCharacter == 'redp'){
				boyfriend.playAnim('hey', true);
				boyfriend.specialAnim = true;
				boyfriend.heyTimer = 0.6;
			}
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			// receptor reset
			if (key >= 0 && playerStrums.members[key] != null)
				playerStrums.members[key].playAnim('static');
		}
	}

	private var keysArray:Array<Dynamic>;

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		if(curStage == 'alpha') {
			healthBar.createFilledBar(FlxColor.RED,
			FlxColor.fromRGB(0, 255, 0));
			healthBar.updateBar();
		}
		else {
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			healthBar.updateBar();
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
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
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = endSong;
			} else {
				doof.finishThing = startCountdown;
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
					if (mom.animation.curAnim != null && !mom.animation.curAnim.name.startsWith('sing') && !mom.stunned)
					{
						mom.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}
				else if(mom.danceIdle && mom.animation.curAnim != null && !mom.stunned && !mom.curCharacter.startsWith('gf') && !mom.animation.curAnim.name.startsWith("sing"))
				{
					mom.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						if(task != null){
							task.start();
						}
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (PlayState.isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						add(ready);
						countDownSprites.push(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(ready);
								remove(ready);
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (PlayState.isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						set.antialiasing = antialias;
						add(set);
						countDownSprites.push(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(set);
								remove(set);
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (PlayState.isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						go.antialiasing = antialias;
						add(go);
						countDownSprites.push(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(go);
								remove(go);
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(dad.curCharacter){
			//red
			case "impostor":
				curPortrait = "red";
			//green
			case "impostor2":
				curPortrait = "red";

			case "impostor3":
				curPortrait = "green";

			case "tomongus":
				curPortrait = "tomongus";

			case "chewmate":
				curPortrait = "hamster";

			case "black":
				curPortrait = "black";

		}

		switch(curSong){
			case "Lights-Down": curPortrait = "greendark";
			case "Defeat": curPortrait = "black";
			case "Mando": curPortrait = "yellow";
			case "Dlow": curPortrait = "yellow";
			case "Oversight": curPortrait = "white";
			case "Double-Kill": curPortrait = "blackairship";
			case "Danger": curPortrait = "blackairship";
			case "Titular": curPortrait = "secret";
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength, curPortrait);
		
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}

					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				} else { //Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[3].toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[2])) {
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad, mom];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad, mom];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);
				
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);
				
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
			
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	public var ratingIndexArray:Array<String> = ["sick", "good", "bad", "shit"];
	public var returnArray:Array<String> = [" [SFC]", " [GFC]", " [FC]", ""];
	public var smallestRating:String;


	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		if(curStage == 'plantroom'){
			cloud1.x = FlxMath.lerp(cloud1.x, cloud1.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));
			cloud2.x = FlxMath.lerp(cloud2.x, cloud2.x - 3, CoolUtil.boundTo(elapsed * 9, 0, 1));
			cloud3.x = FlxMath.lerp(cloud3.x, cloud3.x - 2, CoolUtil.boundTo(elapsed * 9, 0, 1));
			cloud4.x = FlxMath.lerp(cloud4.x, cloud4.x - 0.1, CoolUtil.boundTo(elapsed * 9, 0, 1));
			cloudbig.x = FlxMath.lerp(cloudbig.x, cloudbig.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
		}

		if(curStage == 'toogus'){
			saxguy.x = FlxMath.lerp(saxguy.x, saxguy.x + 15, CoolUtil.boundTo(elapsed * 9, 0, 1));
		}

		if(curStage == "tripletrouble") {
			wiggleEffect.update(elapsed);
			}
		

		

		var legPosY = [13, 7, -3, -1, -1, 2, 7, 9, 7, 2, 0, 0, 3, 1, 3, 7, 13];
		var legPosX = [3, 4, 4, 5, 5, 4, 3, 2, 0, 0, -3, -4, -4, -5, -5, -4, -3];

		if(boyfriend.curCharacter == 'bf-running')
		{
			if(boyfriend.animation.curAnim.name.startsWith("sing")){
				bfLegs.alpha = 1;
				boyfriend.y = bfAnchorPoint[1] + legPosY[bfLegs.animation.curAnim.curFrame];
			}
			else
				bfLegs.alpha = 0;
		}

		if(dad.curCharacter == 'black-run')
			{
				dad.y = dadAnchorPoint[1] + legPosY[dadlegs.animation.curAnim.curFrame];
			}
		
		if(curSong == 'Reactor') {
			if(orb != null) {
				orb.scale.x = FlxMath.lerp(0.7, orb.scale.x, 0.90);
				orb.scale.y = FlxMath.lerp(0.7, orb.scale.y, 0.90);
				orb.alpha = FlxMath.lerp(0.96, orb.alpha, 0.90);
				ass2.alpha = FlxMath.lerp(1, ass2.alpha, 0.90);
			}
		}

		if(curSong == 'Boiling Point') {
			
				overlay.alpha = FlxMath.lerp(0.5, overlay.alpha, 0.40);
			
		}

		if(curStage == "ejected")
		{
			if(!inCutscene)
			camGame.shake(0.002, 0.1);

			if(!tweeningChar && !inCutscene)
			{
				tweeningChar = true;
				FlxTween.tween(boyfriendGroup, {x: FlxG.random.float(bfStartpos.x - 15, bfStartpos.x + 15), y: FlxG.random.float(bfStartpos.y - 15, bfStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut,
					onComplete: function(twn:FlxTween)
					{
						tweeningChar = false;
					}
				});
				FlxTween.tween(gfGroup, {x: FlxG.random.float(gfStartpos.x - 10, gfStartpos.x + 10), y: FlxG.random.float(gfStartpos.y - 10, gfStartpos.y + 10)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
				FlxTween.tween(dadGroup, {x: FlxG.random.float(dadStartpos.x - 15, dadStartpos.x + 15), y: FlxG.random.float(dadStartpos.y - 15, dadStartpos.y + 15)}, 0.4, {
					ease: FlxEase.smoothStepInOut});
			}

			if(boyfriend.platformPos != null){
				plat.setPosition(boyfriend.x + boyfriend.platformPos[0], boyfriend.y + boyfriend.platformPos[1]);
			}
			
		}

		

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'alpha':
				if(timeBar != null) {
					timeBar.visible = false;
				}
				if(timeBarBG != null) {
					timeBarBG.visible = false;
				}
				if(timeTxt != null) {
					timeTxt.visible = false;
				}
			case 'defeat':
				healthBar.visible = false;
				healthBarBG.visible = false;
				health = 1;
				if(songMisses != 0)
				health = 0;
			case 'jerma':
				healthBar.visible = false;
				healthBarBG.visible = false;
				health = 1;
				if(songMisses != 0)
				health = 0;
			case 'airship':
				camGame.shake(0.0008, 0.01);
				camGame.y = Math.sin((Conductor.songPosition / 280)*(Conductor.bpm/60) * 1.0) * 2 - 100;
				camHUD.y = Math.sin((Conductor.songPosition / 300)*(Conductor.bpm/60) * 1.0) * 0.6;
				camHUD.angle = Math.sin((Conductor.songPosition / 350)*(Conductor.bpm/60) * -1.0) * 0.6;
				if(airCloseClouds.members.length > 0 ) {
					for(i in 0...airCloseClouds.members.length) {					
						airCloseClouds.members[i].x = FlxMath.lerp(airCloseClouds.members[i].x, airCloseClouds.members[i].x - 50, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airCloseClouds.members[i].x < -10400.2) {	
							airCloseClouds.members[i].x = 5582.2;
						}
					}
				}
				if(airMidClouds.members.length > 0 ) {
					for(i in 0...airMidClouds.members.length) {					
						airMidClouds.members[i].x = FlxMath.lerp(airMidClouds.members[i].x, airMidClouds.members[i].x - 13, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airMidClouds.members[i].x < -6153.4) {	
							airMidClouds.members[i].x = 2852.4;
						}
					}
				}
				if(airSpeedlines.members.length > 0) {
					for(i in 0...airSpeedlines.members.length) {
						airSpeedlines.members[i].x = FlxMath.lerp(airSpeedlines.members[i].x, airSpeedlines.members[i].x - 350, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airSpeedlines.members[i].x < -5140.05) {	
							airSpeedlines.members[i].x = 3352.1;
						}
					}
				}
				if(airFarClouds.members.length > 0 ) {
					for(i in 0...airFarClouds.members.length) {					
						airFarClouds.members[i].x = FlxMath.lerp(airFarClouds.members[i].x, airFarClouds.members[i].x - 7, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airFarClouds.members[i].x < -6178.95) {	
							airFarClouds.members[i].x = 2874.95;
						}
					}
				}
				if(airshipPlatform.members.length > 0 ) {
					for(i in 0...airshipPlatform.members.length) {					
						airshipPlatform.members[i].x = FlxMath.lerp(airshipPlatform.members[i].x, airshipPlatform.members[i].x - 300, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airshipPlatform.members[i].x < -7184.8) {	
							airshipPlatform.members[i].x = 4275.15;
						}
					}
				}
				if(airBigCloud != null) {
					airBigCloud.x = FlxMath.lerp(airBigCloud.x, airBigCloud.x - bigCloudSpeed, CoolUtil.boundTo(elapsed * 9, 0, 1));
						if(airBigCloud.x < -4163.7) {	
							airBigCloud.x = FlxG.random.float(3931.5, 4824.05);
							airBigCloud.y = FlxG.random.float(-1087.5, -307.35);
							bigCloudSpeed = FlxG.random.float(7, 15);
						}
				}
			case 'ejected':
			camHUD.y = Math.sin((Conductor.songPosition / 1000)*(Conductor.bpm/60) * 1.0) * 15;
			camHUD.angle = Math.sin((Conductor.songPosition / 1200)*(Conductor.bpm/60) * -1.0) * 1.2;
			//make sure that the clouds exist
			if(cloudScroll.members.length == 3) {
				for(i in 0...cloudScroll.members.length) {					
					cloudScroll.members[i].y = FlxMath.lerp(cloudScroll.members[i].y, cloudScroll.members[i].y - speedPass[i], CoolUtil.boundTo(elapsed * 9, 0, 1));
					if(cloudScroll.members[i].y < -1789.65) {
						//im not using flxbackdrops so this is how we're doing things today
						var randomScale = FlxG.random.float(1.5, 2.2);
						var randomScroll = FlxG.random.float(1, 1.3);

						speedPass[i] = FlxG.random.float(1100, 1300);

						cloudScroll.members[i].scale.set(randomScale, randomScale);
						cloudScroll.members[i].scrollFactor.set(randomScroll, randomScroll);
						cloudScroll.members[i].x = FlxG.random.float(-3578.95, 3259.6);
						cloudScroll.members[i].y = 2196.15;
					}
				}
			}
			if(farClouds.members.length == 7) {
				for(i in 0...farClouds.members.length) {					
					farClouds.members[i].y = FlxMath.lerp(farClouds.members[i].y, farClouds.members[i].y - farSpeedPass[i], CoolUtil.boundTo(elapsed * 9, 0, 1));
					if(farClouds.members[i].y < -1614) {
						var randomScale = FlxG.random.float(0.2, 0.5);
						var randomScroll = FlxG.random.float(0.2, 0.4);

						farSpeedPass[i] = FlxG.random.float(1100, 1300);

						farClouds.members[i].scale.set(randomScale, randomScale);
						farClouds.members[i].scrollFactor.set(randomScroll, randomScroll);
						farClouds.members[i].x = FlxG.random.float(-2737.85, 3485.4);
						farClouds.members[i].y = 1738.6;
					}
				}
			}
			//AAAAAAAAAAAAAAAAAAAA			
			if(leftBuildings.length > 0) {
				for(i in 0...leftBuildings.length) {
					leftBuildings[i].y = middleBuildings[i].y + 5888;
				}
			}
			if(middleBuildings.length > 0) {
				for(i in 0...middleBuildings.length) {
					if(middleBuildings[i].y < -11759.9) {
						middleBuildings[i].y = 3190.5;
						middleBuildings[i].animation.play(FlxG.random.bool(50) ? '1' : '2');
					}			
					middleBuildings[i].y = FlxMath.lerp(middleBuildings[i].y, middleBuildings[i].y - 1300, CoolUtil.boundTo(elapsed * 9, 0, 1));
				}
			}
			if(rightBuildings.length > 0) {
				for(i in 0...rightBuildings.length) {
					rightBuildings[i].y = leftBuildings[i].y;
				}
			}
			speedLines.y = FlxMath.lerp(speedLines.y, speedLines.y - 1350, CoolUtil.boundTo(elapsed * 9, 0, 1));

			if(fgCloud != null) {
				fgCloud.y = FlxMath.lerp(fgCloud.y, fgCloud.y - 0.01, CoolUtil.boundTo(elapsed * 9, 0, 1));
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			if(!cameraLocked)
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(cpuControlled)
			scoreTxt.text = 'Score: ? | Combo Breaks: ? | Accuracy: ?';
		else {
			scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ';
				if (ratingString != '?')
					scoreTxt.text += '' + ((Math.floor(ratingPercent * 10000) / 100)) + '%';
				if (songMisses <= 0)
					scoreTxt.text += ratingString;
		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {

				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				PauseSubState.transCamera = camOther;
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;
					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
					timeTxt.text = '' + curSong.toUpperCase();
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming && !cameraLocked)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		var downscrollMultiplier = (ClientPrefs.downScroll ? -1 : 1);
		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if(daNote.copyX) 
					daNote.x = strumX;
				if(daNote.copyAngle) 
					daNote.angle = strumAngle;
				if(daNote.copyAlpha) 
					daNote.alpha = strumAlpha;
				
				if(daNote.copyY) {
					var receptors:FlxTypedGroup<StrumNote> = (daNote.mustPress ? playerStrums : opponentStrums);
					var receptorPosY:Float = receptors.members[Math.floor(daNote.noteData)].y;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					daNote.y = receptorPosY + psuedoY + daNote.offsetY;
					daNote.x = receptors.members[Math.floor(daNote.noteData)].x + daNote.offsetX;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote)
					{
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (downscrollMultiplier < 0)
							{
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
								else
									daNote.y += daNote.endHoldOffset;
							}
							else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}

						if (downscrollMultiplier < 0)
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							daNote.flipY = false;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}

						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if(daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else if(!daNote.noAnimation) {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
								altAnim = '-alt';
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if(daNote.noteType == 'GF Sing') {
							gf.playAnim(animToPlay + altAnim, true);
							gf.holdTimer = 0;
						} else if(daNote.noteType == 'Opponent 2 Sing' || opponent2sing == true) {
							mom.playAnim(animToPlay + altAnim, true);
							mom.holdTimer = 0;
						} else if(daNote.noteType == 'Both Opponents Sing' || bothOpponentsSing == true) {
							mom.playAnim(animToPlay + altAnim, true);
							mom.holdTimer = 0;
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
						}else {
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
						}

						if(daNote.noteType == 'fabs') {
						//	gf.playAnim(animToPlay + altAnim, true);
						//	gf.holdTimer = 0;
						} else {
						//	dad.playAnim(animToPlay + altAnim, true);
						//	dad.holdTimer = 0;
						}
						if(daNote.noteType == 'orb') {
							//	gf.playAnim(animToPlay + altAnim, true);
							//	gf.holdTimer = 0;
							} else {
							//	dad.playAnim(animToPlay + altAnim, true);
							//	dad.holdTimer = 0;
							}
						
						if(daNote.noteType == 'rare') {
							//	gf.playAnim(animToPlay + altAnim, true);
							//	gf.holdTimer = 0;
							} else {
							//	dad.playAnim(animToPlay + altAnim, true);
							//	dad.holdTimer = 0;
							}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);

					if (!daNote.isSustainNote)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
				}

				if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Conductor.safeZoneOffset) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress))
						{
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;

								if (!daNote.ignoreNote)
									noteMissPress(daNote.noteData);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											if (!daNote.ignoreNote)
												noteMissPress(daNote.noteData);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if ((((downscrollMultiplier > 0) && (daNote.y < -daNote.height))
					|| ((downscrollMultiplier < 0) && (daNote.y > (FlxG.height + daNote.height)))
					|| (daNote.isSustainNote && daNote.strumTime - Conductor.songPosition < -350))
					&& (daNote.tooLate || daNote.wasGoodHit))
				{
					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});

			var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT;
			var holdControls:Array<Bool> = [left, down, up, right];

			if (holdControls.contains(true) && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
						&& daNote.isSustainNote
						&& daNote.canBeHit
						&& daNote.mustPress
						&& holdControls[daNote.noteData]
						&& !daNote.tooLate)
						goodNoteHit(daNote);
				});
			}

			if ((boyfriend != null && boyfriend.animation != null)
				&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || cpuControlled)))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
		}
		checkEventNote();

		//tests.update();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		if(!cameraLocked){
			setOnLuas('cameraX', camFollowPos.x);
			setOnLuas('cameraY', camFollowPos.y);
		}
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	var isDead:Bool = false;
	function doDeathCheck() {
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y, this));
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
				
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {	
			case 'Lights out':
				if(charShader == null){
					charShader = new BWShader(0.01, 0.12, true);
				}
				if(boyfriend.curCharacter == 'bf'){
					triggerEventNote('Change Character', '0', 'whitebf');
				}else{
					boyfriend.shader = charShader.shader;
				}
				if(dad.curCharacter == 'impostor3'){
					triggerEventNote('Change Character', '1', 'whitegreen');
				}else{
					dad.shader = charShader.shader;
				}
				iconP1.shader = charShader.shader;
				iconP2.shader = charShader.shader;
				loBlack.alpha = 1;

				healthBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
				healthBar.updateBar();
			case 'Lights on':
				if(boyfriend.curCharacter == 'whitebf'){
					triggerEventNote('Change Character', '0', 'bf');
				}else{
					boyfriend.shader = null;
				}
				if(dad.curCharacter == 'whitegreen'){
					triggerEventNote('Change Character', '1', 'impostor3');
				}else{
					dad.shader = null;
				}
				iconP1.shader = null;
				iconP2.shader = null;
				loBlack.alpha = 0;

				healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
				healthBar.updateBar();
			case 'Who Buzz':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;
				switch(charType) {
					case 0:
						camHUD.visible = false;
						meeting.visible = true;
						meeting.animation.play('bop');
					case 1:
						meeting.visible = false;
						dad.visible = false;
						space.visible = true;
						starsBG.visible = true;
						starsFG.visible = true;
						boyfriend.screenCenter(Y);
						boyfriend.x = -1000;
						FlxTween.angle(boyfriend, 0, 720, 10);
						FlxTween.tween(boyfriend, {x: 3000}, 10);
						//cameraLocked = false;
						defaultCamZoom = 0.5;
						FlxG.camera.zoom = 0.5;
						camFollowPos.setPosition(1100, 1150);
						FlxG.camera.focusOn(camFollowPos.getPosition());

						var whoArray:Array<String> = ["G", "o", "i", "n", "g", "2", "k", "i", "l", "l", "e", "v", "e", "r", "y", "1", "s", "t", "a", "r", "t", "i", "n", "g", "w", "i", "t", "h", "U", " ", "w", "a", "s", " ", "n", "o", "t", " ", "T", "h", "e", " ", "I", "m", "p", "o", "s", "t", "o", "r", "."];

						var ejectText:FlxText;
						ejectText = new FlxText();
						ejectText.setFormat(Paths.font("arial.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						ejectText.scrollFactor.set();
						ejectText.alpha = 0;
						ejectText.borderSize = 1;
						ejectText.text = '';
						ejectText.screenCenter();
						add(ejectText);

						for (i in 0...whoArray.length){
							var addChar:String = whoArray[i];
							ejectText.text = ejectText.text + addChar;
							new FlxTimer().start(0.1);
						}
				}	
			case 'Cam lock in Who':
				if(value1 == 'in'){
					defaultCamZoom = 1.2;
					camGame.camera.zoom = 1.2;
					cameraLocked = true;
					if(value2 == 'dad') {
						camFollowPos.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y + 100);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
					else {
						camFollowPos.setPosition(boyfriend.getMidpoint().x - 50, boyfriend.getMidpoint().y + 50);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
				}
				else {
					cameraLocked = false;
					defaultCamZoom = 0.7;
					FlxG.camera.zoom = 0.7;
					camFollowPos.setPosition(1100, 1150);
					FlxG.camera.focusOn(camFollowPos.getPosition());
				}

			case 'Cam lock in Voting Time':
				if(value1 == 'in'){
					defaultCamZoom = 1.2;
					camGame.camera.zoom = 1.2;
					cameraLocked = true;
					if(value2 == 'dad') {
						camFollowPos.setPosition(460, 700);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
					else {
						camFollowPos.setPosition(1470, 700);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
				}
				else if(value1 == 'close'){
					defaultCamZoom = 1.25;
					camGame.camera.zoom = 1.25;
					cameraLocked = true;
					if(value2 == 'dad') {
						camFollowPos.setPosition(480, 680);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
					else {
						camFollowPos.setPosition(1450, 680);
						FlxG.camera.focusOn(camFollowPos.getPosition());
					}
				}
				else {
					cameraLocked = true;
					defaultCamZoom = 0.7;
					FlxG.camera.zoom = 0.7;
					camFollowPos.setPosition(960, 540);
					FlxG.camera.focusOn(camFollowPos.getPosition());
				}

			case 'Both Opponents':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;
				switch(charType) {
					case 0:
						bothOpponentsSing = false;
					case 1:
						bothOpponentsSing = true;
				}

			case 'Opponent Two':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;
				switch(charType) {
					case 0:
						opponent2sing = false;
					case 1:
						opponent2sing = true;
				}

			case 'Ellie Drop':
				add(momGroup);
				mom.playAnim('enter', false);
				mom.specialAnim = true;
				iconP2.changeIcon('ellie');
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;
			
			case 'Toogus Sax':
				saxguy.setPosition(-550, 275);
				add(saxguy);

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad, mom];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad, mom];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						mom.color = color;
						boyfriend.color = color;
						gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad, mom];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}
				
			case 'DefeatDark':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(charType) {
					case 0:
						defeatblack.alpha = 0;
					case 1:
						defeatblack.alpha += 1;
				}

			case 'flash':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(charType) {
					case 0:
						camGame.flash(FlxColor.WHITE, 0.35);
					case 1:
						camGame.flash(FlxColor.WHITE, 0.35);
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if(!boyfriend.alreadyLoaded) {
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							if(!dad.alreadyLoaded) {
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if(!gf.alreadyLoaded) {
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool) {
		if(isDad) {
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		} else {
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1) {
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween) {
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!usedPractice) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelFadeTween();
							//resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelFadeTween();
						//resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new AmongFreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}
	

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition); 
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var healthMultiplier:Float = 1;

		ratingString = '';
		var daRating:String = "sick";
		if (noteDiff > 45)
		{
			daRating = 'good';
			score = 275;
			healthMultiplier = 0.5;
		} 
		if (noteDiff > 90)
		{
			daRating = 'bad';
			score = 200;
			healthMultiplier = 0.25;
		}
		if (noteDiff > 135)
		{
			daRating = 'shit';
			score = -50;
			healthMultiplier = -1;
			songMisses++;
			combo = 0;
		}

		health += note.hitHealth * healthMultiplier;
		if(daRating == 'sick' && !note.noteSplashDisabled)
			spawnNoteSplashOnNote(note);

		if (songMisses <= 0)
			{
				if (ratingIndexArray.indexOf(daRating) > ratingIndexArray.indexOf(smallestRating))
					smallestRating = daRating;
				ratingString = returnArray[ratingIndexArray.indexOf(smallestRating)];
			}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			songHits++;
			RecalculateRating();
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			if(curStage != 'alpha') {
				scoreTxt.scale.x = 1.1;
				scoreTxt.scale.y = 1.1;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});				
			}
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage) {
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = gf.x - 40;
		rating.y = gf.y - 60;
		rating.acceleration.y = 550;
		if (curStage == 'ejected')
			rating.acceleration.y = -550;
		if(curStage == 'airship') {
			rating.velocity.x = -250;
			rating.acceleration.x = -550;
		}
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		if (curStage == 'ejected')
			rating.acceleration.y = -600;
		if(curStage == 'airship') {
			comboSpr.velocity.x = -250;
			comboSpr.acceleration.x = -550;
		}
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = gf.x + (43 * daLoop) - 90;
			numScore.y = gf.y + 70;

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}


	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth; //For testing purposes
		combo = 0;
		trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		RecalculateRating();

		var animToPlay:String = '';
		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				animToPlay = 'singLEFTmiss';
			case 1:
				animToPlay = 'singDOWNmiss';
			case 2:
				animToPlay = 'singUPmiss';
			case 3:
				animToPlay = 'singRIGHTmiss';
		}

		if(daNote.noteType == 'GF Sing') {
			gf.playAnim(animToPlay, true);
		} else {
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			boyfriend.playAnim(animToPlay + daAlt, true);
		}

		if(daNote.noteType == 'fabs') {
			//gf.playAnim(animToPlay, true);
		} else {
		//	var daAlt = '';
		//	if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

		//	boyfriend.playAnim(animToPlay + daAlt, true);
		}

		if(daNote.noteType == 'orb') {
			//gf.playAnim(animToPlay, true);
		} else {
		//	var daAlt = '';
		//	if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

		//	boyfriend.playAnim(animToPlay + daAlt, true);
		}

		if(daNote.noteType == 'rare') {
			//gf.playAnim(animToPlay, true);
		} else {
		//	var daAlt = '';
		//	if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

		//	boyfriend.playAnim(animToPlay + daAlt, true);
		}
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void 
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad')) 
				gf.playAnim('sad');
	
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) 
				songMisses++;
	
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			vocals.volume = 0;
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			} else {
				if (note.parentNote != null)
					health += note.hitHealth / note.parentNote.childrenNotes.length;
			}

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
					case 1:
						animToPlay = 'singDOWN';
					case 2:
						animToPlay = 'singUP';
					case 3:
						animToPlay = 'singRIGHT';
				}

				if(note.noteType == 'GF Sing') {
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
				} else {
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'fabs') {
				//	gf.playAnim(animToPlay + daAlt, true);
				//	gf.holdTimer = 0;
				} else {
				//	boyfriend.playAnim(animToPlay + daAlt, true);
				//	boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'orb') {
					//	gf.playAnim(animToPlay + daAlt, true);
					//	gf.holdTimer = 0;
					} else {
					//	boyfriend.playAnim(animToPlay + daAlt, true);
					//	boyfriend.holdTimer = 0;
					}

				if(note.noteType == 'rare') {
					//	gf.playAnim(animToPlay + daAlt, true);
					//	gf.holdTimer = 0;
					} else {
					//	boyfriend.playAnim(animToPlay + daAlt, true);
					//	boyfriend.holdTimer = 0;
					}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	function bgFlash():Void
		{
			//oops im stupid so commented out the tweening version
			//flashSprite.alpha = 0;
			//FlxTween.tween(flashSprite.alpha, 0.4, 0.15);
			trace('BG FLASH FUNNY');
			//yeaaah nice try buckaroo cant FLASH WHILE IN A CUTSCENE!! BITCH!!!!!!!!
			// if(!inCutscene)
				// flashSprite.alpha = 0.4;
		}

	private var preventLuaRemove:Bool = false;


	public function cancelFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		flashSprite.alpha -= 0.08;

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0 && !cameraLocked)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		

		{
			var sussusBeats = [94, 95, 288, 296, 304, 312, 318, 319];
			var saboBeats = [16, 24, 32, 40, 48, 56, 62, 63, 272, 280, 288, 296, 302, 303, 376, 384, 892];
			var meltBeats = [0, 16, 32, 48, 64, 72, 80, 88, 96, 104, 112, 120, 126, 127, 200, 208, 216, 224, 232, 240, 248, 256, 272, 288, 304, 320, 336, 352, 368, 382, 464, 480, 496, 512];
			var toogusBeats = [94, 95, 96, 98, 100, 102, 104, 106, 107, 109, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 156, 158, 192, 194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 218, 220, 222, 288, 296, 304, 312, 318, 319, 320, 322, 324, 326, 328, 330, 332, 334, 336, 338, 340, 342, 344, 346, 348, 350, 352, 354, 356, 358, 360, 362, 364, 366, 368, 370, 372, 374, 376, 378, 380, 382];
			var reactorBeats = [1, 16, 32, 48, 64, 72, 80, 88, 96, 104, 112, 120, 126, 127, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176, 180, 184, 188, 448, 456, 464, 472, 476, 478, 480, 484, 488, 492, 496, 500, 504, 508, 512, 516, 520, 524, 528, 532, 536, 540, 544, 548, 552, 556, 560, 564, 568, 572, 576, 580, 584, 588, 592, 596, 600, 604];
			var _b = 0;
			//FlxG.watch.addQuick("Flash Timer", _cb); debug stuff
	
			add(flashSprite);
			flashSprite.alpha = 0;
			flashSprite.scrollFactor.set(0, 0);
	
			if(curSong == 'Sussus-Moogus') // sussus flashes
			{
				
				if(curBeat == 97 || curBeat == 192 || curBeat == 320)
					_cb = 1;
					if(curBeat > 98 && curBeat < 160 || curBeat > 192 && curBeat < 224 || curBeat > 320 && curBeat < 382 || curBeat == 98 || curBeat == 160 || curBeat == 192 || curBeat == 224 || curBeat == 320 || curBeat == 382)
					{
						_cb++;
						if(_cb == 2)
						{
							bgFlash();
							_cb = 0;
						}
					}
				while(_b < sussusBeats.length) {
				var susflash = sussusBeats[_b];
					++_b;
					if(curBeat == susflash)
					{
						bgFlash();
					}
				}
			}
			if(curSong == 'Sabotage') // sabotage flashes
			{
				while(_b < saboBeats.length) {
					var sabflash = saboBeats[_b];
						++_b;
						if(curBeat == sabflash)
						{
							bgFlash();
						}
					}
	
					if(curBeat == 63 || curBeat == 304)
						_cb = 3;
					if(curBeat > 64 && curBeat < 124 || curBeat > 304 && curBeat < 370 || curBeat == 64 || curBeat == 124 || curBeat == 304 || curBeat == 370)
					{
						_cb++;
						if(_cb == 4)
						{
							bgFlash();
							_cb = 0;
						}
					}
			}
			if(curSong == 'Meltdown') // meltdown flashes
			{
				while(_b < meltBeats.length) {
					var meltflash = meltBeats[_b];
					++_b;
					if(curBeat == meltflash)
					{
						bgFlash();
					}
				}
				if(curBeat == 127)
					_cb = 3;
				if(curBeat == 382)
					_cb = 1;
				if(curBeat > 128 && curBeat < 192 || curBeat > 382 && curBeat < 448 || curBeat == 128 || curBeat == 192 || curBeat == 382 || curBeat == 448)
				{
					_cb++;
					if(_cb == 4)
					{
						bgFlash();
						_cb = 0;
					}
				}
			}
			if(curSong == 'Sussus-Toogus') // toogus flashes
			{
				while(_b < toogusBeats.length) {
					var meltflash = toogusBeats[_b];
					++_b;
					if(curBeat == meltflash)
					{
						bgFlash();
					}
				}
			}
		
			if(curSong == 'Reactor') // reactor flashes
			{
				while(_b < reactorBeats.length) {
					var meltflash = reactorBeats[_b];
					++_b;
					if(curBeat == meltflash)
					{
						bgFlash();
					}
				}
			}
		}
		

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 1 == 0) {
			if(boyfriend.curCharacter == 'bf-running')
				bfLegs.dance();
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.curCharacter == 'bf-running')
			{
				boyfriend.dance();
			}
		}

		if(curBeat % 1 == 0) {
			if(dad.curCharacter == 'black-run')
				dadlegs.dance();
		}

		

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.curCharacter != 'bf-running')
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
			if (mom.animation.curAnim.name != null && !mom.animation.curAnim.name.startsWith("sing") && !mom.stunned)
			{
				mom.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		} else if(mom.danceIdle && mom.animation.curAnim.name != null && !mom.curCharacter.startsWith('gf') && !mom.animation.curAnim.name.startsWith("sing") && !mom.stunned) {
			mom.dance();
		}
		
		
				//drop 1
		if (curBeat == 128 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 191 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.5;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 100);
    }
	//drop 2
		if (curBeat == 319 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 383 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.5;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y - 100);
    }
	//FUCKING EPIC DROP NIGGA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//clowfoe wrote this btw im not racist
		if (curBeat == 480 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.9;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		if (curBeat == 607 && curSong == 'Reactor')
    {
			defaultCamZoom = 0.7;
			camFollowPos.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y + 100);
    }

		switch (curStage)
		{	
			case 'polus':
				if(curBeat % 1 == 0) {
					speaker.animation.play('bop');
				}
				if(curBeat % 2 == 0) {
					crowd2.animation.play('bop');
				}
			case 'polus2':
				if(curBeat % 2 == 0) {
					crowd.animation.play('bop');
				}
			case 'chef':
				if(curBeat % 2 == 0) {
					gray.animation.play('bop');
					saster.animation.play('bop');
					neato.animation.play('bop');
				}
			case 'reactor':
				if(curBeat % 4 == 0) {
					orb.scale.set(0.75, 0.75);
					ass2.alpha = 0.9;
					orb.alpha = 1;
					amogus.animation.play('bop', true);
					dripster.animation.play('bop', true);
					yellow.animation.play('bop', true);
					brown.animation.play('bop', true);
				}

			case 'polus3':
				if(curBeat % 4 == 0) {

					overlay.alpha = 0.4;
				
				}
				
					
			case 'loggo':
				if(curBeat % 2 == 0) {
					peopleloggo.animation.play('bop', true);
				}
			case 'toogus':
				if(curBeat % 2 == 0) {
					if(SONG.song.toLowerCase() == 'lights-down') {
						toogusblue.animation.play('bop', true);
						toogusorange.animation.play('bop', true);
						tooguswhite.animation.play('bop', true);
					}
				}
			
			case 'defeat':
				if(curBeat % 4 == 0) {
					defeatthing.animation.play('bop', true);
				}
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}
	

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses) * 350);
			if (!Math.isNaN(ratingPercent) && ratingPercent < 0)
				ratingPercent = 0;

			if (Math.isNaN(ratingPercent))
				ratingString = '?';
			else if (ratingPercent >= 1)
				ratingPercent = 1;

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			if(!Achievements.achievementsUnlocked[arrayIDs[i]][1]) {
				switch(arrayIDs[i]) {
					case 1 | 2 | 3 | 4 | 5 | 6 | 7:
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' &&
						storyPlaylist.length <= 1 && WeekData.getWeekFileName() == ('week' + arrayIDs[i]) && !changedDifficulty && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 8:
						if(ratingPercent < 0.2 && !practiceMode && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 9:
						if(ratingPercent >= 1 && !usedPractice && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 10:
						if(Achievements.henchmenDeath >= 100) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 11:
						if(boyfriend.holdTimer >= 20 && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 12:
						if(!boyfriendIdled && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 14:
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 15:
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
