import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import Character.CharacterFile;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
using Character.CharacterFile;
using StringTools;

class ShopNode extends FlxSprite
{
    public var outline:FlxSprite;
    public var overlay:FlxSprite;
    public var icon:FlxSprite;
    public var portrait:FlxSprite;

    public var connector:FlxSprite;

    public var text:FlxText;
    public var price:Int;
    public var bought:Bool;

    public var name:String;
    public var charData:CharacterFile;

    // CONNECTIONS
    public var connectionDirection:String;

    public var connection:String;

	public function new(_name:String, _color:FlxColor, ?_connection:String, ?_conDir:String, ?_price:Int, ?_bought:Bool)
	{
		super(x, y);

        name = _name;
        connection = _connection;
        connectionDirection = _conDir;
        price = _price;
        bought = _bought;

        connector = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/connector', 'impostor'));
		connector.antialiasing = true;
        connector.updateHitbox();
        connector.visible = false;

        outline = new FlxSprite(0, 0);
        outline.frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		outline.animation.addByPrefix('guh', 'back', 24, true);
		outline.animation.play('guh');
		outline.antialiasing = true;
        outline.updateHitbox();

		frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		animation.addByPrefix('guh', 'emptysquare', 24, true);
		animation.play('guh');
		antialiasing = true;
        updateHitbox();

        overlay = new FlxSprite(0, 0);
        overlay.frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		overlay.animation.addByPrefix('guh', 'overlay', 24, true);
		overlay.animation.play('guh');
		overlay.antialiasing = true;
        overlay.updateHitbox();

        charData = grabCharData(name);

        _color = FlxColor.fromRGB(charData.healthbar_colors[0], charData.healthbar_colors[1], charData.healthbar_colors[2]);

        outline.color = _color;
        overlay.color = _color;
        
        setupIcon(charData.healthicon);

        setupPortrait(name);

        text = new FlxText(0, 0, width, Std.string(price), 36);
		text.setFormat(Paths.font("ariblk.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 3;
        text.antialiasing = true;
        text.updateHitbox();
    }

    function setupPortrait(name:String){
        portrait = new FlxSprite(0, 0);
        portrait.frames = Paths.getSparrowAtlas('shop/portraits', 'impostor');
		portrait.animation.addByPrefix('guh', name, 0, false);
		portrait.animation.play('guh');
		portrait.antialiasing = true;
        portrait.updateHitbox();
    }

    function setupIcon(_name:String){
        var name:String = 'icons/' + _name;
	    if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + _name; //Older versions of psych engine's support
		if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
		var file:Dynamic = Paths.image(name, 'preload');

        icon = new FlxSprite(0, 0).loadGraphic(file, true, 150, 150);
        icon.animation.add('ball', [0], 0, false, false);
        icon.animation.play('ball');
        icon.antialiasing = true;
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        outline.setPosition(x, y);
        overlay.setPosition(x, y);
        icon.setPosition(getGraphicMidpoint().x - icon.frameWidth, getGraphicMidpoint().y - icon.frameHeight);
        portrait.setPosition(getGraphicMidpoint().x - (portrait.width / 2), getGraphicMidpoint().y - (portrait.height / 2));
        text.setPosition(getGraphicMidpoint().x - (text.width / 2), getGraphicMidpoint().y + (text.height / 1.8));

        if(bought){
            color = 0xFFFFFFFF;
        }else{
            color = 0xFF797979;
        }
    }

    function grabCharData(_char:String):CharacterFile{
        var characterPath:String = 'characters/' + _char + '.json';
		var path:String = Paths.getPreloadPath(characterPath);
		if (!Assets.exists(path))
		{
			path = Paths.getPreloadPath('characters/bf.json'); //If a character couldn't be found, change him to BF just to prevent a crash
		}

		var rawJson = Assets.getText(path);

		var json:CharacterFile = cast Json.parse(rawJson);
        return json;
    }
}