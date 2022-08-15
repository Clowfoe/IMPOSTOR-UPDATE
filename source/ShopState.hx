package;

import flixel.math.FlxPoint;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxCamera;
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

using StringTools;

class ShopState extends MusicBeatState
{
    
    var charList:Array<String> = ['none','amongbf','redp','greenp', 'blackp','bfairship', 'bfg', 'bfmira', 'bfpolus', 'bfsauce', 'dripbf', 'picolobby']; // STOP ADDING TO THIS LIST IM TRYNA GETSHIT WORKING
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

    var offset:Float = 250;

    var isFocused:Bool = false;
    var canUnfocus:Bool = false;
    var focusTarget:FlxPoint;
    var focusedNode:ShopNode;

    // UI

    var panel:FlxSprite;

    var equipbutton:FlxSprite;
    var equipText:FlxText;

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
    */
    var nodeData:Array<Dynamic> = [
        ['bottom', 'root', 'redp', 125, false],
        ['right', 'redp', 'greenp', 250, false],
        ['left', 'redp', 'amongbf', 400, false],
        ['right', 'greenp', 'blackp', 450, false],
        ['bottom', 'redp', 'bfg', 200, false],
        ['top', 'root', 'bfpolus', 175, false],
        ['right', 'bfpolus', 'bfmira', 225, false],
        ['left', 'bfpolus', 'bfairship', 200, false],
        ['top', 'bfmira', 'bfsauce', 250, false],
        ['left', 'root', 'bf', 0, true]
    ];
    var root:ShopNode;

    override function create()
	{
		super.create();

        // TODO: FIX THIS SHITTY ASS LOADING SYSTEM
        // its really janky and not a good way of loading it but im tired idgaf
        for(i in 0... nodeData.length){
            nodeData[i][4] = ClientPrefs.boughtArray[i];
        }

        persistentUpdate = true;
        FlxG.mouse.visible = true;

        focusTarget = new FlxPoint(0, 0);

        //i dont care
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

        clickPos = new FlxPoint();
        clickPosScreen = new FlxPoint();

        add(connectors);
        add(outlines);
        add(nodes);
        add(portraits);
        add(icons);
        add(overlays);
        add(texts);

        root = new ShopNode('root', FlxColor.RED, null, null, 0, true);
        nodes.add(root);
        trace('root name is ' + root.name);

        for(i in 0... nodeData.length){
            var node:ShopNode = new ShopNode(nodeData[i][2], FlxColor.ORANGE, nodeData[i][1], nodeData[i][0], nodeData[i][3], nodeData[i][4]);
            node.ID = i;
            connectors.add(node.connector);
            outlines.add(node.outline);
			nodes.add(node);
            icons.add(node.icon);
            portraits.add(node.portrait);
            overlays.add(node.overlay);
            texts.add(node.text);
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
		equipbutton.animation.play('buy');
		equipbutton.antialiasing = true;
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
        equipText.antialiasing = true;
        equipText.cameras = [camUpper];
        add(equipText);
    }

    function arrangeNodes(){
        //test for now; just a linear path from one to another;
        nodes.forEach(function(node:ShopNode) {
            if(node.name != 'root'){
                trace('node connection is ' + node.connection + ' direction is ' + node.connectionDirection);
                var connectionPos:Array<Float> = grabNodePos(node.connection);
                var finalPos:Array<Float> = connectionPos;

                switch(node.connectionDirection){
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
            }
        });
    }

    function updateNodeVisibility(){
        nodes.forEach(function(node:ShopNode) {
            if(node.connection != null || node.connection != 'root'){
                var connectedBought:Bool = checkPurchased(node.connection);
                if(connectedBought){
                    node.portrait.color = 0xFFFFFFFF;
                    node.icon.visible = true;
                    node.text.visible = true;
                }else{
                    node.portrait.color = 0xFF000000;
                    node.icon.visible = false;
                    node.text.visible = false;
                }
            }

            if(node.bought){
                node.text.visible = false;
            }
        });
    }

    function checkPurchased(_name:String):Bool{
        var guh:Bool = false;
        nodes.forEach(function(node:ShopNode) {
            if(node.name == _name && node.bought){
                guh = true;
            }
        });
        return guh;
    }

    function grabNodePos(_name:String):Array<Float>{
        var _x:Float = 0;
        var _y:Float = 0;
        nodes.forEach(function(node:ShopNode) {
            if(node.name == _name){
                _x = node.x;
                _y = node.y;
            }
        });
        return [_x, _y];
    }

    function changeSelection(huh:Int){
        curSelected += huh;
        if (curSelected < 0)
			curSelected = charList.length - 1;
		if (curSelected >= charList.length)
			curSelected = 0;
    }

    function handleCamPress(){
        clickPos.x = camFollowPos.x;
        clickPos.y = camFollowPos.y;
        clickPosScreen.x = FlxG.mouse.screenX;
        clickPosScreen.y = FlxG.mouse.screenY;
    }

    function updateButton(?node:ShopNode = null){
        if(node != null){
            if(!node.bought){
                equipbutton.animation.play('buy');
                equipText.text = 'BUY X' + node.price;
            }else{
                equipbutton.animation.play('equipped');
                equipText.text = 'EQUIP';
            }
            if(node.name == ClientPrefs.charOverride){
                equipbutton.animation.play('grey');
                equipText.text = 'EQUIPPED';
            }
        }
    }

    function focusNode(node:ShopNode){
        isFocused = true;
        FlxG.sound.play(Paths.sound('pop', 'impostor'), 0.9);
        focusedNode = node;
        updateButton(node);
        showPanel();
    }

    function buyNode(node:ShopNode){
        node.bought = true;
        updateButton(node);
        updateNodeVisibility();
    }

    function equipNode(node:ShopNode){
        ClientPrefs.charOverride = node.name;
        updateButton(node);
        ClientPrefs.saveSettings();
    }

    function unfocusNode(node:ShopNode){
        isFocused = false;
        FlxG.sound.play(Paths.sound('panelDisappear', 'impostor'), 0.9);
        hidePanel();
    }

    function handleCamDrag(){
        camFollowPos.x = clickPos.x + (clickPosScreen.x - FlxG.mouse.screenX);
        camFollowPos.y = clickPos.y + (clickPosScreen.y - FlxG.mouse.screenY);
    };

    function showPanel(){
        FlxTween.tween(panel, {x: FlxG.width * 0.6}, 0.4, {ease: FlxEase.circOut});
    }

    function hidePanel(){
        FlxTween.tween(panel, {x: FlxG.width * 1.4}, 0.4, {ease: FlxEase.circIn});
    }

    override function update(elapsed:Float)
    {
        equipbutton.setPosition(panel.getGraphicMidpoint().x - (equipbutton.width / 2), FlxG.height * 0.75);
        equipText.setPosition(panel.getGraphicMidpoint().x - (equipText.width / 2), FlxG.height * 0.785);
        
        nodes.forEach(function(node:ShopNode) {
            if (FlxG.mouse.overlaps(node) && FlxG.mouse.justPressed && node.name != 'root' && !FlxG.mouse.overlaps(equipbutton))
            {
                canUnfocus = false;
                focusNode(node);
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    canUnfocus = true;
                });
                focusTarget.x = (node.x + (node.width / 2)) + (FlxG.width * 0.18);
                focusTarget.y = node.y + (node.height / 2);
            }
        });

        if (FlxG.mouse.overlaps(equipbutton) && FlxG.mouse.justPressed)
        {
            if(!focusedNode.bought){
                buyNode(focusedNode);
            }else{
                equipNode(focusedNode);
            }
        }

        if (FlxG.sound.music.volume < 0.7)
        {
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        }
        
        if(!isFocused){
            if(FlxG.mouse.justPressed){ // convoluted but working way of clicking and dragging
                handleCamPress();
            }
    
            if(FlxG.mouse.pressed){
                handleCamDrag();
            }

            if (FlxG.mouse.wheel != 0)
            {
                FlxG.camera.zoom += ((FlxG.mouse.wheel / 10) * FlxG.camera.zoom);
            }
        }else{
            if(canUnfocus && FlxG.mouse.screenX < FlxG.width * 0.6){
                if(FlxG.mouse.justPressed || FlxG.mouse.wheel != 0){
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
    
        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
        var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
        var accepted = controls.ACCEPT;
        var space = FlxG.keys.justPressed.SPACE;

        if(FlxG.keys.justPressed.R){
            nodes.forEach(function(node:ShopNode) {
                node.bought = false;
            });
            updateNodeVisibility();
            ClientPrefs.saveSettings();
        }
        
        if (controls.BACK)
        {
            nodes.forEach(function(node:ShopNode) {
                ClientPrefs.boughtArray[node.ID] = node.bought;
            });

            ClientPrefs.saveSettings();
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}