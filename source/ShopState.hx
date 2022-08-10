package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

using StringTools;

class ShopState extends MusicBeatState
{
    public var camGame:FlxCamera;
    public var camUpper:FlxCamera;
    public var camOther:FlxCamera;
    
    var charList:Array<String> = ['none','amongbf','redp','greenp', 'bfairship', 'ghost', 'bfmira', 'bfpolus', 'bfsauce'];
    var curSelected:Int = 0;
    var things:FlxTypedGroup<FlxText>;

    override function create()
	{
		super.create();

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

        things = new FlxTypedGroup<FlxText>();

        add(things);

        for(i in 0... charList.length){
            var thingy:FlxText = new FlxText(0, (FlxG.height / 2) + (i * 20), 200, charList[i], 18);
            thingy.screenCenter(X);
            thingy.ID = i;
            things.add(thingy);
        }
    }

    function changeSelection(huh:Int){
        curSelected += huh;
        if (curSelected < 0)
			curSelected = charList.length - 1;
		if (curSelected >= charList.length)
			curSelected = 0;
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.7)
        {
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        }

        things.forEach(function(guh:FlxText) {
            if(curSelected == guh.ID){
                guh.alpha = 1;
            }
            else{
                guh.alpha = 0.5;
            }
        });
    
        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
        var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
        var accepted = controls.ACCEPT;
        var space = FlxG.keys.justPressed.SPACE;
    
        if (upP)
        {
            changeSelection(-1);
        }
        if (downP)
        {
            changeSelection(1);
        }
    
        if (controls.BACK)
        {
            if(charList[curSelected] != 'none'){
                ClientPrefs.charOverride = charList[curSelected];
            }else{
                ClientPrefs.charOverride = '';
            }

            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}