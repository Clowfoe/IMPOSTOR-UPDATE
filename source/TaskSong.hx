package;

#if sys
import sys.io.File;
#end

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
using flixel.util.FlxSpriteUtil;

class TaskSong extends FlxSpriteGroup
{
    var meta:Array<Array<String>> = [];
    var size:Float = 0;
    var fontSize:Int = 24;

    public function new(_x:Float, _y:Float, _song:String, ?_numberThing:Int = -1) {

        super(_x, _y);


        var addToPath = "";
        if(_numberThing != -1){
            addToPath = "" + _numberThing;
        }

        var pulledText:String = Assets.getText(Paths.txt(_song.toLowerCase().replace(' ', '-') + "/info" + addToPath));
        pulledText += '\n';
        var splitText:Array<String> = [];

        
        splitText = pulledText.split('\n');
        
        //theres literally no reason to have more than 2 lines
        //cry
        splitText.resize(2);

        trace(splitText.length);

        var text = new FlxText(0, 0, 0, "", fontSize);
        text.setFormat(Paths.font("arial.ttf"), fontSize, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var text2 = new FlxText(0, 30, 0, "", fontSize);
        text2.setFormat(Paths.font("arial.ttf"), fontSize, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);


        text.text = splitText[0];
        text2.text = splitText[1];

        text.updateHitbox();
        text2.updateHitbox();

        size = text2.fieldWidth;
        
        var bg = new FlxSprite(fontSize/-2, fontSize/-2).makeGraphic(Math.floor(size + fontSize), Std.int(text.height + text2.height + 15), FlxColor.WHITE);
        bg.height = text.height + text2.height;
        bg.alpha = 0.47;

        text.text += "\n";

        add(bg);
        add(text);
        add(text2);

        x -= size;
        alpha = 0.00000001; 
    }

    public function start(){
        alpha = 1;

        FlxTween.tween(this, {x: x + size + (fontSize/2)}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween){
            FlxTween.tween(this, {x: x - size - 50}, 1, {ease: FlxEase.quintInOut, startDelay: 2, onComplete: function(twn:FlxTween){ 
                this.destroy(); 
            }});
        }});
    }
}