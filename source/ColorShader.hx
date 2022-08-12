package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class ColorShader extends FlxBasic // simplist fucking shader ever but idk a proper workaround IF THERES A WAY TO LMK
{
	public var shader(default, null):ColorShaderGLSL = new ColorShaderGLSL();

	public var amount(default, set):Float = 0;


	public function new(_amount:Float):Void{
		amount = _amount;
        super();
	}

    override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	function set_amount(v:Float):Float{
		amount = v;
		shader.amount.value = [amount];
		return v;
	}

}

class ColorShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float amount;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

            textureColor.rgb = textureColor.rgb + vec3(amount);
	
			gl_FragColor = vec4(textureColor.rgb * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
