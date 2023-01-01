package;

import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class ChromaticAbberation extends FlxBasic
{
    public var shader(default, null):CAGLSL = new CAGLSL();

    var iTime:Float = 0;

    public var amount(default, set):Float = 0;

    public function new(_amount:Float):Void{
        super();
       // shader.iResolution.value = [FlxG.stage.stageWidth, FlxG.stage.stageHeight];
        amount = _amount;
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
    }
    
    function set_amount(v:Float):Float{
		amount = v;
		shader.amount.value = [amount];
       // shader.iResolution.value = [FlxG.stage.stageWidth, FlxG.stage.stageHeight];
		return v;
	}
}

class CAGLSL extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float amount;

    vec2 PincushionDistortion(in vec2 uv, float strength) 
    {
	    vec2 st = uv - 0.5;
        float uvA = atan(st.x, st.y);
        float uvD = dot(st, st);
        return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
    }

    vec3 ChromaticAbberation(sampler2D tex, in vec2 uv) 
    {
	    float rChannel = texture(tex, PincushionDistortion(uv, 0.3 * amount)).r;
        float gChannel = texture(tex, PincushionDistortion(uv, 0.15 * amount)).g;
        float bChannel = texture(tex, PincushionDistortion(uv, 0.075 * amount)).b;
        vec3 retColor = vec3(rChannel, gChannel, bChannel);
        return retColor;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        vec3 col = ChromaticAbberation(bitmap, uv);
    
        gl_FragColor = vec4(col, 1.0);
    }')

    public function new()
    {
        super();
    }
}