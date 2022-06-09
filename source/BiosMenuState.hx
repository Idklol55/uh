package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class BiosMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1-git'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	private var bioText:FlxText;
	private var charName:FlxText;
	
	var chars:Array<String> = [
		'silver',
		'dark',
		'terios',
		'sonai'
	];
	private var bios:Array<String> = [];
	private var charSprites:Map<String, FlxSprite> = [];
	private var portSprites:Map<String, FlxSprite> = [];
	private var textScroll1:FlxBackdrop = new FlxBackdrop(Paths.image('bios/text'), 1, 1, true, false, 50);
	private var textScroll2:FlxBackdrop = new FlxBackdrop(Paths.image('bios/text'), 1, 1, true, false, 50);

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Bios Menu", null);
		#end
		persistentUpdate = true;
		
		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('bios/bg'));
		bg.scrollFactor.set(0, 0);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		textScroll1.alpha = 0.5;
		textScroll2.alpha = 0.3;
		
		textScroll1.screenCenter();
		textScroll2.screenCenter();
		textScroll1.y += 30;
		textScroll2.y -= 30;
		
		add(textScroll1);
		textScroll2.scale.set(0.7, 0.7);
		add(textScroll2);
		
		// magenta.scrollFactor.set();
		
		var uiShadow:FlxSprite = new FlxSprite(725.05, 209).loadGraphic(Paths.image('bios/hover'));
		uiShadow.setGraphicSize(554);
		uiShadow.updateHitbox();
		uiShadow.scrollFactor.set();
		add(uiShadow);
		
		var plate:FlxSprite = new FlxSprite(237.05, 535.05).loadGraphic(Paths.image('bios/plate'));
		plate.setGraphicSize(812);
		plate.updateHitbox();
		plate.scrollFactor.set();
		plate.antialiasing = ClientPrefs.globalAntialiasing;
		add(plate);
		
		var chalkboard:FlxSprite = new FlxSprite(78, 96.05).loadGraphic(Paths.image('bios/chalkboard'));
		chalkboard.setGraphicSize(562);
		chalkboard.updateHitbox();
		chalkboard.scrollFactor.set();
		chalkboard.antialiasing = ClientPrefs.globalAntialiasing;
		add(chalkboard);
		
		charName = new FlxText(0, 0, 0, "TERIOS", 36);
		charName.setFormat("NiseSegaSonic", 60, FlxColor.WHITE);
		charName.screenCenter();
		charName.y -= 320;
		charName.x -= 120;
		charName.borderStyle = OUTLINE;
		charName.borderColor = FlxColor.BLACK;
		charName.borderSize = 3;
		charName.antialiasing = ClientPrefs.globalAntialiasing;
		charName.scrollFactor.set();
		add(charName);
		
		for (i in 0...chars.length)
		{
			var charSpr:FlxSprite = new FlxSprite();
			charSpr.frames = Paths.getSparrowAtlas('bios/menu_chars');
			var frameIndices:Array<Int> = CoolUtil.numberArray(13, 0);
			for (i in 0...5)
			{
				frameIndices.push(12);
				frameIndices.push(13);
				trace(frameIndices);
			}
			charSpr.animation.addByIndices(chars[i], chars[i], frameIndices, "", 24, false);
			charSpr.animation.play(chars[i], true);
			switch (chars[i])
			{
				case 'silver':
					bios[i] = "Voiced by Luckiibean\n\nSonic's first robotic doppelganger created by Dr.Eggman.\n\nThis guy has made an appearance in:\nSonic 2 8-BIT, Sonic Mania and both the Archie and IDW comics.";
					charSpr.setGraphicSize(208);
					charSpr.setPosition(880.85, 209);
				case 'dark':
					bios[i] = "Voiced by Snap\nOne of Sonic's many super forms,\nmanifested from his anger & the energy from counterfeit Chaos Emeralds\nAlthough, he only appeared once in\nSonic X in The Season 3 Episode: Testing Time.";
					charSpr.setGraphicSize(273);
					charSpr.setPosition(847.35, 83.45);
				case 'terios':
					bios[i] = "Voiced by Begwhi\nA character based on one of Shadow's original character designs for:\nSonic Adventure 2\n\nGiven the name Terios (or Umbra) by the community.";
					charSpr.setGraphicSize(283);
					charSpr.setPosition(867, 122.4);
				case 'sonai':
					bios[i] = "This is Simply EJ's EXE take on the blue blur. \n\nIn summary, its an AI that was meant to assist in making Sonic 2 that was\nreactivated in a corrupted copy of the game,\nyears after it's released causing it to be corrupted itself.";
					charSpr.setGraphicSize(305);
					charSpr.setPosition(855.6, 107.5);
			}
			charSpr.updateHitbox();
			charSpr.scrollFactor.set();
			charSpr.ID = i;
			charSprites[chars[i]] = charSpr;
			add(charSpr);
			
			var portrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bios/portrait-' + chars[i]));
			portrait.setGraphicSize(296);
			switch (chars[i])
			{
				case 'silver':
					portrait.setPosition(234, 132);
				default:
					portrait.setPosition(234, 128);
			}
			portrait.updateHitbox();
			portrait.scrollFactor.set();
			portrait.ID = i;
			portSprites[chars[i]] = portrait;
			add(portrait);
		}
		
		bioText = new FlxText(0, 0, 0, "Dark Sonic\rVoiced by Snap\rOne of Sonic's many super forms,\rachieved from his anger and the energy from counterfeit Chaos Emeralds \rAlthough, this only appeared once in Sonic X Season 3 Episode 67 Testing Time.", 12);
		bioText.setFormat("PhantomMuff 1.5", 16, FlxColor.WHITE, CENTER);
		bioText.scrollFactor.set();
		bioText.fieldWidth = -5;
		bioText.wordWrap = false;
		bioText.autoSize = false;
		bioText.setPosition(plate.getMidpoint().x - 325, plate.getMidpoint().y - 60);
		add(bioText);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		textScroll1.x -= 4;
		textScroll2.x -= 2;
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
			
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}
	
	override function beatHit()
	{
		super.beatHit();

		if (charSprites[chars[curSelected]] != null && curBeat % 2 == 0)
			charSprites[chars[curSelected]].animation.play(chars[curSelected], true);
	}


	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		if (curSelected >= chars.length) //revert back to without - 1
			curSelected = 0;
		if (curSelected < 0)
			curSelected = chars.length - 1; //revert back to - 1
		
		for (sprite in charSprites)
		{
			if (sprite.ID == curSelected)
			{
				sprite.animation.play(chars[curSelected], true);
				sprite.visible = true;
			}
			else
				sprite.visible = false;
		}
		
		for (sprite in portSprites)
		{
			if (sprite.ID == curSelected)
				sprite.visible = true;
			else
				sprite.visible = false;
		}
		
		bioText.text = bios[curSelected];
		if (chars[curSelected] != 'dark')
			charName.text = chars[curSelected].toUpperCase();
		else
			charName.text = chars[curSelected].toUpperCase() + ' SONIC';
		switch (chars[curSelected])
		{
			case "dark":
				charName.offset.x = 0;
			case "silver" | "terios":
				charName.offset.x = -80;
			default:
				charName.offset.x = -100;
		}
	}
}
