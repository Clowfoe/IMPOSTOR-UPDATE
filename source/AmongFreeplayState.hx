package;

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
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class AmongFreeplayState extends MusicBeatState {

    var space:FlxSprite;
    var starsBG:FlxBackdrop;
    var starsFG:FlxBackdrop;
    var upperBar:FlxSprite;
    var upperBarOverlay:FlxSprite;
    var portrait:FlxSprite;
    var porGlow:FlxSprite;    
    private static var curSelected:Int = 0;
    var listOfButtons:Array<FreeplayCard> = [
        new FreeplayCard(40.8, 352.25, 'Danger', 'black'),
        new FreeplayCard(2.2, 233.1, "D'Low", 'yellow'),
        new FreeplayCard(2.2, 467.7, 'Reactor', 'impostor3'),
        new FreeplayCard(-49.25, 120.15, 'Boiling Point', 'maroon'),
        new FreeplayCard(-49.25, 578.15, 'Skinny Nuts', 'skinnynuts'),
        new FreeplayCard(-129.25, 690, 'Defeat', 'black')
    ];

    override function create() {        
        FlxG.mouse.visible = true;

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
        portrait.animation.addByPrefix('red', 'Red', 24, true);
        portrait.animation.addByPrefix('green', 'Green', 24, true);
        portrait.animation.addByPrefix('parasite', 'Parasite', 24, true);
        portrait.animation.addByPrefix('white', 'White', 24, true);
        portrait.animation.addByPrefix('maroon', 'Maroon', 24, true);
        portrait.animation.addByPrefix('tomo', 'Tomo', 24, true);
        portrait.animation.addByPrefix('ham', 'Ham', 24, true);
        portrait.animation.addByPrefix('pink', 'Pink', 24, true);
        portrait.animation.addByPrefix('chef', 'Chef', 24, true);
        portrait.animation.addByPrefix('grey', 'Grey', 24, true);
        portrait.animation.addByPrefix('henry', 'Henry', 24, true);
        portrait.animation.addByPrefix('yellow', 'Yellow', 24, true);
        portrait.animation.addByPrefix('black', 'Defeat', 24, true);

        portrait.animation.play('red');
        portrait.antialiasing = true;
        portrait.setPosition(304.65, -100);
        portrait.updateHitbox();
        portrait.scrollFactor.set();
        add(portrait);

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
        add(upperBar);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
        var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        super.create();
        
    }

    override function update(elapsed:Float) {
        starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
        starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

        if(upP) {
            changeSelection(-1);
        }
        if(downP) {
            changeSelection(1);
        }
        super.update(elapsed);
    }

    function changeSelection(change:Int) {
        curSelected += change;
        if(curSelected < 0) {
            curSelected = 0;
        }
        else if(curSelected > listOfButtons.length - 1) {
            curSelected = listOfButtons.length - 1;
        }

        var bullShit:Int = 0;

		for (i in 0...listOfButtons.length)
		{
			listOfButtons[i].targetY = bullShit - curSelected;

            listOfButtons[i].spriteOne.alpha = 0.6;
            listOfButtons[i].icon.alpha = 0.6;
            listOfButtons[i].songText.alpha = 0.6;

            if(listOfButtons[i].targetY == 0) {
                listOfButtons[i].spriteOne.alpha = 1;
                listOfButtons[i].icon.alpha = 1;
                listOfButtons[i].songText.alpha = 1;
            }

			bullShit++;
		}
    }
}