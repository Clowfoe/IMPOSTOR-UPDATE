package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;

using StringTools;

class FreeplayCard extends FlxSprite {

    public var spriteOne:FlxSprite;
    public var icon:FlxSprite;
    public var trueX:Float;
    public var trueY:Float;
    public var coloring:FlxColor;
    public var iconName:String;
    public var songText:FlxText;
    public var portrait:String;
    public var songName:String;
    public var targetY:Float = 0;
    public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var yMult:Float = 100;
	public var xAdd:Float = 0;
    public var yAdd:Float = 0;
    public var deAlpha:Float = 0;

    public function new(x:Float, y:Float, song:String, namer:String, colord:FlxColor, portraits:String)
    {
        trueX = x;
        trueY = y;
        iconName = namer;
        coloring = colord;
        songName = song;
        portrait = portraits;

        visible = false;

        spriteOne = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('freeplay/songPanel', 'impostor'));
        spriteOne.antialiasing = true;
        spriteOne.updateHitbox();

        var name:String = 'icons/icon-' + iconName;
        var file:Dynamic = Paths.image(name);
        
        icon = new FlxSprite(trueX - 13, trueY - 23).loadGraphic(file, true, 150, 150);
        icon.antialiasing = true;
        icon.updateHitbox();
        icon.setGraphicSize(Std.int(icon.width * 0.6));

        songText = new FlxText(trueX + 50, trueY - 23, 0, song, 48);
        songText.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
        songText.antialiasing = true;
        songText.updateHitbox();

        super();        
    }

    override function update(elapsed:Float) {
        
        var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
        var theX:Float = 20;
        
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 15.6, 0, 1);        
        
        theX = (Math.abs(targetY * 70) * -1) + 70;

        spriteOne.y = FlxMath.lerp(spriteOne.y, (scaledY * 90) + (FlxG.height * 0.45), lerpVal);
        spriteOne.x = FlxMath.lerp(spriteOne.x, theX, lerpVal);

        deAlpha = 1 + (-Math.abs(targetY) * 0.25);

        icon.alpha = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);
        spriteOne.alpha = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);
        songText.alpha = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);

        icon.setPosition(spriteOne.x - 13, spriteOne.y - 23);
        songText.setPosition(spriteOne.x + 120, spriteOne.y + 5);
        super.update(elapsed);
    }
}