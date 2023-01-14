package;

import openfl.display3D.textures.Texture;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	private static var currentTrackedAssets:Map<String, Map<String, Dynamic>> = ["textures" => [], "graphics" => [], "sounds" => []];
	private static var localTrackedAssets:Map<String, Array<String>> = ["graphics" => [], "sounds" => []];

	// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory():Void
	{
		for (key in currentTrackedAssets["graphics"].keys())
		{
			@:privateAccess
			if (!localTrackedAssets["graphics"].contains(key))
			{
				if (currentTrackedAssets["textures"].exists(key))
				{
					var texture:Null<Texture> = currentTrackedAssets["textures"].get(key);
					texture.dispose();
					texture = null;
					currentTrackedAssets["textures"].remove(key);
				}

				var graphic:Null<FlxGraphic> = currentTrackedAssets["graphics"].get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
				currentTrackedAssets["graphics"].remove(key);
			}
		}

		for (key in currentTrackedAssets["sounds"].keys())
		{
			if (!localTrackedAssets["sounds"].contains(key))
			{
				OpenFlAssets.cache.removeSound(key);
				currentTrackedAssets["sounds"].remove(key);
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	public static function clearStoredMemory():Void
	{
		FlxG.bitmap.dumpCache();

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets["graphics"].exists(key))
			{
				var graphic:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
			}
		}

		for (key in OpenFlAssets.cache.getSoundKeys())
		{
			if (!currentTrackedAssets["sounds"].exists(key))
				OpenFlAssets.cache.removeSound(key);
		}

		for (key in OpenFlAssets.cache.getFontKeys())
			OpenFlAssets.cache.removeFont(key);

		localTrackedAssets["sounds"] = localTrackedAssets["graphics"] = [];
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	inline static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline public static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function deathData(key:String, ?library:String)
	{
		return getPath('sounds/deaths/$key/info.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}

	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if (FileSystem.exists(file))
			return file;
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Any
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Any
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Any
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String, ?useGL:Bool = true):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library, useGL ? ClientPrefs.useGL : false);
		return returnAsset;
	}

	inline static public function buttonimage(key:String, ?library:String):FlxGraphic
	{
		// image function for buttons 
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if (FileSystem.exists(file))
			return file;
		#end
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key)))
			return true;
		#end

		if (OpenFlAssets.exists(getPath(key, type)))
			return true;

		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key, library, false);

		var xmlExists:Bool = false;
		if (FileSystem.exists(modsXml(key)))
			xmlExists = true;

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)),
			(xmlExists ? File.getContent(modsXml(key)) : File.getContent(file('images/$key.xml', library))));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key, library, false);

		var txtExists:Bool = false;
		if (FileSystem.exists(modsTxt(key)))
			txtExists = true;

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)),
			(txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	public static function returnGraphic(key:String, ?library:String, ?useGL:Bool = false)
	{
		#if MODS_ALLOWED
		var path:String = modsImages(key);
		if (FileSystem.exists(path))
		{
			if (!currentTrackedAssets["graphics"].exists(path))
			{
				var graphic:FlxGraphic;
				var bitmapData:BitmapData = BitmapData.fromFile(path);

				if (useGL)
				{
					var texture:Texture = FlxG.stage.context3D.createTexture(bitmapData.width, bitmapData.height, BGRA, true);
					texture.uploadFromBitmapData(bitmapData);

					if (!currentTrackedAssets["textures"].exists(path))
						currentTrackedAssets["textures"].set(path, texture);

					localTrackedAssets["textures"].push(path);

					bitmapData.disposeImage();
					bitmapData.dispose();
					bitmapData = null;

					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
				}
				else
					graphic = FlxGraphic.fromBitmapData(bitmapData, false, path);

				graphic.persist = true;
				currentTrackedAssets["graphics"].set(path, graphic);
			}
		}
		#end

		var path:String = getPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path))
		{
			if (!currentTrackedAssets["graphics"].exists(path))
			{
				var graphic:FlxGraphic;
				var bitmapData:BitmapData = OpenFlAssets.getBitmapData(path);

				if (useGL)
				{
					var texture:Texture = FlxG.stage.context3D.createTexture(bitmapData.width, bitmapData.height, BGRA, true);
					texture.uploadFromBitmapData(bitmapData);
					currentTrackedAssets["textures"].set(path, texture);

					bitmapData.disposeImage();
					bitmapData.dispose();
					bitmapData = null;

					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
				}
				else
					graphic = FlxGraphic.fromBitmapData(bitmapData, false, path);

				graphic.persist = true;
				currentTrackedAssets["graphics"].set(path, graphic);
			}

			localTrackedAssets["graphics"].push(path);
			return currentTrackedAssets["graphics"].get(path);
		}

		FlxG.log.error('oh no $path is returning null NOOOO');
		return null;
	}

	public static function returnSound(path:String, key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var file:String = modsSounds(path, key);
		if (FileSystem.exists(file))
		{
			if (!currentTrackedAssets["sounds"].exists(file))
				currentTrackedAssets["sounds"].set(file, Sound.fromFile(file));

			localTrackedAssets["sounds"].push(file);
			return currentTrackedAssets["sounds"].get(file);
		}
		#end

		var file:String = getPath(path == 'songs' ? '$key.$SOUND_EXT' : '$path/$key.$SOUND_EXT', SOUND, path == 'songs' ? path : library);
		if (OpenFlAssets.exists(file))
		{
			if (!currentTrackedAssets["sounds"].exists(file))
				currentTrackedAssets["sounds"].set(file, OpenFlAssets.getSound(file));

			localTrackedAssets["sounds"].push(file);
			return currentTrackedAssets["sounds"].get(file);
		}

		FlxG.log.error('oh no $file is returning null NOOOO');
		return null;
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '')
	{
		return 'mods/' + key;
	}

	inline static public function modsFont(key:String)
	{
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String)
	{
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String)
	{
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String)
	{
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String)
	{
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String)
	{
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String)
	{
		return modFolders('images/' + key + '.txt');
	}

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/' + key + '.frag');
	}

	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/' + key + '.vert');
	}

	inline static public function modsAchievements(key:String)
	{
		return modFolders('achievements/' + key + '.json');
	}

	static public function modFolders(key:String)
	{
		if (currentModDirectory != null && currentModDirectory.length > 0)
		{
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}

		return 'mods/' + key;
	}

	public static var ignoreModFolders:Array<String> = [
		'characters', 'custom_events', 'custom_notetypes', 'data', 'songs', 'music', 'sounds', 'shaders', 'videos', 'images', 'stages', 'weeks', 'fonts',
		'scripts', 'achievements'
	];

	static public function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if (FileSystem.exists(modsFolder))
		{
			for (folder in FileSystem.readDirectory(modsFolder))
			{
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder))
				{
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}
