package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxObject;

class AmongCreditsState extends MusicBeatState
{
    private static var amongCreditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link
        //WE ARE ALL IMPORTANT PEOPLE
        ['Clowfoe',		'clow',	    'im clowfoe.... i directed the mod and i coded a SHIT TON of it\nim really proud of this whole team ty all for playing and hope it was worth the wait',	'https://twitter.com/Clowfoe'],		
        ['Ethan\nTheDoodler',	'ethan',		'im a real doodler now, mama','https://twitter.com/D00dlerEthan'],        
        ['_emi',			'emi',			'artist!! so glad to be a part of this mod.. ty for playing <3',				'https://twitter.com/superinky_'],   
        ['mayhew',			'mayhew',		'i made triple trouble and i am gay artist',		'@kibolomay'],
        
        ['aqua',			'aqua',			"local sexy babe and hot programmer\ni coded a lot of this mod and lost sleep working on it\nfollow me for my insane ramblings @ useraqua_",				'https://twitter.com/useraqua_'],   
        ['fabs',		'fabs',	    'did a thing',	'https://twitter.com/fabsthefabs'],		
        ['ziffy',	'ziffy',		'I HELPED ON TORTURE AND\nI MADE THE FREEPLAY MENU','https://twitter.com/ziffymusic'],
        ['Rozebud',		'rozebud',	"Download Bunker Bumrush.\nPlay my new game Bunker Bumrush.",		'https://twitter.com/helpme_thebigt'],
        ['duskie',		'duskie',	    'From what little i did do for this mod, the team was nice and fun to work with. Hope you enjoyed the double note ghosts :)',	'https://twitter.com/DuskieWhy'],		
        
        ['punkett',				'punkett',			"im punkett",	'https://twitter.com/_punkett'],
        ['emihead',				'emihead',			"im emihead i made tomonjus tuesday and the credits song also i am canonically the black impostor's lover so please draw us making out and tag me on twitter @ emihead",	'https://twitter.com/emihead'],
        ['Saster',		'saster',	"Hey guys, it's me! I composed Sauces Moogus and Heartbeat. Though they are both songs I created more than a year ago, I still think they're not too bad. I hope you enjoyed those songs and see you in another mod!!",		'https://twitter.com/sub0ru'],
        ['Rareblin',		'rareblin',	"im a funny musician idk check out my Youtube channel",		'https://www.youtube.com/channel/UCnTN-0q7Wv1zqvBXQ_g4gZA'],
        ['keoni',				'keoni',			"keoni",	'https://twitter.com/AmongUsVore'],
        ['Keegan',		'keegan',	"Hey Gamers, I'm Keegan, I made Turbulence and all the midi sections of Room Code.\nI like ENA and I draw occasionally you should follow me @__Keegan_",		'https://twitter.com/__Keegan_'],
        ['fluffyhairs',				'fluffyhair',			"subscribe to fluffyhairs",	'https://twitter.com/fluffyhairslol'],
        ['Nii-san', 'niisan', 'Musician. Had lots of fun working on this mod, thanks to everyone for playing V4! (sub to my youtube, @niisanmusic, i uploaded the songs there)', 'https://twitter.com/NiisanHP'],
        ['JADS', 'jads', '"if u tired, just sleep." - Gandhi', 'https://twitter.com/Aw3somejds'],
        
        ['loggo',			'lojo',			'halloween',				'https://twitter.com/loggoman512'],   
        ['mayo',				'mayo',		"Hi I'm Mayokiddo! I'm an artist for the mod and I made a bunch of the playable mini impostor skins, and i also made a few sprites\nshout out to everyone currently in silly squad",	'https://twitter.com/Mayokiddo_'],
        ['Mash\nPro\nTato',     'mashywashy',   'im so sorry for making among us kills 2 years ago',    'https://twitter.com/MashProTato'],
        ['Julien',     'julien',   'hi i made the parasite form isnt he so awesome',    'https://twitter.com/itjulienn'],
        ['neato',				'neato',		'if she yo girl why my leitmotif in her theme',	'https://neatong.newgrounds.com/'],
        ['orbyy',			'orb',			"Im really happy i got to work on this, i was brought on v3 to do pixel art for tomongus and i'm grateful for being given the opportunity. I hope yall love the new pixel art for tomongus week and i apologize for v3's defeat chart.",    'https://twitter.com/OrbyyNew'],   
        ['squidboy',	'squid',	'hi im squid you may or may not know me for moderating the impostorm discord server\nive also been working for impostor ever since its beginning so thats cool i guess\nlove u zial <3<3<3',		'https://twitter.com/SquidBoy84'],
        ['pip',			'pip',			'"            "',				'https://twitter.com/DojimaDog'],   
        ['crocidy',				'croc',		"can you follow me i made fourth wall",	'https://twitter.com/croc2RTX'],
        ['Lay\nLasagna',				'lay',		"#1 giggleboy and omfg fan\nhello mommy!!!!!!! :)))) i'm a big boy now!!!!",	'https://twitter.com/LayLasagna7'],
        ['coti',			'coti',			'hi !! im coti-- i didnt really do much except for a drawing or visual tweaking here and there, but im happy i got to work on the mod anyway !! remember to always be silly',	'https://twitter.com/espeoncutie'],   
        ['elikapika',			'pika',			'bunny emoji',	'https://twitter.com/elikapika'],   
        ['salterino',		'salterino',	    'hi i did 1 thing for mod hi',	'https://twitter.com/Salterin0'],		
        ['Farfoxx',			'hi',			"hi!!! i did a few little things for the mod - although i wish i could've helped more, seeing the mod's development progress was incredible! everyone on the team is so talented, i'm grateful i got to see it reach completion",	'https://twitter.com/iron222_2'],   
        ['Steve',              'thales',    "I'm very happy to help draw a small part of this mod, it's a big achievement for me, I hope you all have a good time in the game!", 'https://twitter.com/Steve06421194'],
        ['MSG',              'msg',    "gaming", 'https://twitter.com/MSGTheEpic'],

        ['Gonk',				'gonk',		"Working on Impostor has been a ton of fun honestly, was really cool to be a part of something special like this. I'm also the reason crewicide is in, dumb joke song based off a dream I had and its probably my favourite thing I worked on in the mod, It Funny, makes Me Lol",	'https://www.youtube.com/watch?v=rZP7kWOMPzI'],
        ['gibz',				'gibz',		"shit idk , charted a few songs",	'https://twitter.com/9766Gibz'],
        ['thales',				'thalesrealthistime',		"I guess I'm the closest to a Jorsawsee director in the mod? Created / Voiced Warchief and charted a lot, making sure everything was playable. Working with everyone was a pleasure, but never tell me to chart two 4+ minute songs again.",	'https://twitter.com/MoonlessShift'],
        ['kal',				'kal',		"i love snas\n-art by @Butholeeo",	'https://twitter.com/Kal_050'],
        
        ['monotone\ndoc',				'monotone',		"hi i'm the guy who voiced the shapeshifter, very grateful to have had the opportunity and i hope y'all thought it was cool :)",	'https://twitter.com/MonotoneDoc'],
        ['amongus\nfan',				'cooper',		"i did nothing for this mod but let them use red mungus but i get a quote for having cancer",	'https://twitter.com/amongusfan24'],
    ];

    var nameText:FlxText;
    var descText:FlxText;
    var curDesc:Int = 0;

    var wallback:FlxSprite;
    var frame:FlxSprite;
    var dumnote:FlxSprite;
    var lamp:FlxSprite;
    var lamplight:FlxSprite;
    var tree1:FlxSprite;
    var tree2:FlxSprite;

    var portrait:FlxSprite;

    var mole:FlxSprite; //hey pip :]
    var baritone:FlxSprite; //hey pip again :]

    private var camFollowPos:FlxObject;

    override public function create()
    {
        super.create();

        camFollowPos = new FlxObject(0, 0, 1, 1);

        FlxG.camera.zoom = 0.8;
        FlxG.camera.follow(camFollowPos, LOCKON);

        camFollowPos.setPosition(660, 370);

        wallback = new FlxSprite().loadGraphic(Paths.image('credits/wallback', 'impostor'));
		wallback.antialiasing = true;
        wallback.scale.set(1.3, 1.3);
		add(wallback);

        portrait = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/portraits/clow', 'impostor'));
		portrait.antialiasing = true;
		add(portrait);

        frame = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/frame', 'impostor'));
		frame.antialiasing = true;
		add(frame);

        dumnote = new FlxSprite(0, 30).loadGraphic(Paths.image('credits/stickynote', 'impostor'));
		dumnote.antialiasing = true;
		dumnote.scale.set(1.25, 1.25);
		add(dumnote);

        
        lamplight = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/lamplight', 'impostor'));
		lamplight.antialiasing = true;
        lamplight.x = (FlxG.width / 2)  - (lamplight.width / 2);
        lamplight.blend = ADD;
        lamplight.alpha = 0.2;
		add(lamplight);

        lamp = new FlxSprite(0, -50).loadGraphic(Paths.image('credits/lamp', 'impostor'));
		lamp.antialiasing = true;
        lamp.x = (FlxG.width / 2)  - (lamp.width / 2);
		add(lamp);

        tree1 = new FlxSprite(-400, 0).loadGraphic(Paths.image('credits/tree', 'impostor'));
		tree1.antialiasing = true;
		add(tree1);

        tree2 = new FlxSprite(1050, 0).loadGraphic(Paths.image('credits/tree2', 'impostor'));
		tree2.antialiasing = true;
		add(tree2);

        mole = new FlxSprite(621, 620).loadGraphic(Paths.image('credits/mole', 'impostor'));
		mole.antialiasing = false;
        add(mole);

        descText = new FlxText(0, 600, 1200, "", 0);
		descText.setFormat(Paths.font("AmaticSC-Bold.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 1.3;
        add(descText);

        nameText = new FlxText(565, 120, 800, "", 0);
		nameText.setFormat(Paths.font("Dum-Regular.ttf"), 45, FlxColor.BLACK, CENTER);
		nameText.angle = -12;
        nameText.updateHitbox();
        add(nameText);

        baritone = new FlxSprite(630, 638).loadGraphic(Paths.image('credits/baritoneAd', 'impostor'));
		baritone.antialiasing = false;
        baritone.scale.set(1.2, 1.2);
        add(baritone);
        
        updateDescription();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (amongCreditsStuff[curDesc][1] == 'pip'){ mole.visible = true; }
        else{ mole.visible = false; }

        if (amongCreditsStuff[curDesc][1] == 'rozebud'){ baritone.visible = true; }
        else{ baritone.visible = false; }
     
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;

		if (leftP)
		{
			updateDescription(-1);
		}
		if (rightP)
		{
			updateDescription(1);
		}

    	if (controls.BACK)			
        {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
        if(controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			CoolUtil.browserLoad(amongCreditsStuff[curDesc][3]);
		}
    }

    function updateDescription(?change:Int)
    {
        curDesc += change;
        
        if(curDesc >= amongCreditsStuff.length - 1)
        {
            curDesc = amongCreditsStuff.length - 1;
            tree2.visible = true;
        }
        else
            tree2.visible = false;
        if(curDesc <= 0)
        {
            curDesc = 0;
            tree1.visible = true;
        }
        else
            tree1.visible = false;

        nameText.text = amongCreditsStuff[curDesc][0];

        descText.text = amongCreditsStuff[curDesc][2];
        descText.x = ((FlxG.width / 2) - (descText.width / 2));

        switch(amongCreditsStuff[curDesc][0]){
            case 'Ethan\nTheDoodler' | 'Lay\nLasagna' | 'monotone\ndoc' | 'amongus\nfan':
                nameText.y = 100;
            case 'Mash\nPro\nTato':
                nameText.y = 80;
            default:
                nameText.y = 120;
        }

        portrait.loadGraphic(Paths.image('credits/portraits/' + amongCreditsStuff[curDesc][1], 'impostor'));
        portrait.x = ((FlxG.width / 2) - (portrait.width / 2));
        frame.x = portrait.x - 55;
        dumnote.x = frame.x + 560;
    }
}