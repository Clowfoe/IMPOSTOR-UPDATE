package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class SkinState extends MusicBeatState
{
	private var camGame:FlxCamera;
	public static var curSkinSelected:Int = 0;

	var skins:Array<String> = ['bf', 'amongbf', 'bfpolus'];
	var selectSkins:FlxSpriteGroup;
	var skinBox:FlxSprite;
	var space:FlxSprite;
    var starsBG:FlxBackdrop;
    var starsFG:FlxBackdrop;

	override function create()
	{
		super.create();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

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

		skinBox = new FlxSprite().loadGraphic(Paths.image('skinSelect'));
		skinBox.scrollFactor.set(0, 0);
		skinBox.setGraphicSize(Std.int(skinBox.width * 0.85));
		skinBox.updateHitbox();
		skinBox.screenCenter();
		skinBox.antialiasing = ClientPrefs.globalAntialiasing;
		add(skinBox);

		selectSkins = new FlxSpriteGroup();
		add(selectSkins);

		for (i in 0...skins.length)
		{
			var bf:Character = new Character(590, 240, skins[i]);
			//startCharacterPos(bf, true);
			//bf.screenCenter();
			bf.ID = i;
			bf.flipX = false;
			selectSkins.add(bf);

			switch(i){
				case 1:
					bf.x -= 35;
					bf.y += 170;
				case 2:
					bf.x += 5;
					bf.y -= 10;
			}
		}

		changeItem();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		/*selectSkins.forEach(function(spr:FlxSprite)
		{
	        spr.x = skinBox.x;
		});*/

		starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
        starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				selectSkins.forEach(function(spr:FlxSprite)
				{
					if (spr.ID == curSkinSelected)
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							MusicBeatState.switchState(new MainMenuState());
						});
						//spr.playAnim('singRIGHT');
					}
				});
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSkinSelected += huh;

		if (curSkinSelected >= skins.length)
			curSkinSelected = 0;
		if (curSkinSelected < 0)
			curSkinSelected = skins.length - 1;

		selectSkins.forEach(function(spr:FlxSprite)
		{
			spr.visible = false;

			if (spr.ID == curSkinSelected)
			{
				spr.visible = true;
			}
		});
	}
}
