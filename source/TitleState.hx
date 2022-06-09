package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{
	
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var whiteScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var titleBG:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;
	
	var titleJSON:TitleData;
	
	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();
		
		//trace(path, FileSystem.exists(path));
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/
		
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}
			
			http.onError = function (error) {
				trace('error: $error');
			}
			
			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		if(!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			//trace('LOADED FULLSCREEN SETTING!!');
		}
		
		ClientPrefs.loadPrefs();
		
		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		
		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'Logo Bop', 24, false);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.4));
		logoBl.updateHitbox();
		logoBl.screenCenter(X);
		logoBl.x -= 25;
		// logoBl.color = FlxColor.BLACK;

		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else
		
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.setGraphicSize(Std.int(titleText.width * 0.6));
		//titleText.screenCenter(X);
		titleText.updateHitbox();
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
		
		titleBG = new FlxSprite(-80).loadGraphic(Paths.image('titleBG2'));
		titleBG.setGraphicSize(Std.int(titleBG.width * 1.175));
		titleBG.updateHitbox();
		titleBG.screenCenter(X);
		titleBG.antialiasing = ClientPrefs.globalAntialiasing;
		titleBG.visible = true;
		add(titleBG);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55ff0000, 0xAAff0000], 1, 90, true);
		gradientBar.y = 1000;
		gradientBar.scale.y = 0;
		gradientBar.updateHitbox();
		add(gradientBar);
		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;
		
		whiteScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteScreen.alpha = 0;
		add(whiteScreen);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			else if(easterEggEnabled)
			{
				var finalKey:FlxKey = FlxG.keys.firstJustPressed();
				if(finalKey != FlxKey.NONE) {
					lastKeysPressed.push(finalKey); //Convert int to FlxKey
					if(lastKeysPressed.length > easterEggKeyCombination.length)
					{
						lastKeysPressed.shift();
					}
					
					if(lastKeysPressed.length == easterEggKeyCombination.length)
					{
						var isDifferent:Bool = false;
						for (i in 0...lastKeysPressed.length) {
							if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
								isDifferent = true;
								break;
							}
						}

						/*if(!isDifferent) {
							trace('Easter egg triggered!');
							FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
							FlxG.sound.play(Paths.sound('secretSound'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							lastKeysPressed = [];
							closedState = true;
							transitioning = true;
						}*/
					}
				}
			}
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) 
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					credTextShit.visible = true;
					addMoreText('simplyej');
					addMoreText('freshwoomy');
				case 2:
					#if PSYCH_WATERMARKS
					addMoreText('luckiibean');
					#else
					#end
				case 3:
					#if PSYCH_WATERMARKS
					addMoreText('dj awesome');
					#else
					#end
				case 4:
					deleteCoolText();

					addMoreText('snap', 15);
				case 5:
					addMoreText('begwhi', 15);
				case 6:
					addMoreText('ratsots', 15);
				case 7:
					addMoreText('two-story', 15);
				case 8:
					deleteCoolText();

					addMoreText('cold_vee', 15);
				case 9:
					addMoreText('sentiack', 15);
				case 10:
					addMoreText('sugarratio', 15);
				case 11:
					addMoreText('kiwiquest', 15);
				case 12:
					deleteCoolText();
	
					addMoreText('spiketherapperDA', 15);
					addMoreText('Comgaming_Nz', 15);
				case 13:
					deleteCoolText();
				
					addMoreText('Zavemann', 15);
					addMoreText('rotty eyes', 15);
				case 14:
					deleteCoolText();
					addMoreText('and', 15);
					addMoreText('rileyverse', 15);
					addMoreText('ethanthedoodler', 15);
				case 15:
					addMoreText('present', 15);
				case 16:
					FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(gradientBar, {y: 700}, 2.3, {ease: FlxEase.expoInOut, startDelay: 0});
					gradientBar.updateHitbox();
					gradientBar.y = FlxG.height - gradientBar.height;
					deleteCoolText();
					addMoreText('Psych Engine by', 15);
					
				case 18:
					addMoreText('Shadow Mario',30);
					addMoreText('RiverOaken',30);
					addMoreText('shub',30);
				case 19:
					deleteCoolText();
				case 20:
					createCoolText(['Not associated', 'with'], -40);
				case 22:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 23:
					deleteCoolText();
					ngSpr.visible = false;
				case 24:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 26:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 27:
					deleteCoolText();
				case 28:
					addMoreText('Super');
				// credTextShit.visible = true;
				case 29:
					addMoreText('Sonic');
				// credTextShit.text += '\nNight';
				case 30:
					addMoreText('Smackdown'); // credTextShit.text += '\nFunkin';
					FlxTween.tween(whiteScreen, {alpha: 100}, 1, {ease: FlxEase.expoInOut, startDelay: 0});
				case 32:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			titleBG.visible = false;
			whiteScreen.visible = false;
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			gradientBar.visible = false;
			skippedIntro = true;
		}
	}
}
