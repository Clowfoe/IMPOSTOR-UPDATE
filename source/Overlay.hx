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
	@:noCompletion private var currentMemoryPeak:UInt;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, size_x:Int = 1, size_y:Int = 1, size:Int = 15)
	{
		super();

		this.x = x;
		this.y = y;

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
			stats.push('Memory: ${getMemorySize(currentMemory)} / ${getMemorySize(currentMemoryPeak)}');
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

	public static function getMemorySize(memory:UInt):String
	{
		var size:Float = memory;
		var label:Int = 0;
		var labels:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

		while(size >= 1000 && (label < labels.length - 1))
		{
			label++;
			size /= 1000;
		}

		return '${Std.int(size) + "." + addZeros(Std.string(Std.int((size % 1) * 100)), 2)}${labels[label]}';
	}

	public static inline function addZeros(str:String, num:Int)
	{
		while(str.length < num)
			str = '0${str}';

		return str;
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
