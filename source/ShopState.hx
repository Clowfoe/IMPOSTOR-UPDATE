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

    var starsBG:FlxBackdrop;
    var starsFG:FlxBackdrop;

    var upperBar:FlxSprite;
    var crossImage:FlxSprite;

    // top bar

    var cosmicubeButton:FlxSprite;
    var petsButton:FlxSprite;
    var skinsButton:FlxSprite;

    var _state:String;

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
        ['right', 'bfg', 'ghostgf', 450, false],
        ['top', 'root', 'bfpolus', 175, false],
        ['right', 'root', 'dripbf', 225, false],
        ['right', 'bfpolus', 'bfmira', 225, false],
        ['left', 'bfpolus', 'bfairship', 200, false],
        ['right', 'bfmira', 'gfmira', 250, false],
        ['top', 'bfmira', 'bfsauce', 250, false],
        ['left', 'root', 'bf', 0, true],
        ['left', 'bf', 'stick-bf', 375, false]
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

        starsBG = new FlxBackdrop(Paths.image('shop/starBG', 'impostor'), 0.3, 0.3, true, true);
        starsBG.antialiasing = true;
        starsBG.updateHitbox();
       // starsBG.scrollFactor.set(0.3, 0.3);
        add(starsBG);
        
        starsFG = new FlxBackdrop(Paths.image('shop/starFG', 'impostor'), 0.5, 0.5, true, true);
        starsFG.updateHitbox();
        starsFG.antialiasing = true;
       // starsFG.scrollFactor.set(0.5, 0.5);
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

        charName = new FlxText(0, 0, panel.width, 'this is a test', 70);
		charName.setFormat(Paths.font("ariblk.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        charName.updateHitbox();
		charName.borderSize = 3;
        charName.scrollFactor.set();
        charName.antialiasing = true;
        charName.cameras = [camUpper];
        add(charName);

        upperBar = new FlxSprite(-2, -1.4).loadGraphic(Paths.image('freeplay/topBar', 'impostor'));
		upperBar.antialiasing = true;
		upperBar.updateHitbox();
		upperBar.scrollFactor.set();
		upperBar.cameras = [camUpper];
		add(upperBar);

		crossImage = new FlxSprite(12.50, 8.05).loadGraphic(Paths.image('freeplay/menuBack', 'impostor'));
		crossImage.antialiasing = true;
		crossImage.scrollFactor.set();
		crossImage.updateHitbox();
		crossImage.cameras = [camUpper];
		add(crossImage);
        FlxMouseEventManager.add(crossImage, function onMouseDown(s:FlxSprite)
		{
			goBack();
		}, null, null);

        cosmicubeButton = new FlxSprite(0, 8.05).loadGraphic(Paths.image('shop/icons/cosmicube', 'impostor'));
		cosmicubeButton.antialiasing = true;
		cosmicubeButton.scrollFactor.set();
		cosmicubeButton.updateHitbox();
        cosmicubeButton.screenCenter(X);
        cosmicubeButton.x += 100;
		cosmicubeButton.cameras = [camUpper];
		add(cosmicubeButton);
        FlxMouseEventManager.add(cosmicubeButton, function onMouseDown(s:FlxSprite)
		{
			changeFocus('cosmicube');
		}, null, null);

        petsButton = new FlxSprite(0, 8.05).loadGraphic(Paths.image('shop/icons/pets', 'impostor'));
		petsButton.antialiasing = true;
		petsButton.scrollFactor.set();
		petsButton.updateHitbox();
        petsButton.screenCenter(X);
		petsButton.cameras = [camUpper];
		add(petsButton);
        FlxMouseEventManager.add(petsButton, function onMouseDown(s:FlxSprite)
		{
			changeFocus('inventory', 'pets');
		}, null, null);

        skinsButton = new FlxSprite(0, 8.05).loadGraphic(Paths.image('shop/icons/skins', 'impostor'));
		skinsButton.antialiasing = true;
		skinsButton.scrollFactor.set();
		skinsButton.updateHitbox();
        skinsButton.screenCenter(X);
        skinsButton.x -= 100;
		skinsButton.cameras = [camUpper];
		add(skinsButton);
        FlxMouseEventManager.add(skinsButton, function onMouseDown(s:FlxSprite)
        {
            changeFocus('inventory', 'skins');
        }, null, null);
    

		topBean = new FlxSprite(30, 100).loadGraphic(Paths.image('shop/bean', 'impostor'));
        topBean.antialiasing = true;
        topBean.cameras = [camUpper];
        topBean.updateHitbox();
		add(topBean);	

        beanText = new FlxText(110, 105, 200, '18381', 35);
		beanText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        beanText.updateHitbox();
		beanText.borderSize = 3;
        beanText.scrollFactor.set();
        beanText.antialiasing = true;
        beanText.cameras = [camUpper];
        add(beanText);

        changeFocus('inventory', 'skins');
    }

    function changeFocus(_destination:String, ?_category:String){
        switch(_destination){
            case 'cosmicube':
                _state = 'cosmicube';
                connectors.visible = true;
                outlines.visible = true;
                nodes.visible = true;
                icons.visible = true;
                portraits.visible = true;
                overlays.visible = true;
                texts.visible = true;

                connectors.active = true;
                outlines.active = true;
                nodes.active = true;
                icons.active = true;
                portraits.active = true;
                overlays.active = true;
                texts.active = true;
            case 'inventory':
                _state = 'inventory';
                connectors.visible = false;
                outlines.visible = false;
                nodes.visible = false;
                icons.visible = false;
                portraits.visible = false;
                overlays.visible = false;
                texts.visible = false;

                connectors.active = false;
                outlines.active = false;
                nodes.active = false;
                icons.active = false;
                portraits.active = false;
                overlays.active = false;
                texts.active = false;
        }
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
                node.connector.visible = true;
                switch(node.connectionDirection){
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
        charName.text = node.name;
        showPanel();
    }

    function buyNode(node:ShopNode){
        node.bought = true;
        updateButton(node);
        updateNodeVisibility();
    }

    /*
    function equipNode(node:ShopNode){
        ClientPrefs.charOverride = node.name;
        equipThing.animation.play('check');
        updateButton(node);
        ClientPrefs.saveSettings();
        updateNodeVisibility();
    }*/

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
        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
        var rightP = controls.UI_RIGHT_P;
		var leftP = controls.UI_LEFT_P;
        var accepted = controls.ACCEPT;
        var space = FlxG.keys.justPressed.SPACE;

        switch(_state){
            case 'cosmicube':
                equipbutton.setPosition(panel.getGraphicMidpoint().x - (equipbutton.width / 2), FlxG.height * 0.75);
                equipText.setPosition(panel.getGraphicMidpoint().x - (equipText.width / 2), FlxG.height * 0.785);
                charName.setPosition(panel.getGraphicMidpoint().x - (charName.width / 2), FlxG.height * 0.1);

                starsBG.x = FlxMath.lerp(starsBG.x, starsBG.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
                starsFG.x = FlxMath.lerp(starsFG.x, starsFG.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));
        
                //trace(FlxG.camera.zoom);
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
                     /*
                        equipNode(focusedNode);
                        */
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

                if(FlxG.keys.justPressed.R){
                    nodes.forEach(function(node:ShopNode) {
                        node.bought = false;
                    });
                    updateNodeVisibility();
                    ClientPrefs.saveSettings();
                }

                if(FlxG.keys.justPressed.B){
                    add(new BeansPopup(500, camUpper));
                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                    trace('Giving beans');
                }
        }

        if (controls.BACK)
        {
            goBack();
        }

        super.update(elapsed);
    }

    function goBack(){
        nodes.forEach(function(node:ShopNode) {
            ClientPrefs.boughtArray[node.ID] = node.bought;
        });

        ClientPrefs.saveSettings();
        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new MainMenuState());
    }
}

class BeansPopup extends FlxSpriteGroup {
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

        var colorShader:ColorShader = new ColorShader(0);

		ClientPrefs.saveSettings();
		popupBG = new FlxSprite(FlxG.width - 300, 0).makeGraphic(300, 100, 0xF8FF0000);
        popupBG.visible = false;
		popupBG.scrollFactor.set();
        add(popupBG);

        bean = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/bean', 'impostor'));
        bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
        bean.antialiasing = true;
        bean.updateHitbox(); 
        bean.scrollFactor.set();
		add(bean);	

        theText = new FlxText(popupBG.x + 90, popupBG.y + 35, 200, Std.string(amount), 35);
		theText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
        theText.updateHitbox();
		theText.borderSize = 3;
        theText.scrollFactor.set();
        theText.antialiasing = true;
        add(theText);

        bean.shader = colorShader.shader;
        theText.shader = colorShader.shader;

        FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});

        new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
            canLerp = true;
            colorShader.amount = 1;
            FlxTween.tween(colorShader, {amount: 0}, 0.8, {ease: FlxEase.expoOut});
        });

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		bean.cameras = cam;
		theText.cameras = cam;
		popupBG.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 1.8,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

    override function update(elapsed:Float){
        super.update(elapsed);
        if(canLerp){
            lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, CoolUtil.boundTo(elapsed * 6, 0, 1)));
            if(Math.abs(0 - lerpScore) < 10) lerpScore = 0;
        }

        theText.text = Std.string(lerpScore);
        bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
    }

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}