package;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.system.FlxAssets.FlxShader;

//hi fabs
// thanks rozebud

class BWShader extends FlxObject
{
	public var shader(default, null):BWShaderGLSL = new BWShaderGLSL();

	public var lowerBound(default, set):Float;
	public var upperBound(default, set):Float;
	public var invert(default, set):Bool;

	public function new(_lowerBound:Float = 0.01, _upperBound:Float = 0.15, _invert:Bool = false):Void{
		super();
		lowerBound = _lowerBound;
		upperBound = _upperBound;
		invert = _invert;
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	function set_invert(v:Bool):Bool{
		invert = v;
		shader.invert.value = [invert];
		return v;
	}

	function set_lowerBound(v:Float):Float{
		lowerBound = v;
		shader.lowerBound.value = [lowerBound];
		return v;
	}

	function set_upperBound(v:Float):Float{
		upperBound = v;
		shader.upperBound.value = [upperBound];
		return v;
	}

}

class BWShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform bool invert;
		uniform float lowerBound;
		uniform float upperBound;

		void main()
		{
			vec4 textureColor = texture2D(bitmap, openfl_TextureCoordv);

			float gray = 0.21 * textureColor.r + 0.71 * textureColor.g + 0.07 * textureColor.b;

			float outColor = 0;

			if(gray > upperBound){
				outColor = 1;
			}
			else if(!(gray < lowerBound) && (upperBound - lowerBound) != 0){
				outColor = (gray - lowerBound) / (upperBound - lowerBound);
			}

			if(invert){
				outColor = (1 - outColor) * textureColor.a;
			}

			gl_FragColor = vec4(outColor, outColor, outColor, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
