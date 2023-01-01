package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;

using StringTools;

class WalkingCrewmate extends FlxSprite {

    public var thecolor:String;
    public var xRange:Array<Float> = [0, 0];
    public var yHeight:Float = 0;
    
    var idle:Bool = false;
    var nextActionTime:Float;
    var time:Float;

    var right:Bool;

    var hibernating:Bool = false;

    public function new(theColor:Int, range:Array<Float>, height:Float, thescale:Float)
    {
        super(FlxG.random.float(range[1] - range[0]), height);   

        xRange = range;
        yHeight = height; 
        scale.set(thescale, thescale);

        lookupColor(theColor);

        frames = Paths.getSparrowAtlas('mira/walkers', 'impostor');	
	    animation.addByPrefix('walk', thecolor, 24, true);
        animation.addByIndices('idle', thecolor, [14, 15], "", 24, true);
	    animation.play('walk');
	    antialiasing = true;
	    scrollFactor.set(1, 1);

        setNewActionTime();
    }

    function lookupColor(h:Int){
        switch(h){
            case 0:
                thecolor = 'blue';
            case 1:
                thecolor = 'brown';
            case 2:
                thecolor = 'lime';
            case 3:
                thecolor = 'tan';
            case 4:
                thecolor = 'white'; 
            case 5:
                thecolor = 'yellow'; 
        }
    }

    function swapSkin(){
        nextActionTime = time + FlxG.random.float(5, 10);
        visible = false;
        animation.stop();
        animation.remove('walk');
        animation.remove('idle');
        var newColor:Int = FlxG.random.int(0, 6);
        lookupColor(newColor);
        animation.addByPrefix('walk', thecolor, 24, true);
        animation.addByIndices('idle', thecolor, [14, 15], "", 24, true);
    }

    function setNewActionTime(){
        nextActionTime = time + FlxG.random.float(2, 7);
    }

    function triggerNextAction(){

        if(hibernating == true){
            hibernating = false;
            visible = true;
        }

        if(FlxG.random.bool(20))
            right = FlxG.random.bool(50);

        if(idle == false && FlxG.random.bool(60)){
            idle = true;
        }
        if(idle == true && FlxG.random.bool(50)){
            idle = false;
        }
        setNewActionTime();
    }

    override function update(elapsed:Float) {

        time += elapsed;

        if(time > nextActionTime){
            triggerNextAction();
        }

        super.update(elapsed);
        
        if(hibernating == false){

            if(x > (xRange[1] * 0.9)){
                hibernating = true;
                x -= 50;
                right = false;
                swapSkin();
            }
    
            if(x < (xRange[0] * 1.1)){
                hibernating = true;
                x += 50;
                right = true;
                swapSkin();
            }
            
            if(idle == false){
                if(animation.curAnim.name != 'walk')
                    animation.play('walk');
    
                if(right == true){
                    x = FlxMath.lerp(x, x + 30, CoolUtil.boundTo(elapsed * 9, 0, 1));
                    flipX = false;
                }else{
                    x = FlxMath.lerp(x, x - 30, CoolUtil.boundTo(elapsed * 9, 0, 1));
                    flipX = true;
                }
            }else{
                if(animation.curAnim.name != 'idle' && (animation.curAnim.curFrame == 7 || animation.curAnim.curFrame == 15))
                    animation.play('idle');
    
                if(right == true){
                    flipX = false;
                }else{
                    flipX = true;
                }
            }

            if(x > xRange[1]){
                right = false;
            }
    
            if(x < xRange[0]){
                right = true;
            }
        }
        
        
    }
}