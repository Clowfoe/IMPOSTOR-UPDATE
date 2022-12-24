
enum abstract Haxe5Axes(Int)
{
	var X    = 0x01;
	var Y    = 0x10;
	var XY   = 0x11;
	var NONE = 0x00;
	
	/**
	 * Whether the horizontal axis is anebled
	 */
	public var x(get, never):Bool;
	
	/**
	 * Whether the vertical axis is anebled
	 */
	public var y(get, never):Bool;
	
	/**
	 * Internal helper to reference self
	 */
	var self(get, never):Haxe5Axes;
	
	inline function get_self():Haxe5Axes
	{
		return cast this;
	}
	
	inline function get_x()
	{
		return self == X || self == XY;
	}
	
	inline function get_y()
	{
		return self == Y || self == XY;
	}
	
	public function toString():String
	{
		return switch self
		{
			case X: "x";
			case Y: "y";
			case XY: "xy";
			case NONE: "none";
		}
	}
	
	public static function fromBools(x:Bool, y:Bool):Haxe5Axes
	{
		return cast (x ? (cast X:Int) : 0) | (y ? (cast Y:Int) : 0);
	}
	
	public static function fromString(axes:String):Haxe5Axes
	{
		return switch axes.toLowerCase()
		{
			case "x": X;
			case "y": Y;
			case "xy" | "yx" | "both": XY;
			case "none" | "" | null : NONE;
			default : throw "Invalid axes value: " + axes;
		}
	}
}