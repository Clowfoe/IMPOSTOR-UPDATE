package;

import haxe.zip.Compress;
import FreeplayState.SongMetadata;
import flixel.input.mouse.FlxMouseEventManager;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import flixel.addons.display.FlxBackdrop;

using StringTools;

typedef FreeplayWeek = 
{
	// JSON variables
	var songs:Array<Dynamic>;
	var freeplayColor:Array<Int>;
	var weekName:String;
    var section:Int;
}

class AmongFreeplayState extends MusicBeatState {

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
    private static var curDifficulty:Int = 2;

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

    
    //someones dying for this
    //and its me!
    public static var weeks:Array<FreeplayWeek> = [];

    var listOfButtons:Array<FreeplayCard> = [];

    override function create() {        
        FlxG.mouse.visible = true;

        //i dont care
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

        //END IT
        portrait.animation.addByPrefix('impostor', 'Red', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('crewmate', 'Green', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('parasite', 'Parasite', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('white', 'White', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('maroon', 'Maroon', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('tomongus', 'Tomo', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('hamster', 'Ham', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('pink', 'Pink', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('placeholder', 'Chef', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('gray', 'Grey', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('henry', 'Henry', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('yellow', 'Yellow', 24, true);
        portraitArray++;
        portrait.animation.addByPrefix('black', 'Defeat', 24, true);
        portraitArray++;

        for(i in 0...portraitArray) {
            switch(i) {
                case 0:
                    portraitOffset.push([304.65, -100]);
                default:
                    portraitOffset.push([304.65, -100]);
            }
        }

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

        weeks = [];        
        listOfButtons = [];

        addWeeks();

        for(i in 0...weeks.length) {
            //lolLOLLING IM LOLLING
            var prevI:Int = i;
            for(i in 0...weeks[i].songs.length) {
                if(weeks[prevI].section == curWeek) {
                    listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3]));
                }
            }
        }

        trace('created Weeks');

        trace('pushed list of buttons with ' + listOfButtons.length + ' buttons');

        for(i in listOfButtons) {
            add(i);
            add(i.spriteOne);
            add(i.icon);
            add(i.songText);            
        }

        for(i in 0...listOfButtons.length) {
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
        FlxMouseEventManager.add(crossImage, function onMouseDown(s:FlxSprite){goBack();}, null, null);

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

        super.create();        
    }

    override function update(elapsed:Float) {
        starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
        starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

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

        infoText.text = lerpScore + '\n' + Math.floor(lerpRating * 100) + '\n';

        if(upScroll) {
            changeSelection(-1);
        }
        if(downScroll) {
            changeSelection(1);
        }
        if(rightP) {
            changeWeek(1);
            FlxG.sound.play(Paths.sound('panelAppear', 'impostor'), 0.5);
        }
        if(leftP) {
            changeWeek(-1);
            FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.5);
        }        
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
        if (accepted)
		{
			var songLowercase:String = Paths.formatToSongPath(listOfButtons[curSelected].songName.toLowerCase());
            trace(listOfButtons[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, 1);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;

			PlayState.storyWeek = curWeek;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			LoadingState.loadAndSwitchState(new PlayState());
		}

        infoText.x = FlxG.width - infoText.width - 6;

        super.update(elapsed);
    }

    function changeSelection(change:Int) {
        prevSel = curSelected;
        curSelected += change;
        if(curSelected < 0) {
            curSelected = 0;
        }
        else if(curSelected > listOfButtons.length - 1) {
            curSelected = listOfButtons.length - 1;
        }
        else {
            FlxG.sound.play(Paths.sound('hover', 'impostor'), 0.5);
        }


        intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 1);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 1);

        var bullShit:Int = 0;

        if(listOfButtons.length > 0) {
            for (i in 0...listOfButtons.length)
            {
                listOfButtons[i].targetY = bullShit - curSelected;
    
                bullShit++;
            }
        }

        changePortrait();
    }

    function Hover() {

    }

    function UnHover() {

    }

    public static function goBack() {
        MusicBeatState.switchState(new MainMenuState());
        FlxG.sound.play(Paths.sound('select', 'impostor'), 0.5);
    }

    function addWeeks() {

        weeks = [];
        //im just like putting this in its own function because
        //jesus christ man this cant get near the coherent code
        weeks.push
        ({
            songs: [["Sussus Moogus", "impostor", 'red', FlxColor.RED], ["Sabotage", "impostor", 'red', FlxColor.RED], ["Meltdown", "impostor", 'red', FlxColor.RED]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 1',
            section: 0
        });

        weeks.push
        ({
            songs: [["Sussus Toogus", "crewmate", 'green', FlxColor.fromRGB(0, 255, 0)], ["Lights Down", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0)], ["Reactor", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0)], ["Ejected", "parasite", 'green', FlxColor.fromRGB(0, 255, 0)], ["Double Trouble", 'dt', 'green', FlxColor.fromRGB(0, 255, 0)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 2',
            section: 0
        });

        weeks.push
        ({
            songs: [["Sussy Bussy", "tomongus",'tomo', FlxColor.fromRGB(255, 90, 134)], ["Rivals", "tomongus",'tomo', FlxColor.fromRGB(255, 90, 134)], ["Chewmate", "hamster",'ham', FlxColor.fromRGB(255, 90, 134)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 3',
            section: 0
        });

        weeks.push
        ({
            songs: [["Mando", "yellow",'yellow', FlxColor.fromRGB(255, 218, 67)], ["Dlow", "yellow",'yellow', FlxColor.fromRGB(255, 218, 67)], ["Oversight", "white",'white', FlxColor.WHITE], ["Danger", "black",'black', FlxColor.fromRGB(179, 0, 255)], ["Double Kill", "whiteblack",'black', FlxColor.fromRGB(179, 0, 255)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 4',
            section: 0
        });

        weeks.push
        ({
            songs: [["Defeat", "black", 'black', FlxColor.fromRGB(179, 0, 255)], ["Ominous", "black", 'black', FlxColor.fromRGB(179, 0, 255)], ["Finale", "black", 'black', FlxColor.fromRGB(179, 0, 255)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 5',
            section: 0
        });

        weeks.push
        ({
            songs: [["Ashes", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0)],["Magmatic", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0)],["Boiling Point", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 1',
            section: 1
        });

        weeks.push
        ({
            songs: [["Insane", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)], ["Blackout", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)], ["Delusion", "gray", 'grey', FlxColor.fromRGB(139, 157, 168)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 2',
            section: 1
        });

        
        weeks.push
        ({
            songs: [["Pinkwave", "pink", 'pink', FlxColor.fromRGB(255, 0, 222)], ["Heartbeat", "pink", 'pink', FlxColor.fromRGB(255, 0, 222)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 3',
            section: 1
        });

        weeks.push
        ({
            songs: [["Order Up", "placeholder", 'chef', FlxColor.fromRGB(255, 0, 222)]], 
            freeplayColor: [146, 113, 253],
            weekName: 'Week 4',
            section: 1
        });

        weeks.push
        ({
            songs: [["Alpha Moogus", "oldpostor", 'oldpostor', FlxColor.RED], ["Actin Sus", "oldpostor", 'oldpostor', FlxColor.RED]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 1',
            section: 2
        });

        weeks.push
        ({
            songs: [["Titular", "henry", 'henry', FlxColor.fromRGB(84, 167, 202)], ["Armed", "henry", 'henry', FlxColor.fromRGB(84, 167, 202)], ["Who", "placeholder", 'red', FlxColor.fromRGB(84, 167, 202)], ["Drippypop", "placeholder", 'red', FlxColor.fromRGB(84, 167, 202)], ["Monochrome", "placeholder", 'red', FlxColor.fromRGB(84, 167, 202)], ["Compromised Persona", "placeholder", 'red', FlxColor.fromRGB(84, 167, 202)]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 1',
            section: 3
        });

        weeks.push
        ({
            songs: [["Skinny Nuts", "henry", 'red', FlxColor.ORANGE],["Skinny Nuts 2", "henry", 'red', FlxColor.ORANGE]],
            freeplayColor: [146, 113, 253],
            weekName: 'Week 1',
            section: 4
        });
    }


    function changeWeek(change:Int) {

        prevWeek = curWeek;

        curWeek += change;

        if(curWeek > 4) {
            curWeek = 0;
        }
        if(curWeek < 0) {
            curWeek = 4;
        }  


        
        trace(curWeek + ' ' + weeks.length);

        trace('created Weeks');

        for (i in 0...listOfButtons.length) {
            listOfButtons[i].destroy();
            listOfButtons[i].spriteOne.destroy();
            listOfButtons[i].icon.destroy();
            listOfButtons[i].songText.destroy();
        }

        listOfButtons = [];

        for(i in 0...weeks.length) {
            //lolLOLLING IM LOLLING
            var prevI:Int = i;
            for(i in 0...weeks[i].songs.length) {
                if(weeks[prevI].section == curWeek) {
                    listOfButtons.push(new FreeplayCard(0, 0, weeks[prevI].songs[i][0], weeks[prevI].songs[i][1], weeks[prevI].songs[i][3]));
                }
            }
        }

        for(i in listOfButtons) {
            add(i);
            add(i.spriteOne);
            add(i.icon);
            add(i.songText);  
            trace('added button ' + i);          
        }

        for(i in 0...listOfButtons.length) {
            listOfButtons[i].targetY = i;
            listOfButtons[i].spriteOne.alpha = 0;
            listOfButtons[i].songText.alpha = 0;
            listOfButtons[i].icon.alpha = 0;
            listOfButtons[i].spriteOne.setPosition((Math.abs(listOfButtons[i].targetY * 70) * -1) - 270, (FlxMath.remapToRange(listOfButtons[i].targetY, 0, 1, 0, 1.3) * 90) + (FlxG.height * 0.45));
        }               

        curSelected = 0;

        intendedScore = Highscore.getScore(listOfButtons[curSelected].songName.toLowerCase(), 1);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName.toLowerCase(), 1);

        changePortrait(true);


    }

    function changePortrait(?reset:Bool = false) {
        prevPort = portrait.animation.name;
        switch(listOfButtons[curSelected].iconName) {
            case 'impostor3':
                portrait.animation.play('crewmate');  
            default:
                portrait.animation.play(listOfButtons[curSelected].iconName);  
        }
        portrait.animation.play(listOfButtons[curSelected].iconName);    
        if(!reset) {
            if(prevSel != curSelected) {
                if(prevPort != portrait.animation.name) {
                    if(portraitTween != null) {
                        portraitTween.cancel();
                    }
                    if(portraitAlphaTween != null) {
                        portraitAlphaTween.cancel();
                    }
                    if(colorTween != null) {
                        colorTween.cancel();
                    }
                    portrait.x = 504.65;
                    portrait.alpha = 0;
                    var prevColor:FlxColor = porGlow.color;
                    colorTween = FlxTween.color(porGlow, 0.2, porGlow.color, listOfButtons[curSelected].coloring);
                    portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
                    portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
                }
            }
        }
        else {
            if(portraitTween != null) {
                portraitTween.cancel();
            }
            if(portraitAlphaTween != null) {
                portraitAlphaTween.cancel();
            }
            if(colorTween != null) {
                colorTween.cancel();
            }
            portrait.x = 504.65;
            portrait.alpha = 0;
            var prevColor:FlxColor = porGlow.color;
            colorTween = FlxTween.color(porGlow, 0.2, porGlow.color, listOfButtons[curSelected].coloring);
            portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
            portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        }
    }
}