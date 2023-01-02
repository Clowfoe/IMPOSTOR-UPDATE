package;

import ShopState.RequirementType;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

using StringTools;

import AmongFreeplayState.RequireType;

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

    public var lock:FlxSprite;
    public var priceText:FlxText;
    public var price:Int = 0;
    public var locked:Bool = true;
    public var shuffleLetters:Array<String> = [];
    public var bean:FlxSprite;
    public var requirementtype:RequireType;

    var shuffleTimer:FlxTimer;

    public function new(x:Float, y:Float, song:String, namer:String, colord:FlxColor, portraits:String, ?requirement:RequireType, ?songs:Array<String>, _price:Int = 0, ?forceUnlock = false)
    {
        trueX = x;
        trueY = y;
        iconName = namer;
        coloring = colord;
        songName = song;
        portrait = portraits;
        requirementtype = requirement;
        price = _price;

        visible = false;

        spriteOne = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('freeplay/songPanel', 'impostor'));
        spriteOne.antialiasing = true;
        spriteOne.updateHitbox();

        lock = new FlxSprite(0, 0);
        if(requirement != SPECIAL) lock.frames = Paths.getSparrowAtlas('freeplay/lock', 'impostor'); else lock.frames = Paths.getSparrowAtlas('freeplay/lockGold', 'impostor');
		lock.animation.addByPrefix('lock', 'lock0', 24, true);
        lock.animation.addByPrefix('unlock', 'lock open', 24, false);
		lock.animation.play('lock');
		lock.antialiasing = true;
        lock.updateHitbox();

        priceText = new FlxText(0, 0, 500, Std.string(price), 28);
		priceText.setFormat(Paths.font("ariblk.ttf"), 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        priceText.updateHitbox();
		priceText.borderSize = 2;
        priceText.antialiasing = true;

        bean = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('freeplay/bean', 'impostor'));
        bean.scale.set(0.6, 0.6);
        bean.antialiasing = true;
        bean.updateHitbox();

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

        for(i in 0...song.length){
            shuffleLetters.push(song.charAt(i));
        }

        findLocked(requirement, songs, forceUnlock);

        if(price == 0){
            bean.visible = false;
            priceText.visible = false;
        }

        if(locked){
            doShuffle();
            icon.color = FlxColor.BLACK;
            spriteOne.color = 0xFF4A4A4A;
            shuffleTimer = new FlxTimer().start(FlxG.random.float(0.1, 0.2), function(tmr:FlxTimer)
            {
                doShuffle();
            }, 0);
        }

        super();        
    }

    public function unlockAnim(){
        var colorShader:ColorShader = new ColorShader(0);

        spriteOne.shader = colorShader.shader;
        lock.shader = colorShader.shader;
        priceText.shader = colorShader.shader;
        bean.shader = colorShader.shader;
        icon.shader = colorShader.shader;
        songText.shader = colorShader.shader;
        locked = false;

        FlxG.sound.play(Paths.sound('unlockSong', 'impostor'), 0.9);
        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            lock.animation.play('unlock');
            FlxTween.tween(colorShader, {amount: 1}, 1.2, {ease: FlxEase.expoIn});
            new FlxTimer().start(1.3, function(tmr:FlxTimer)
            {
                FlxTween.tween(colorShader, {amount: 0}, 1.2, {ease: FlxEase.expoOut});
                lock.visible = false;
                priceText.visible = false;
                bean.visible = false;
                spriteOne.color = 0xFFFFFFFF;
                icon.color = 0xFFFFFFFF;
                shuffleTimer.cancel();
                songText.text = songName;
                new FlxTimer().start(1.5, function(tmr:FlxTimer)
                {
                    spriteOne.shader = null;
                    lock.shader = null;
                    priceText.shader = null;
                    bean.shader = null;
                    icon.shader = null;
                    songText.shader = null;
                });
            });
        });
    }

    function findLocked(requirement:RequireType, songs:Array<String>, forceUnlock:Bool = false){
        locked = false;
        if(forceUnlock){
            lock.visible = false;
            bean.visible = false;
            priceText.visible = false;
            return;
        }

        if(requirement == FROM_STORY_MODE){
            for(song in songs){
                if(Highscore.getScore(song, 2) == 0){
                    locked = true;
                }
            }
        }
        if(requirement == BEANS){ 
            locked = true;
        }
        if(requirement == SPECIAL){ 
            for(song in songs){
                if(Highscore.getScore(song, 2) == 0){
                    locked = true;
                }
            }
        }

        if(locked){
            lock.visible = true;
            //bean.visible = true;
            //priceText.visible = true;
        }else{
            lock.visible = false;
            bean.visible = false;
            priceText.visible = false;
        }

    }

    function doShuffle(){
        FlxG.random.shuffle(shuffleLetters);
        var theText:String = '';
        for(letter in shuffleLetters){
            if(FlxG.random.bool(50)){
                letter = letter.toUpperCase();
            }else{
                letter = letter.toLowerCase();
            }
            theText += letter;
        }
        songText.text = theText;
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
        lock.alpha = FlxMath.lerp(lock.alpha, deAlpha, lerpVal);
        bean.alpha = FlxMath.lerp(bean.alpha, deAlpha, lerpVal);
        priceText.alpha = FlxMath.lerp(lock.alpha, deAlpha, lerpVal);
        spriteOne.alpha = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);
        songText.alpha = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);

        icon.setPosition(spriteOne.x - 13, spriteOne.y - 23);
        lock.setPosition(spriteOne.x + 25, spriteOne.y + 11);
        bean.setPosition(spriteOne.x + 405, spriteOne.y - 20);
        priceText.setPosition(spriteOne.x + 440, spriteOne.y - 20);
        songText.setPosition(spriteOne.x + 120, spriteOne.y + 5);
        super.update(elapsed);

    }
}