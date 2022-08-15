package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if sys
import sys.FileSystem;
#end

class HenryState extends MusicBeatState
{
    
    var freezeFrame:FlxSprite;
    var grad:FlxSprite;

    var mic:FlxSprite;
    var stare:FlxSprite;
    var sock:FlxSprite;

    var canClick:Bool = false;

	override function create()
	{
		super.create();

        freezeFrame = new FlxSprite(0, 0).loadGraphic(Paths.image('henry/finalframe', 'impostor'));
        freezeFrame.width = FlxG.width;
        freezeFrame.height = FlxG.height;
        freezeFrame.updateHitbox();
        freezeFrame.screenCenter();
		add(freezeFrame);

        grad = new FlxSprite(0, 0).loadGraphic(Paths.image('henry/hguiofuhjpsod', 'impostor'));
        grad.width = FlxG.width;
        grad.height = FlxG.height;
        grad.updateHitbox();
        grad.screenCenter();
		add(grad);

        sock = new FlxSprite(0, 0);
        sock.frames = Paths.getSparrowAtlas('henry/Sock_Puppet_Option', 'impostor');	
        sock.animation.addByPrefix('select', 'Sock Puppet Select', 24, false);
        sock.animation.addByPrefix('deselect', 'Sock Puppet', 24, false);
        sock.scale.set(0.5, 0.5);
       // option.animation.play('select');
        sock.visible = false;
        sock.updateHitbox();

        stare = new FlxSprite(0, 0);
        stare.frames = Paths.getSparrowAtlas('henry/Stare_Down_Option', 'impostor');	
        stare.animation.addByPrefix('select', 'Stare Down Select', 24, false);
        stare.animation.addByPrefix('deselect', 'Stare Down', 24, false);
        stare.scale.set(0.5, 0.5);
       // option.animation.play('select');
        stare.visible = false;
        stare.updateHitbox();

        mic = new FlxSprite(0, 0);
        mic.frames = Paths.getSparrowAtlas('henry/Microphone_Option', 'impostor');	
        mic.animation.addByPrefix('select', 'Microphone Select', 24, false);
        mic.animation.addByPrefix('deselect', 'Microphone', 24, false);
        mic.scale.set(0.5, 0.5);
        mic.visible = false;
        mic.updateHitbox();

        add(sock);
        add(stare);
        add(mic);

        mic.antialiasing = true;
        stare.antialiasing = true;
        sock.antialiasing = true;

        mic.screenCenter();
        mic.x -= FlxG.width * 0.15;
        mic.y -= FlxG.height * 0.15;

        sock.screenCenter();
        sock.x += FlxG.width * 0.15;
        sock.y -= FlxG.height * 0.15;

        stare.screenCenter();
        stare.y += FlxG.height * 0.15;

        //options();
        startVideo('henry1', 0);
    }

    function options():Void{

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            mic.visible = true;
            FlxG.sound.play(Paths.sound('mic'), 0.6);
		});

        new FlxTimer().start(2, function(tmr:FlxTimer) {
            sock.visible = true;
            FlxG.sound.play(Paths.sound('sock'), 0.6);
		});

        new FlxTimer().start(3, function(tmr:FlxTimer) {
            stare.visible = true;
            FlxG.sound.play(Paths.sound('stare'), 0.6);
            canClick = true;
		});

    }

    function click(type:String){
        canClick = false;
        sock.visible = false;
        stare.visible = false;
        mic.visible = false;
        freezeFrame.visible = false;
        grad.visible = false;
        switch(type){
            case 'mic':
                startVideo('henrymic', 2);
            case 'sock':
                startVideo('henrysock', 1);
            case 'stare':
                startVideo('henrystare', 1);
        }
    }

    function dead(){
        canClick = true;
        sock.visible = true;
        stare.visible = true;
        mic.visible = true;
        freezeFrame.visible = true;
        grad.visible = true;
    }

    function win(){
        startWeek();
    }


    function startWeek():Void{
        
        var _difficulty:Int = 2; // TODO: make this the actual diff
        var _week:Int = 9;

        WeekData.reloadWeekFiles(true);

        // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[_week]).songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;

		var diffic = CoolUtil.difficultyStuff[_difficulty][1];
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = _difficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = _week;
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		LoadingState.loadAndSwitchState(new PlayState(), true);
    }

    var over:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        if(canClick){
        if (FlxG.mouse.overlaps(sock))
		{
			if(!over){
                over = true;
                FlxG.sound.play(Paths.sound('sock'), 0.6);
                sock.animation.play('select', true);
            }
			if(FlxG.mouse.pressed)
			{
                click('sock');
			}
        }else{
            if(sock.animation.curAnim != null){
                sock.animation.play('deselect', true);
            }
        }

        if (FlxG.mouse.overlaps(mic))
		{
			if(!over){
                over = true;
                FlxG.sound.play(Paths.sound('mic'), 0.6);
                mic.animation.play('select', true);
            }
			if(FlxG.mouse.pressed)
			{
                click('mic');
			}
        }else{
            if(mic.animation.curAnim != null){
                mic.animation.play('deselect', true);
            }
        }

        if (FlxG.mouse.overlaps(stare))
		{
			if(!over){
                over = true;
                FlxG.sound.play(Paths.sound('stare'), 0.6);
                stare.animation.play('select', true);
            }
			if(FlxG.mouse.pressed)
			{
                click('stare');
			}
        }else{
            if(stare.animation.curAnim != null){
                stare.animation.play('deselect', true);
            }
        }

        if(!FlxG.mouse.overlaps(stare) && !FlxG.mouse.overlaps(mic) && !FlxG.mouse.overlaps(sock)){
            over = false;
        }
        }
	}

    public function startVideo(name:String, funcToCall:Int):Void {

        var finishCallback:Void->Void;

        switch(funcToCall){
            case 0:
                finishCallback = options; 
            case 1:
                finishCallback = dead; 
            case 2:
                finishCallback = win;
        }
       
        
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
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
                finishCallback();
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
	}


}
