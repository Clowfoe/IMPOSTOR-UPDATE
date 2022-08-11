package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class RimlightShader
{
	public var shader(default, null):RimlightShaderGLSL = new RimlightShaderGLSL();

	public var distanceX(default, set):Float = 0.0009;
	public var distanceY(default, set):Float = 0.0009;
	public var rimlightColor(default, set):FlxColor = 0xFFFFFFFF;
	public var refSprite:FlxSprite;

	public function new(_distX:Float = 0.0009, _distY:Float = 0.0009, _rimlightColor:FlxColor = 0xFFFFFFFF, ?_refSprite:FlxSprite = null):Void{
		distanceX = _distX;
		distanceY = _distY;
		rimlightColor = _rimlightColor;
		refSprite = _refSprite;
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
}

class RimlightShaderGLSL extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec2 distance;
		uniform vec4 rimlightColor;
		uniform vec4 bounds;

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
	
			outColor = mix(rimlightColor.rgb, textureColor, overlapColor.a * rimlightColor.a);
	
			gl_FragColor = vec4(outColor.rgb * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
