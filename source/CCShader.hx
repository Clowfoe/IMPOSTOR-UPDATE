package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class CCShader
{
	public var shader(default, null):CCShaderGLSL = new CCShaderGLSL();

	public var distanceX(default, set):Float = 0.0009;
	public var distanceY(default, set):Float = 0.0009;
	public var rimlightColor(default, set):FlxColor = 0xFFFFFFFF;
	public var refSprite:FlxSprite;

	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var contrast(default, set):Float = 0;
	public var multiply(default, set):FlxColor = 0x00FFFFFF;


	public function new(_hue:Float = 0, _saturation:Float = 0, _brightness:Float = 0, _contrast:Float = 0, _multiply:FlxColor = 0x00FFFFFF, _distX:Float = 0.0009, _distY:Float = 0.0009, _rimlightColor:FlxColor = 0xFFFFFFFF, ?_refSprite:FlxSprite = null):Void{
		distanceX = _distX;
		distanceY = _distY;
		rimlightColor = _rimlightColor;
		refSprite = _refSprite;

		hue = _hue;
		saturation = _saturation;
		brightness = _brightness;
		contrast = _contrast;
		multiply = _multiply;
	}

	public function update():Void{
		if(refSprite != null){
			shader.bounds.value = [refSprite.frame.uv.left, refSprite.frame.uv.top, refSprite.frame.uv.right, refSprite.frame.uv.bottom];
		}
		else{ 
			shader.bounds.value = [0, 0, 1, 1]; 
		}
	}

	function set_distanceX(v:Float):Float{
		distanceX = v;
		shader.distance.value = [distanceX, distanceY];
		return v;
	}

	function set_distanceY(v:Float):Float{
		distanceY = v;
		shader.distance.value = [distanceX, distanceY];
		return v;
	}

	function set_rimlightColor(v:FlxColor):FlxColor{
		rimlightColor = v;
		shader.rimlightColor.value = [rimlightColor.redFloat, rimlightColor.greenFloat, rimlightColor.blueFloat, rimlightColor.alphaFloat];
		return v;
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

		uniform vec2 distance;
		uniform vec4 rimlightColor;
		uniform vec4 bounds;

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

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 overlapColor;

			vec2 overlapCoord = vec2(openfl_TextureCoordv.x - distance.x, openfl_TextureCoordv.y - distance.y);
			if(overlapCoord.x < bounds.x || overlapCoord.x > bounds.z || overlapCoord.y < bounds.y || overlapCoord.y > bounds.w){
				overlapColor = vec4(0);
			}
			else{
				overlapColor = flixel_texture2D(bitmap, overlapCoord);
			}

			vec3 outColor = textureColor.rgb;

			if(muliply.a > 0){
				vec3 multiplyColor = mix(textureColor.rgb, muliply.rgb, muliply.a);
				outColor = mix(applyHSBEffect(textureColor).rgb * multiplyColor, textureColor, overlapColor.a * rimlightColor.a);
			}else{
				outColor = mix(applyHSBEffect(textureColor), textureColor, overlapColor.a * rimlightColor.a);
			}
			

			if(muliply.a > 0){
				vec3 multiplyColor = mix(textureColor.rgb, muliply.rgb, muliply.a);
				textureColor.rgb *= multiplyColor;
			}
	
			gl_FragColor = vec4(outColor.rgb * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
