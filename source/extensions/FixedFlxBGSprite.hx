package extensions;

import flixel.FlxBasic;
import flixel.system.FlxBGSprite;



//this class didnt account for zooms not = to 1 so here
class FixedFlxBGSprite extends FlxBGSprite
{
	@:access(flixel.FlxCamera)
	override public function draw():Void
	{
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}

			_matrix.identity();
			_matrix.scale(camera.viewWidth, camera.viewHeight);
			_matrix.translate(camera.viewMarginLeft, camera.viewMarginTop);
			camera.drawPixels(frame, _matrix, colorTransform);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}

}