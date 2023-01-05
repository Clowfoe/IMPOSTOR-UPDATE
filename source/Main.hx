package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;

#if desktop
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;	
import Discord.DiscordClient;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsCounter:FPS;
	public static var fpsVar:FPS;
	

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}
	

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end
		
		ClientPrefs.startControls();

		// Paths.getModFolders();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FlxG.signals.gameResized.add(onResizeGame);
		
		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		if(fpsCounter != null) { 
			fpsCounter.visible = ClientPrefs.showFPS;
		}
		#end

		

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if desktop
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	function onResizeGame(w:Int, h:Int) {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null || cam._filters != []))
				fixShaderSize(cam);
		}	
	}

	function fixShaderSize(camera:FlxCamera) // Shout out to Ne_Eo for bringing this to my attention
		{
			@:privateAccess {
				var sprite:Sprite = camera.flashSprite;
	
				if (sprite != null)
				{
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	public function setFPSCap(cap:Float)
	{
		var framerate = Std.int(cap);
		openfl.Lib.current.stage.frameRate = cap;
		if (framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = framerate;
			FlxG.drawFramerate = framerate;
		}
		else
		{
			FlxG.drawFramerate = framerate;
			FlxG.updateFramerate = framerate;
		}
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	#if desktop
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
