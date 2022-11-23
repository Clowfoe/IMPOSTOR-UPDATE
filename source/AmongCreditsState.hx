package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class AmongCreditsState extends MusicBeatState
{
    private static var amongCreditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link
        //important people
        ['Clowfoe',		'clow',	    'im clowfoe.... i directed the mod and i coded a SHIT TON of it\nim really proud of this whole team ty all for playing and hope it was worth the wait',	'https://twitter.com/Clowfoe'],		
        ['Ethan\nTheDoodler',	'ethan',		'im a real doodler now, mama','https://twitter.com/creepercrunch'],
        ['creeper\ncrunch',	'crunch',		'yo, im crunch, i directed jorsawsee and did a good bit of scattered work across the mod, working on this mod was awesome, i hope everyone loves it as much as i do!','https://twitter.com/creepercrunch'],
       
        //coders

        //artists
        ['mayhew',			'mayhew',		'i got in here because of stupid fan concept\ni loved working on this mod its so awesome vs impostor fnf mod vs impostor\nadd me on fall guys',		'https://twitter.com/SandPlanetNG'],
        ['mayo',				'mayo',		"Hi I'm Mayokiddo\nI'm an artist for the mod and I made a bunch of the playable mini impostor skins, and i also made a few sprites\nshout out to everyone currently in silly squad",	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],
        ['neato',				'neato',		'im neato i made sprites for drippypop insane streamer and turbulance\nand made some of the instrumental for insane streamer im gon get hit by a truck and break my spine',	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],
        ['squidboy84',	'squid',	'hi im squid you may or may not know me for moderating the impostorm discord server\nive also been working for impostor ever since its beginning so thats cool i guess\nlove u zial <3<3<3',							'https://twitter.com/Keoiki_'],
        ['pip',			'pip',			'mole',				'https://twitter.com/gedehari'],   
        ['crocidy',				'croc',		"can you follow me i made fourth wall",	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],
        ['LayLasagna7',				'lay',		"#1 giggleboy and omfg fan\nhello mommy!!!!!!! :)))) i'm a big boy now!!!!",	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],
 
        //musicians
        ['emihead',				'emihead',			"im emihead i made tomonjus tuesday and the credits song also i am canonically the black impostor's lover so please draw us making out and tag me on twitter @ emihead",	'https://twitter.com/emihead'],
		['Keegan',		'keegan',	"Hey Gamers, I'm Keegan, I made Turbulence and all the midi sections of Room Code.\nI like ENA and I draw occasionally you should follow me @__Keegan_",						'https://twitter.com/polybiusproxy'],
       
        //charters
        ['gibz',				'gibz',		" shit idk , charted a few songs",	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],

        //misc
        ['amongusfan24',				'cooper',		"i did nothing for this mod but let them use red mungus but i get a quote for having cancer",	'https://www.youtube.com/channel/UCxQTnLmv0OAS63yzk9pVfaw'],
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

    override public function create()
    {
        super.create();

        wallback = new FlxSprite().loadGraphic(Paths.image('credits/wallback', 'impostor'));
		wallback.antialiasing = true;
		add(wallback);

        portrait = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/portraits/clow', 'impostor'));
		portrait.antialiasing = true;
		add(portrait);

        frame = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/frame', 'impostor'));
		frame.antialiasing = true;
		add(frame);

        dumnote = new FlxSprite(0, 30).loadGraphic(Paths.image('credits/stickynote', 'impostor'));
		dumnote.antialiasing = true;
		add(dumnote);

        lamp = new FlxSprite(0, -50).loadGraphic(Paths.image('credits/lamp', 'impostor'));
		lamp.antialiasing = true;
        lamp.x = (FlxG.width / 2)  - (lamp.width / 2);
		add(lamp);

        lamplight = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/lamplight', 'impostor'));
		lamplight.antialiasing = true;
        lamplight.x = (FlxG.width / 2)  - (lamplight.width / 2);
        lamplight.alpha = 0.2;
		//add(lamplight);

        tree1 = new FlxSprite(-400, 0).loadGraphic(Paths.image('credits/tree', 'impostor'));
		tree1.antialiasing = true;
		add(tree1);

        tree2 = new FlxSprite(1050, 0).loadGraphic(Paths.image('credits/tree2', 'impostor'));
		tree2.antialiasing = true;
		add(tree2);

        descText = new FlxText(0, 600, 1200, "", 0);
		descText.setFormat(Paths.font("AmaticSC-Bold.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 1;
        add(descText);

        nameText = new FlxText(560, 120, 800, "", 0);
		nameText.setFormat(Paths.font("Dum-Regular.ttf"), 45, FlxColor.BLACK, CENTER);
		nameText.angle = -12;
        add(nameText);

        updateDescription();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
     
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

        portrait.loadGraphic(Paths.image('credits/portraits/' + amongCreditsStuff[curDesc][1], 'impostor'));
        portrait.x = ((FlxG.width / 2) - (portrait.width / 2));
        frame.x = portrait.x - 55;
        dumnote.x = frame.x + 540;
    }
}