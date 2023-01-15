package;

import openfl.system.System;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = 1; // Zoom of the game.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsCounter:Overlay;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public function new():Void
	{
		super();

		SUtil.uncaughtErrorHandler();
		SUtil.checkPermissions();

		ClientPrefs.startControls();
		FlxGraphic.defaultPersist = false;
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if desktop
		FlxG.signals.gameResized.add(onResizeGame);
		#end

		fpsCounter = new Overlay(10, 3, gameWidth, gameHeight);
		addChild(fpsCounter);
		if (fpsCounter != null)
			fpsCounter.visible = ClientPrefs.showFPS;

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end
	}

	#if desktop
	function onResizeGame(w:Int, h:Int):Void
	{
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list)
		{
			@:privateAccess
			if (cam != null && (cam._filters != null && cam._filters.length > 0))
			{
				var sprite:Sprite = cam.flashSprite; // Shout out to Ne_Eo for bringing this to my attention
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
	}
	#end
}
