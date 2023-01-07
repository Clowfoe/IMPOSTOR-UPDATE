package;

#if android
import android.os.Build.VERSION;
#end
import openfl.Lib;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

enum GLInfo
{
	RENDERER;
	SHADING_LANGUAGE_VERSION;
}

class Overlay extends TextField
{
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var currentMemoryPeak:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, size_x:Int = 1, size_y:Int = 1, size:Int = 15)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;
		mouseEnabled = false;

		defaultTextFormat = new TextFormat('_sans', Std.int(size * Math.min(Lib.current.stage.stageWidth / size_x, Lib.current.stage.stageHeight / size_y)), 0xFFFFFF);

		currentTime = 0;
		currentMemoryPeak = 0;
		times = [];

		addEventListener(Event.ENTER_FRAME, function(e:Event)
		{
			var time:Int = Lib.getTimer();
			onEnterFrame(time - currentTime);
		});
		addEventListener(Event.RESIZE, function(e:Event)
		{
			final daSize:Int = Std.int(size * Math.min(Lib.current.stage.stageWidth / size_x, Lib.current.stage.stageHeight / size_y));
			if (defaultTextFormat.size != daSize)
				defaultTextFormat.size = daSize;
		});
	}

	private function onEnterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
			times.shift();

		var currentFrames:Int = times.length;
		if (currentFrames > Std.int(Lib.current.stage.frameRate))
			currentFrames = Std.int(Lib.current.stage.frameRate);

		if (currentFrames <= Std.int(Lib.current.stage.frameRate) / 4)
			textColor = 0xFFFF0000;
		else if (currentFrames <= Std.int(Lib.current.stage.frameRate) / 2)
			textColor = 0xFFFFFF00;
		else
			textColor = 0xFFFFFFFF;

		var currentMemory:UInt = System.totalMemory;
		if (currentMemory > currentMemoryPeak)
			currentMemoryPeak = currentMemory;

		if (visible || alpha > 0)
		{
			var stats:Array<String> = [];
			stats.push('FPS: ${currentFrames}');
			stats.push('Memory: ${getMemoryInterval(currentMemory.toFloat())} / ${getMemoryInterval(currentMemoryPeak.toFloat())}');
			stats.push('GL Renderer: ${getGLInfo(RENDERER)}');
			stats.push('GL Shading Version: ${getGLInfo(SHADING_LANGUAGE_VERSION)}');
			#if android
			stats.push('System: Android ${VERSION.RELEASE} (API ${VERSION.SDK_INT})');
			#elseif mac
			stats.push('System: ${lime.system.System.platformLabel}');
			#else
			stats.push('System: ${lime.system.System.platformLabel} ${lime.system.System.platformVersion}');
			#end
			stats.push(''); // adding this to not hide the last line.
			text = stats.join('\n');
		}
	}

	private function getMemoryInterval(size:Float):String
	{
		var data:Int = 0;

		final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
		while (size >= 1000 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1000;
		}

		size = Math.round(size * 100) / 100;

		if (data <= 2)
			size = Math.round(size);

		return '$size ${intervalArray[data]}';
	}

	private function getGLInfo(info:GLInfo):String
	{
		@:privateAccess
		var gl:Dynamic = Lib.current.stage.context3D.gl;

		switch (info)
		{
			case RENDERER:
				return Std.string(gl.getParameter(gl.RENDERER));
			case SHADING_LANGUAGE_VERSION:
				return Std.string(gl.getParameter(gl.SHADING_LANGUAGE_VERSION));
		}

		return '';
	}
}
