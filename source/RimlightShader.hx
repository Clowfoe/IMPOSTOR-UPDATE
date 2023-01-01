package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

//Written by Rozebud, teehee!!

class RimlightShader extends FlxBasic
{
	public var shader(default, null):RimlightShaderGLSL = new RimlightShaderGLSL();

	public var angle(default, set):Float = 0;
	public var distance(default, set):Float = 10;
	public var rimlightColor(default, set):FlxColor = 0xFFFFFFFF;
	public var refSprite:FlxSprite;

	public function new(_angle:Float = 0, _distance:Float = 10, _rimlightColor:FlxColor = 0xFFFFFFFF, _refSprite:FlxSprite):Void{
		super();
		angle = _angle;
		distance = _distance;
		rimlightColor = _rimlightColor;
		refSprite = _refSprite;

		shader.pixelSize.value = [1/refSprite.graphic.width, 1/refSprite.graphic.height];
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		uvUpdate();
	}

	public function uvUpdate(){
		shader.bounds.value = [refSprite.frame.uv.left, refSprite.frame.uv.top, refSprite.frame.uv.right, refSprite.frame.uv.bottom];
	}

	function set_angle(v:Float):Float{
		angle = v;
		shader.angle.value = [angle];
		return v;
	}

	function set_distance(v:Float):Float{
		distance = v;
		shader.distance.value = [distance];
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

		uniform float angle;
		uniform float distance;
		uniform vec4 rimlightColor;

		uniform vec2 pixelSize;
		uniform vec4 bounds;

		void main(){
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			float overlapAlpha;

			vec2 distanceScaled = vec2(cos(radians(angle)) * pixelSize.x * distance, sin(radians(angle)) * pixelSize.y * distance);

			vec2 overlapCoord = vec2(openfl_TextureCoordv.x + distanceScaled.x, openfl_TextureCoordv.y - distanceScaled.y);
			if(overlapCoord.x < bounds.x || overlapCoord.x > bounds.z || overlapCoord.y < bounds.y || overlapCoord.y > bounds.w){
				overlapAlpha = 0;
			}
			else{
				overlapAlpha = flixel_texture2D(bitmap, overlapCoord).a;
			}

			vec3 outColor = mix(rimlightColor.rgb, textureColor.rgb / textureColor.a, overlapAlpha * rimlightColor.a);
	
			gl_FragColor = vec4(outColor.rgb * textureColor.a, textureColor.a);
		}')

	public function new()
	{
		super();
	}
}
