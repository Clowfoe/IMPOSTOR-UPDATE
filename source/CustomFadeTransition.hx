package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var width = FlxG.camera.viewWidth * 2;
		var height:Int = Std.int(FlxG.height * 1.25);
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.y = height + 400;
		transBlack.scale.x = width;
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		add(transBlack);

		transBlack.screenCenter(X);
		transGradient.screenCenter(X);


		if (isTransIn)
		{
			transGradient.y = transBlack.y - transBlack.height;
			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.linear
			});
		}
		else
		{
			transGradient.y = -transGradient.height;
			transBlack.y = transGradient.y - transBlack.height + 50;
			leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: executeCallback,
				ease: FlxEase.linear
			});
		}


	}

	override function update(elapsed:Float) {

		super.update(elapsed);
		
		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
	}

	override function destroy() {
		if(leTween != null) {
			executeCallback();
			leTween.cancel();
		}
		super.destroy();
	}


	function executeCallback(?_) {
		if (finishCallback != null) {
			finishCallback();
			finishCallback = null;
		}
	}
}