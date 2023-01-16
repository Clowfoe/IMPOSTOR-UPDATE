package;

import flixel.tweens.misc.NumTween;
import flixel.math.FlxPoint;
#if desktop
import Discord.DiscordClient;
#end
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import Character;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.input.mouse.FlxMouseEventManager;

using StringTools;

enum RequirementType
{
	PERCENT95;
	COMPLETED;
}

enum SkinType
{
	BF;
	GF;
	PET;
}

class ShopState extends MusicBeatState
{
	var buttonTween:FlxTween;
	var textTween:FlxTween;

	var charList:Array<String> = [
		'none', 'amongbf', 'redp', 'greenp', 'blackp', 'bfairship', 'bfg', 'bfmira', 'bfpolus', 'bfsauce', 'dripbf', 'picolobby'
	]; // STOP ADDING TO THIS LIST IM TRYNA GETSHIT WORKING
	var curSelected:Int = 0;
	var things:FlxTypedGroup<FlxText>;

	var testList:Array<String> = ['p', 'penis', 'graaah'];
	var connectors:FlxTypedGroup<FlxSprite>;
	var outlines:FlxTypedGroup<FlxSprite>;
	var nodes:FlxTypedGroup<ShopNode>;
	var icons:FlxTypedGroup<FlxSprite>;
	var portraits:FlxTypedGroup<FlxSprite>;
	var overlays:FlxTypedGroup<FlxSprite>;
	var texts:FlxTypedGroup<FlxText>;

	var clickPos:FlxPoint;
	var clickPosScreen:FlxPoint;

	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	public var camGame:FlxCamera;
	public var camUpper:FlxCamera;
	public var camOther:FlxCamera;
	public var camStars:FlxCamera;

	var offset:Float = 250;
	var offset2:Float = 112;

	var isFocused:Bool = false;
	var canUnfocus:Bool = false;
	var focusTarget:FlxPoint;
	var focusedNode:ShopNode;

	var topBean:FlxSprite;
	var beanText:FlxText;

	// UI
	var panel:FlxSprite;

	var equipbutton:FlxSprite;
	var equipText:FlxText;

	var charName:FlxText;
	var charDesc:FlxText;

	var starsBG:Haxe5Backdrop;
	var starsFG:Haxe5Backdrop;

	var upperBar:FlxSprite;
	var crossImage:FlxSprite;

	// top bar
	var _state:String;

	var localBeans:Int;

	var petReset:FlxSprite;
	var gfReset:FlxSprite;
	var bfReset:FlxSprite;

	/*
		DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS 
		DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS 
		DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS DONT ADD ANY NEW CHARACTERS TO THIS 
		DONT ADD ANY NEW CHARACTERS TO THIS 
		please :)

	 */
	/*
		NOTE FOR ANYONE ADDING NODES:
		- first value is the connetction, going from top bottom left and right, which
		determine where the connection to another node will be made
		- the 2nd value is the previous node that it will connect to by name 
		(i.e 'greenp' will connect the node to the greenp node itself)
		- the 3rd value is the name of the current node and will determine the character it represents

		- the 4th value is the price in beans (this serves literally no purpose rn)

		- the 'root' is the starting node

		- the root isnt listed here but can be accessed by connecting to 'root'

		- TODO: expand on this menu with more tabs and shit but ehhhhhh im bored lol ill do it later
		jus saving this here to remember


		okay more shit

		OH AND THE CHARACTER TYPE           \/ - right here
		next four are the name, description, nd the requirements, then if its secret and if it is then u get a description to cover the real one
	 */
	var nodeData:Array<Dynamic> = [
		[
			'bottom',
			'root',
			'redp',
			125,
			false,
			'Red',
			'Unlocked by completing the first week.',
			BF,
			COMPLETED,
			['sussus-moogus', 'sabotage', 'meltdown']
		],
		[
			'right',
			'redp',
			'greenp',
			250,
			false,
			'Green',
			'Unlocked by completing the second week.',
			BF,
			COMPLETED,
			['sussus-toogus', 'lights-down', 'ejected']
		],
		[
			'right',
			'greenp',
			'blackp',
			450,
			false,
			'Black',
			"Unlocked by completing the black week",
			BF,
			COMPLETED,
			['defeat', 'finale'],
			true,
			"It's a secret!"
		],
		[
			'top',
			'blackp',
			'amongbf',
			400,
			false,
			'Crewmate',
			"Unlocked by completing all of the main story's songs.",
			BF,
			COMPLETED,
			[
				'sussus-moogus', 'sabotage', 'meltdown', 'sussus-toogus', 'lights-down', 'ejected', 'mando', 'dlow', 'oversight', 'danger', 'double-kill'
			]
		],
		[
			'bottom',
			'redp',
			'bfg',
			200,
			false,
			'Ghost BF',
			"Unlocked by achieving an accuracy higher than 95% on all of the first week's songs.",
			BF,
			PERCENT95,
			['sussus-moogus', 'sabotage', 'meltdown']
		],
		[
			'right',
			'bfg',
			'ghostgf',
			450,
			false,
			'Ghost GF',
			"Unlocked by achieving an accuracy higher than 95% on all of the first week's songs.",
			GF,
			PERCENT95,
			['sussus-moogus', 'sabotage', 'meltdown']
		],
		[
			'top',
			'root',
			'bfpolus',
			175,
			false,
			'Polus BF',
			'Unlocked by completing the fifth week.',
			BF,
			COMPLETED,
			['magmatic', 'ashes', 'boiling-point']
		],
		[
			'right',
			'root',
			'dripbf',
			225,
			false,
			'Drippypop BF',
			'Unlocked by achieving an accuracy higher than 95% on Drippypop.',
			BF,
			PERCENT95,
			['drippypop']
		],
		[
			'right',
			'bfpolus',
			'bfmira',
			225,
			false,
			'Mira BF',
			'Unlocked by completing the sixth week.',
			BF,
			COMPLETED,
			['heartbeat', 'pinkwave', 'pretender']
		],
		[
			'left',
			'bfpolus',
			'bfairship',
			200,
			false,
			'Airship BF',
			'Unlocked by completing the sixth week.',
			BF,
			COMPLETED,
			['delusion', 'blackout', 'neurotic']
		],
		[
			'right',
			'bfmira',
			'gfmira',
			250,
			false,
			'Mira GF',
			'Unlocked by completing the seventh week.',
			GF,
			COMPLETED,
			['heartbeat', 'pinkwave', 'pretender']
		],
		[
			'top',
			'bfmira',
			'bfsauce',
			250,
			false,
			'Chef BF',
			'Unlocked by achieving an accuracy higher than 95% on Sauces Moogus.',
			BF,
			PERCENT95,
			['sauces-moogus']
		],
		[
			'top',
			'bfpolus',
			'gfpolus',
			450,
			false,
			'Polus GF',
			"Unlocked by completing the fifth week.",
			GF,
			COMPLETED,
			['magmatic', 'ashes', 'boiling-point']
		],
		[
			'top',
			'gfpolus',
			'snowball',
			300,
			false,
			'Snowball',
			"i dont even know man",
			PET
		],
		[
			'right',
			'bfsauce',
			'ham',
			300,
			false,
			'Hammy',
			"its like a ham but with legs",
			PET
		],
		['bottom', 'bfg', 'dog', 300, false, 'Doggy', "man(?)'s best friend!", PET],
		[
			'bottom',
			'ghostgf',
			'frankendog',
			300,
			false,
			'Frankendog',
			"spooky ass dog",
			PET
		],
		[
			'left',
			'redp',
			'minicrewmate',
			300,
			false,
			'Crewmate',
			"your very own child",
			PET
		],
		[
			'left',
			'minicrewmate',
			'tomong',
			300,
			false,
			'Tomongus',
			"he's not among us, he's a hamster!",
			PET
		],
		[
			'top',
			'bfairship',
			'crab',
			300,
			false,
			'Bedcrab',
			"the thing from half life",
			PET
		],
		['left', 'crab', 'ufo', 300, false, 'UFO', "aliens ahh", PET],
		[
			'left',
			'root',
			'stick-bf',
			375,
			false,
			'Stickmin BF',
			"Unlocked by completing Henry's week.",
			BF,
			COMPLETED,
			['titular', 'reinforcements', 'greatest-plan', 'armed'],
			true,
			"Someone told me about some broken old device lying around the airship and i dont think anyones cleaned it up yet.\nMight wanna check that out sometime."
		],
		[
			'left',
			'stick-bf',
			'henrygf',
			375,
			false,
			'Stickmin GF',
			"Unlocked by completing Henry's week.",
			GF,
			COMPLETED,
			['titular', 'reinforcements', 'greatest-plan', 'armed'],
			true,
			"..."
		],
		['top', 'henrygf', 'stickmin', 300, false, 'H. Stickmin', "a tiny henry?", PET],
		['left', 'stickmin', 'elliepet', 300, false, 'E. Rose', "and an ellie too!", PET]
	];

	var root:ShopNode;

	override function create()
	{
		super.create();

		Paths.clearUnusedMemory();

		for (i in 0...nodeData.length)
		{
			nodeData[i][4] = ClientPrefs.boughtArray[i];
		}
		localBeans = ClientPrefs.beans;

		persistentUpdate = true;
		FlxG.mouse.visible = #if mobile false #else true #end;

		focusTarget = new FlxPoint(0, 0);

		// i dont care
		camGame = new FlxCamera();
		camUpper = new FlxCamera();
		camOther = new FlxCamera();
		camUpper.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUpper);
		FlxG.cameras.add(camOther);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;

		icons = new FlxTypedGroup<FlxSprite>();
		nodes = new FlxTypedGroup<ShopNode>();
		outlines = new FlxTypedGroup<FlxSprite>();
		overlays = new FlxTypedGroup<FlxSprite>();
		connectors = new FlxTypedGroup<FlxSprite>();
		portraits = new FlxTypedGroup<FlxSprite>();
		texts = new FlxTypedGroup<FlxText>();

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		FlxG.camera.follow(camFollowPos, null, 2);
		// camStars.follow(camFollowPos, null, 2);

		starsBG = new Haxe5Backdrop(Paths.image('shop/starBG', 'impostor'), XY, 0, 0);
		starsBG.antialiasing = !ClientPrefs.lowQuality;
		starsBG.updateHitbox();
		// starsBG.cameras = [camStars];
		starsBG.scrollFactor.set(0.3, 0.3);
		add(starsBG);

		starsFG = new Haxe5Backdrop(Paths.image('shop/starFG', 'impostor'), XY, 0, 0);
		starsFG.updateHitbox();
		starsFG.antialiasing = !ClientPrefs.lowQuality;
		// starsFG.cameras = [camStars];
		starsFG.scrollFactor.set(0.5, 0.5);
		add(starsFG);

		clickPos = new FlxPoint();
		clickPosScreen = new FlxPoint();

		add(connectors);
		add(outlines);
		add(nodes);
		add(portraits);
		add(icons);
		add(overlays);
		add(texts);

		root = new ShopNode('root', 'root', 'description', FlxColor.RED, BF, null, null, 0, true);
		nodes.add(root);
		trace('root name is ' + root.name);

		for (i in 0...nodeData.length)
		{
			var node:ShopNode = new ShopNode(nodeData[i][2], nodeData[i][5], nodeData[i][6], FlxColor.ORANGE, nodeData[i][7], nodeData[i][1], nodeData[i][0],
				nodeData[i][3], nodeData[i][4]);
			node.ID = i;
			connectors.add(node.connector);
			outlines.add(node.outline);
			nodes.add(node);
			icons.add(node.icon);
			portraits.add(node.portrait);
			overlays.add(node.overlay);
			texts.add(node.text);

			node.setUnlockState(nodeData[i][8], nodeData[i][9]);

			if (nodeData[i][10] == true)
			{
				node.updateSecret(nodeData[i][11]);
			}
		}

		arrangeNodes();
		updateNodeVisibility();

		panel = new FlxSprite(FlxG.width * 1.4, 0).makeGraphic(Std.int(FlxG.width * 0.4), FlxG.height, 0xFFA2A2A2);
		panel.alpha = 0.47;
		panel.cameras = [camUpper];
		add(panel);

		equipbutton = new FlxSprite(0, 0);
		equipbutton.frames = Paths.getSparrowAtlas('shop/button', 'impostor');
		equipbutton.animation.addByPrefix('buy', 'buy', 0, false);
		equipbutton.animation.addByPrefix('equipped', 'equipped', 0, false);
		equipbutton.animation.addByPrefix('grey', 'grey', 0, false);
		equipbutton.animation.addByPrefix('locked', 'locked', 0, false);
		equipbutton.animation.play('buy');
		equipbutton.antialiasing = !ClientPrefs.lowQuality;
		equipbutton.scale.set(0.8, 0.8);
		equipbutton.updateHitbox();
		equipbutton.scrollFactor.set();
		equipbutton.cameras = [camUpper];
		add(equipbutton);

		equipText = new FlxText(0, 0, equipbutton.width, 'BUY', 35);
		equipText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		equipText.updateHitbox();
		equipText.borderSize = 3;
		equipText.scrollFactor.set();
		equipText.antialiasing = !ClientPrefs.lowQuality;
		equipText.cameras = [camUpper];
		add(equipText);

		charName = new FlxText(0, 0, panel.width, 'this is a test', 70);
		charName.setFormat(Paths.font("ariblk.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charName.updateHitbox();
		charName.borderSize = 3;
		charName.scrollFactor.set();
		charName.antialiasing = !ClientPrefs.lowQuality;
		charName.cameras = [camUpper];
		add(charName);

		charDesc = new FlxText(0, 0, panel.width, 'this is a test', 20);
		charDesc.setFormat(Paths.font("ariblk.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charDesc.updateHitbox();
		charDesc.borderSize = 1;
		charDesc.scrollFactor.set();
		charDesc.antialiasing = !ClientPrefs.lowQuality;
		charDesc.cameras = [camUpper];
		add(charDesc);

		upperBar = new FlxSprite(-2, -1.4).loadGraphic(Paths.image('freeplay/topBar', 'impostor'));
		upperBar.antialiasing = !ClientPrefs.lowQuality;
		upperBar.updateHitbox();
		upperBar.scrollFactor.set();
		upperBar.cameras = [camUpper];
		add(upperBar);

		crossImage = new FlxSprite(12.50, 8.05).loadGraphic(Paths.buttonimage('freeplay/menuBack', 'impostor'));
		crossImage.antialiasing = !ClientPrefs.lowQuality;
		crossImage.scrollFactor.set();
		crossImage.updateHitbox();
		crossImage.cameras = [camUpper];
		add(crossImage);
		FlxMouseEventManager.add(crossImage, function onMouseDown(s:FlxSprite)
		{
			goBack();
		}, null, null);

		topBean = new FlxSprite(30, 100).loadGraphic(Paths.image('shop/bean', 'impostor'));
		topBean.antialiasing = !ClientPrefs.lowQuality;
		topBean.cameras = [camUpper];
		topBean.updateHitbox();
		add(topBean);

		beanText = new FlxText(110, 105, 200, '---', 35);
		beanText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		beanText.updateHitbox();
		beanText.borderSize = 3;
		beanText.scrollFactor.set();
		beanText.antialiasing = !ClientPrefs.lowQuality;
		beanText.cameras = [camUpper];
		add(beanText);

		beanText.text = Std.string(localBeans);
	}

	function resetChar(id:Int)
	{
		equipbutton.animation.play('equipped');
		switch (id)
		{
			case 0:
				ClientPrefs.charOverrides[0] = 'bf';
			case 1:
				ClientPrefs.charOverrides[1] = 'gf';
			case 2:
				ClientPrefs.charOverrides[2] = 'none';
		}
	}

	function arrangeNodes()
	{
		// test for now; just a linear path from one to another;
		nodes.forEach(function(node:ShopNode)
		{
			if (node.name != 'root')
			{
				trace('node connection is ' + node.connection + ' direction is ' + node.connectionDirection);
				var connectionPos:Array<Float> = grabNodePos(node.connection);
				var finalPos:Array<Float> = connectionPos;

				switch (node.connectionDirection)
				{
					case 'top':
						finalPos[1] += offset;
					case 'bottom':
						finalPos[1] -= offset;
					case 'left':
						finalPos[0] -= offset;
					case 'right':
						finalPos[0] += offset;
				}
				node.setPosition(finalPos[0], finalPos[1]);
				node.connector.visible = true;
				switch (node.connectionDirection)
				{
					case 'top':
						node.connector.angle = -90;
						// node.updateHitbox();
						node.connector.setPosition(node.x - 5, node.y - 100);
					case 'bottom':
						node.connector.angle = -90;
						// node.updateHitbox();
						node.connector.setPosition(node.x - 5, node.y + 200);
					case 'right':
						node.connector.setPosition(node.x + -184, node.y + 39.3);
					case 'left':
						node.connector.setPosition(node.x + 163.8, node.y + 39.3);
				}
			}
		});
	}

	function updateNodeVisibility()
	{
		nodes.forEach(function(node:ShopNode)
		{
			if (node.connection != null || node.connection != 'root')
			{
				var connectedBought:Bool = checkPurchased(node.connection);
				if (connectedBought)
				{
					node.portrait.color = 0xFFFFFFFF;
					node.icon.visible = true;
					node.text.visible = true;
				}
				else
				{
					node.portrait.color = 0xFF000000;
					node.icon.visible = false;
					node.text.visible = false;
					node.visibleName = '???';
				}
			}

			if (node.bought)
			{
				node.text.visible = false;
			}

			if (node.gotRequirements == false)
			{
				node.portrait.color = 0xFF000000;
				node.icon.visible = false;
				node.text.visible = false;
				node.visibleName = '???';
			}
		});
	}

	function checkPurchased(_name:String):Bool
	{
		var guh:Bool = false;
		nodes.forEach(function(node:ShopNode)
		{
			if (node.name == _name && node.bought)
			{
				guh = true;
			}
		});
		return guh;
	}

	function grabNodePos(_name:String):Array<Float>
	{
		var _x:Float = 0;
		var _y:Float = 0;
		nodes.forEach(function(node:ShopNode)
		{
			if (node.name == _name)
			{
				_x = node.x;
				_y = node.y;
			}
		});
		return [_x, _y];
	}

	function changeSelection(huh:Int)
	{
		curSelected += huh;
		if (curSelected < 0)
			curSelected = charList.length - 1;
		if (curSelected >= charList.length)
			curSelected = 0;
	}

	function handleCamPress()
	{
		clickPos.x = camFollowPos.x;
		clickPos.y = camFollowPos.y;
		clickPosScreen.x = FlxG.mouse.screenX;
		clickPosScreen.y = FlxG.mouse.screenY;
	}

	function updateButton(?node:ShopNode = null)
	{
		if (node != null)
		{
			var connectedBought:Bool = true;
			connectedBought = checkPurchased(node.connection);
			if (!node.bought)
			{
				equipbutton.animation.play('buy');
				equipText.text = 'BUY X' + node.price;
			}
			else
			{
				equipbutton.animation.play('equipped');
				equipText.text = 'EQUIP';
			}
			if (node.name == ClientPrefs.charOverrides[0]
				|| node.name == ClientPrefs.charOverrides[1]
				|| node.name == ClientPrefs.charOverrides[2])
			{
				equipbutton.animation.play('grey');
				equipText.text = 'EQUIPPED';
			}
			if (!node.gotRequirements || !connectedBought)
			{
				equipbutton.animation.play('locked');
				equipText.text = 'LOCKED';
			}
		}
	}

	function focusNode(node:ShopNode)
	{
		isFocused = true;
		FlxG.sound.play(Paths.sound('pop', 'impostor'), 0.9);
		focusedNode = node;
		updateButton(node);
		charName.text = node.visibleName;
		charDesc.text = node.description;
		if (node.secret && !node.gotRequirements)
			charDesc.text = node.secretDesc;
		showPanel();
	}

	function buyNode(node:ShopNode)
	{
		node.bought = true;
		localBeans -= node.price;
		updateButton(node);
		updateNodeVisibility();

		beanText.text = Std.string(localBeans);
	}

	function equipNode(node:ShopNode)
	{
		switch (node.skinType)
		{
			case BF:
				if (node.name == ClientPrefs.charOverrides[0])
				{
					ClientPrefs.charOverrides[0] = 'bf';
					updateButton(node);
					ClientPrefs.saveSettings();
					updateNodeVisibility();
					return;
				}
				ClientPrefs.charOverrides[0] = node.name;
			case GF:
				if (node.name == ClientPrefs.charOverrides[1])
				{
					ClientPrefs.charOverrides[1] = 'gf';
					updateButton(node);
					ClientPrefs.saveSettings();
					updateNodeVisibility();
					return;
				}
				ClientPrefs.charOverrides[1] = node.name;
			case PET:
				if (node.name == ClientPrefs.charOverrides[2])
				{
					ClientPrefs.charOverrides[2] = '';
					updateButton(node);
					ClientPrefs.saveSettings();
					updateNodeVisibility();
					return;
				}
				ClientPrefs.charOverrides[2] = node.name;
		}
		// equipThing.animation.play('check');
		updateButton(node);
		ClientPrefs.saveSettings();
		updateNodeVisibility();
	}

	function unfocusNode(node:ShopNode)
	{
		isFocused = false;
		FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.9);
		hidePanel();
	}

	function handleCamDrag()
	{
		camFollowPos.x = clickPos.x + (clickPosScreen.x - FlxG.mouse.screenX);
		camFollowPos.y = clickPos.y + (clickPosScreen.y - FlxG.mouse.screenY);
	};

	function showPanel()
	{
		FlxTween.tween(panel, {x: FlxG.width * 0.6}, 0.4, {ease: FlxEase.circOut});
	}

	function hidePanel()
	{
		FlxTween.tween(panel, {x: FlxG.width * 1.4}, 0.4, {ease: FlxEase.circIn});
	}

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		equipbutton.setPosition(panel.getGraphicMidpoint().x - (equipbutton.width / 2), FlxG.height * 0.75);
		equipText.setPosition(panel.getGraphicMidpoint().x - (equipText.width / 2), FlxG.height * 0.785);
		charName.setPosition(panel.getGraphicMidpoint().x - (charName.width / 2), FlxG.height * 0.15);
		charDesc.setPosition(panel.getGraphicMidpoint().x - (charDesc.width / 2), FlxG.height * 0.39);

		starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
		starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));

		// trace(FlxG.camera.zoom);
		nodes.forEach(function(node:ShopNode)
		{
			if (FlxG.mouse.overlaps(node) && FlxG.mouse.justPressed && node.name != 'root' && !FlxG.mouse.overlaps(equipbutton))
			{
				canUnfocus = false;
				focusNode(node);
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					canUnfocus = true;
				});
				focusTarget.x = (node.x + (node.width / 2)) + (FlxG.width * 0.18);
				focusTarget.y = node.y + (node.height / 2);
			}
		});

		if (FlxG.mouse.overlaps(equipbutton) && FlxG.mouse.justPressed)
		{
			var pulseColor:FlxColor;

			var connectedBought:Bool = true;

			if (focusedNode.connection != null || focusedNode.connection != 'root')
			{
				connectedBought = checkPurchased(focusedNode.connection);
				trace(connectedBought, focusedNode.connection);
			}

			if (!focusedNode.bought && focusedNode.gotRequirements && localBeans >= focusedNode.price && connectedBought)
			{
				buyNode(focusedNode);
				FlxG.sound.play(Paths.sound('shopbuy', 'impostor'), 1);
				pulseColor = 0xFF30FF86;
				// FlxG.sound.play(Paths.sound('pop', 'impostor'), 0.9);
			}
			else if (!focusedNode.bought && focusedNode.gotRequirements && localBeans < focusedNode.price || !connectedBought)
			{
				FlxG.sound.play(Paths.sound('locked', 'impostor'), 1);
				camUpper.shake(0.01, 0.35);
				FlxG.camera.shake(0.005, 0.35);
				pulseColor = 0xFFFF4444;
			}
			else if (!focusedNode.gotRequirements)
			{
				FlxG.sound.play(Paths.sound('locked', 'impostor'), 1);
				camUpper.shake(0.01, 0.35);
				FlxG.camera.shake(0.005, 0.35);
				pulseColor = 0xFFFF4444;
			}
			else
			{
				equipNode(focusedNode);
				if (focusedNode.skinType == PET)
				{
					FlxG.sound.play(Paths.sound('equippet', 'impostor'), 1);
				}
				else
				{
					FlxG.sound.play(Paths.sound('equip', 'impostor'), 1);
				}
				pulseColor = 0xFFFFA143;
			}

			if (buttonTween != null)
				buttonTween.cancel();
			buttonTween = FlxTween.color(equipbutton, 0.6, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
			if (textTween != null)
				textTween.cancel();
			textTween = FlxTween.color(equipText, 0.5, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
		}

		if (FlxG.sound.music.volume < 0.3)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (FlxG.sound.music.volume > 0.3)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		if (!isFocused)
		{
			if (FlxG.mouse.justPressed)
			{ // convoluted but working way of clicking and dragging
				handleCamPress();
			}

			if (FlxG.mouse.pressed)
			{
				handleCamDrag();
			}

			if (FlxG.mouse.wheel != 0)
			{
				var nextZoom = FlxG.camera.zoom + ((FlxG.mouse.wheel / 10) * FlxG.camera.zoom);

				if (nextZoom > 0.05 && nextZoom < 1.75)
					FlxG.camera.zoom = nextZoom;
			}
		}
		else
		{
			if (canUnfocus && FlxG.mouse.screenX < FlxG.width * 0.6)
			{
				if (FlxG.mouse.justPressed || FlxG.mouse.wheel != 0)
				{
					isFocused = false;
					canUnfocus = false;
					hidePanel();
					handleCamPress();
				}
			}
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * 3, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, focusTarget.x, lerpVal), FlxMath.lerp(camFollowPos.y, focusTarget.y, lerpVal));
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, lerpVal);
		}

		if (FlxG.keys.justPressed.R)
		{
			nodes.forEach(function(node:ShopNode)
			{
				node.bought = false;
			});
			updateNodeVisibility();
			ClientPrefs.saveSettings();
		}

		// if(FlxG.keys.justPressed.B){
		//     add(new BeansPopup(50, camUpper));
		//     localBeans += 50;
		//     beanText.text = Std.string(localBeans);
		//     FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		//     trace('Giving beans');
		// }
		// if(FlxG.keys.justPressed.N){
		//     add(new BeansPopup(-10, camUpper));
		//     localBeans -= 10;
		//     beanText.text = Std.string(localBeans);
		//     FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		//     trace('Giving beans');
		// }

		if (controls.BACK)
		{
			goBack();
		}

		super.update(elapsed);
	}

	function goBack()
	{
		nodes.forEach(function(node:ShopNode)
		{
			ClientPrefs.boughtArray[node.ID] = node.bought;
		});
		ClientPrefs.beans = localBeans;

		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('cancelMenu'));
		MusicBeatState.switchState(new MainMenuState());
	}
}

class BeansPopup extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;
	var bean:FlxSprite;
	var popupBG:FlxSprite;
	var theText:FlxText;
	var lerpScore:Int = 0;
	var canLerp:Bool = false;

	public function new(amount:Int, ?camera:FlxCamera = null)
	{
		super(x, y);
		this.y -= 100;
		lerpScore = amount;

		ClientPrefs.beans += amount;

		var colorShader:ColorShader = new ColorShader(0);

		ClientPrefs.saveSettings();
		popupBG = new FlxSprite(FlxG.width - 300, 0).makeGraphic(300, 100, 0xF8FF0000);
		popupBG.visible = false;
		popupBG.scrollFactor.set();
		add(popupBG);

		bean = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/bean', 'impostor'));
		bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
		bean.antialiasing = !ClientPrefs.lowQuality;
		bean.updateHitbox();
		bean.scrollFactor.set();
		add(bean);

		theText = new FlxText(popupBG.x + 90, popupBG.y + 35, 200, Std.string(amount), 35);
		theText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
		theText.updateHitbox();
		theText.borderSize = 3;
		theText.scrollFactor.set();
		theText.antialiasing = !ClientPrefs.lowQuality;
		add(theText);

		bean.shader = colorShader.shader;
		theText.shader = colorShader.shader;

		FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});

		new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
			canLerp = true;
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0}, 0.8, {ease: FlxEase.expoOut});
			FlxG.sound.play(Paths.sound('getbeans', 'impostor'), 0.9);
		});

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}
		alpha = 0;
		bean.cameras = cam;
		theText.cameras = cam;
		popupBG.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {
			onComplete: function(twn:FlxTween)
			{
				alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
					startDelay: 2.5,
					onComplete: function(twn:FlxTween)
					{
						alphaTween = null;
						remove(this);
						if (onFinish != null)
							onFinish();
					}
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (canLerp)
		{
			lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, CoolUtil.boundTo(elapsed * 4, 0, 1) / 1.5));
			if (Math.abs(0 - lerpScore) < 10)
				lerpScore = 0;
		}

		theText.text = Std.string(lerpScore);
		bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
		theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
	}

	override function destroy()
	{
		if (alphaTween != null)
		{
			alphaTween.cancel();
		}
		super.destroy();
	}
}
