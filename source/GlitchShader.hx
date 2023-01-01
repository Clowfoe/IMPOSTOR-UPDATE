package;

import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class GlitchShader extends FlxBasic
{
    public var shader(default, null):GlitchGLSL = new GlitchGLSL();

    var iTime:Float = 0;

    public var amount(default, set):Float = 0;

    public function new(_amount:Float):Void{
        super();
        shader.iResolution.value = [FlxG.stage.stageWidth, FlxG.stage.stageHeight];
        amount = _amount;
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }
    
    function set_amount(v:Float):Float{
		amount = v;
		shader.glitchAmount.value = [amount];
		return v;
	}
}

class GlitchGLSL extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform vec2 iResolution; 
        uniform float iTime;

        uniform float glitchAmount;

vec4 posterize(vec4 color, float numColors)
{
    return floor(color * numColors - 0.5) / numColors;
}

vec2 quantize(vec2 v, float steps)
{
    return floor(v * steps) / steps;
}

float dist(vec2 a, vec2 b)
{
    return sqrt(pow(b.x - a.x, 2.0) + pow(b.y - a.y, 2.0));
}

void main()
{   
    vec2 fragCoord = openfl_TextureCoordv * iResolution;
	vec2 uv = fragCoord.xy / iResolution.xy;
    float amount = pow(glitchAmount, 2.0);
    vec2 pixel = 1.0 / iResolution.xy;    
    vec4 color = texture2D(bitmap, uv);
    float t = mod(mod(iTime, amount * 100.0 * (amount - 0.5)) * 109.0, 1.0);
    vec4 postColor = posterize(color, 16.0);
    vec4 a = posterize(texture2D(bitmap, quantize(uv, 64.0 * t) + pixel * (postColor.rb - vec2(.5)) * 100.0), 5.0).rbga;
    vec4 b = posterize(texture2D(bitmap, quantize(uv, 32.0 - t) + pixel * (postColor.rg - vec2(.5)) * 1000.0), 4.0).gbra;
    vec4 c = posterize(texture2D(bitmap, quantize(uv, 16.0 + t) + pixel * (postColor.rg - vec2(.5)) * 20.0), 16.0).bgra;
    gl_FragColor = mix(texture2D(bitmap, 
                              uv + amount * (quantize((a * t - b + c - (t + t / 2.0) / 10.0).rg, 16.0) - vec2(.5)) * pixel * 100.0),
                    (a + b + c) / 3.0,
                    (0.5 - (dot(color, postColor) - 1.5)) * amount);
}')

    public function new()
    {
        super();
    }
}