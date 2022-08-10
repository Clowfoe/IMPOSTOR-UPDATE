package;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.system.FlxAssets.FlxShader;

/*
A shader that aims to replicate Adobe Animate's Adjust Color filter with the ability to add a tinted multiply layer similar to how Animate mixes color.
Basically just used to apply color adjusts to sprites without needing a whole new sprite sheet. 
Adapted from Andrey-Postelzhuk's shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
A lot of stuff needed to be changed to make it more accurate to Adobe Animate's Adjust Color filter or just to make it work in general.
*/

// this shader is made by rozebud thank u for letting me steal it

class CCShader extends FlxObject
{
	public var shader(default, null):CCShaderGLSL = new CCShaderGLSL();

	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var contrast(default, set):Float = 0;
	public var multiply(default, set):FlxColor = 0x00FFFFFF;

	//Adobe Animate's color adjust requires goes from -250 to 250 for total black and white.
	//Setting this to false will make the shader use -100 to 100 like the rest of the non-hue values.

	public function new(_hue:Float = 0, _saturation:Float = 0, _brightness:Float = 0, _contrast:Float = 0, _multiply:FlxColor = 0x00FFFFFF):Void{
		super();
		hue = _hue;
		saturation = _saturation;
		brightness = _brightness;
		contrast = _contrast;
		multiply = _multiply;
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	function set_hue(v:Float):Float{
		hue = v;
		shader.hue.value = [hue];
		return v;
	}

	function set_saturation(v:Float):Float{
		saturation = v;
		shader.saturation.value = [saturation];
		return v;
	}

	function set_brightness(v:Float):Float{
		brightness = v;
		shader.brightness.value = [brightness];
		return v;
	}

	function set_contrast(v:Float):Float{
		contrast = v;
		shader.contrast.value = [contrast];
		return v;
	}

	function set_multiply(v:FlxColor):FlxColor{
		multiply = v;
		shader.muliply.value = [multiply.redFloat, multiply.greenFloat, multiply.blueFloat, multiply.alphaFloat];
		return v;
	}

}

class CCShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float hue;
		uniform float saturation;
		uniform float brightness;
		uniform float contrast;
		uniform vec4 muliply;

		vec3 applyHue(vec3 aColor, float aHue)
        {
            float angle = radians(aHue);
            vec3 k = vec3(0.57735, 0.57735, 0.57735);
            float cosAngle = cos(angle);
            return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
        }

        vec4 applyHSBEffect(vec4 color)
        {
            color.rgb = applyHue(color.rgb, hue);

			// for some reason these need to have alpha subtracted from them to stop giant boxes from appearing
			color.rgb = clamp((color.rgb - 0.5) * (1.0 + ((contrast * color.a) / 100)) + 0.5, 0, 1); 
			color.rgb = clamp(color.rgb + ((brightness * color.a) / 250), 0, 1.05); // clamping at 1.05 made it looks slightly more like animate

			vec3 intensity = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            color.rgb = mix(intensity, color.rgb, (1.0 + (saturation / 100)));
			
            return color;
        }

		void main()
		{
			vec4 textureColor = texture2D(bitmap, openfl_TextureCoordv);

			textureColor = applyHSBEffect(textureColor);

			if(muliply.a > 0){
				vec3 multiplyColor = mix(textureColor.rgb, muliply.rgb, muliply.a);
				textureColor.rgb *= multiplyColor;
			}

			gl_FragColor = textureColor;
		}')

	public function new()
	{
		super();
	}
}
