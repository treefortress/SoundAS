package
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import treefortress.sound.SoundAS;
	import treefortress.sound.SoundInstance;
	import treefortress.sound.SoundManager;
	
	public class SoundAS_Demo extends Sprite
	{
		public static var CLICK:String = "click";
		public static var MUSIC:String = "music";
		public static var SOLO1:String = "solo1";
		public static var SOLO2:String = "solo2";
		
		public function SoundAS_Demo(){
			
			SoundAS.loadSound("Loop.mp3", "loop");
			SoundAS.loadSound("Click.mp3", CLICK);
			SoundAS.loadSound("Music.mp3", MUSIC, 100);
			SoundAS.loadSound("Solo1.mp3", SOLO1, 100);
			SoundAS.loadSound("Solo2.mp3", SOLO2, 100);
			
			//SoundAS.playLoop("loop", 1, 10000);
			
			stage.addEventListener(MouseEvent.CLICK, function(){
				var click:SoundInstance = SoundAS.playFx(CLICK);
				trace("Click.oldChannels.length = " + click.oldChannels.length);
			});
			
			stage.addEventListener(KeyboardEvent.KEY_UP, function(event:KeyboardEvent){
				var volume:Number = 1;
				switch(event.keyCode){
					
					case Keyboard.NUMBER_1:
						
						trace("Testing PLAY: Play / Stop / PlayMultiple / StopMultiple");
						SoundAS.playLoop(MUSIC, volume);
						trace("play");
						setTimeout(function(){
							SoundAS.getSound(MUSIC).stop();
							trace("stop");
							trace("isPlaying:", SoundAS.getSound(MUSIC).isPlaying);
						}, 3000);
						setTimeout(function(){
							trace("playMultiple");
							SoundAS.playFx(SOLO1, volume)
							SoundAS.playFx(SOLO2, volume);
						}, 4000);
						setTimeout(function(){
							trace("stopAll");
							SoundAS.stopAll();
						}, 5500);
						break;
					
					case Keyboard.NUMBER_2:
						trace("PAUSE: Pause / Resume, PauseAll / ResumeAll");
						SoundAS.playFx(MUSIC, volume, 68000);
						
						setTimeout(function(){
							SoundAS.pause(MUSIC);
							trace("pause");
						}, 3000);
						
						setTimeout(function(){
							SoundAS.resume(MUSIC).soundCompleted.addOnce(function(si:SoundInstance):void {
								SoundAS.playFx(SOLO1, volume);
								SoundAS.playFx(SOLO2, volume);
								
								setTimeout(function(){
									SoundAS.pauseAll();
									trace("pauseAll");
								}, 1000);
								
								setTimeout(function(){
									SoundAS.resumeAll();
									trace("resumeAll");
								}, 2000);
							});
							trace("resume");
						}, 3500);
						
						
						break;
					
					case Keyboard.NUMBER_3:
						trace("FADES: fade, fadeMultiple, fadeMaster");
						SoundAS.playLoop(MUSIC, volume);
						SoundAS.fadeFrom(MUSIC, 0, 1);
						trace("fadeIn");
						setTimeout(function(){
							SoundAS.getSound(MUSIC).volume = .2;
							SoundAS.fadeTo(MUSIC, 0);
							trace("fadeOut");
						}, 3000);
						
						setTimeout(function(){
							SoundAS.playLoop(MUSIC, volume);
							SoundAS.playFx(SOLO1, volume);
							SoundAS.playFx(SOLO2, volume);
							SoundAS.fadeAllFrom(0, 1, 500);
							trace("fadeAllFrom");
						}, 4000);
						
						setTimeout(function(){
							SoundAS.fadeAllTo(0, 1000);
							trace("fadeAllTo");
						}, 5000);
						
						setTimeout(function(){
							SoundAS.play(MUSIC);
							SoundAS.fadeMasterFrom(0, 1);
							trace("fadeMasterFrom");
						}, 6500);
						
						setTimeout(function(){
							SoundAS.fadeMasterTo(0);
							trace("fadeMasterTo");
						}, 7500);
						
						setTimeout(function(){
							SoundAS.masterVolume = 1;
							SoundAS.stopAll();
						}, 9000);
						
						break;
					
					case Keyboard.NUMBER_4:
						trace("MULITPLE CHANNELS: play 3 music + 1 solo loop, muteAll, unmuteAll, 20% volumeAll, stopAll");
						SoundAS.playFx(MUSIC, .5);
						SoundAS.playFx(MUSIC, .5, 2000);
						SoundAS.playFx(MUSIC, .5, 4000);
						SoundAS.playLoop(SOLO1);
						
						setTimeout(function(){
							trace("mute");
							SoundAS.mute = true;
						}, 2000);
						//return;
						
						setTimeout(function(){
							trace("un-mute");
							SoundAS.mute = false;
						}, 3000);
						
						setTimeout(function(){
							trace("volume=.2");
							SoundAS.volume = .2;
						}, 4000);
						
						setTimeout(function(){
							trace("stopAll");
							SoundAS.stopAll();
						}, 6000);
						
						break;
					
					case Keyboard.NUMBER_5:
						trace("LOOPING: Loop solo 2 times, pause halfway each time. Shows workaround for the 'loop bug': http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/ ");
						var solo:SoundInstance = SoundAS.play(SOLO1, volume, 0, 0);
						var loopCount:int = 0;
						solo.soundCompleted.add(playPause);
						playPause(solo);
						
						function playPause(si:SoundInstance):void {
							if(++loopCount == 3){ 
								trace("INFINITE LOOP: 5 seconds of repeating Clicks");
								var startTime:int = getTimer();
								var click:SoundInstance = SoundAS.play(CLICK, 1, 0, -1, false, false, true);
								setTimeout(function(){
									trace("stop Clicks");
									click.stop();
									click.soundCompleted.removeAll();
									solo.soundCompleted.removeAll();
								}, 5000);
							} 
							else {
								SoundAS.play(SOLO1, volume, 0, 0);
								setTimeout(function(){
									solo.pause();
									trace("pause");
								}, 500);
								setTimeout(function(){
									solo.resume();
									trace("resume");
								}, 1000);
							}
						}
						break;
					
					case Keyboard.NUMBER_6:
						trace("GROUPS: MUSIC and SOLOS. Pause solos. Resume solos. FadeOut music, FadeIn music. Set volume music. Mute solos. unMute solos. ");
						
						var music:SoundManager = SoundAS.group("music");
						var solos:SoundManager = SoundAS.group("solos");
						
						music.loadSound("Music.mp3", MUSIC);
						
						solos.loadSound("Solo1.mp3", SOLO1);
						solos.loadSound("Solo2.mp3", SOLO2);
						
						music.playLoop(MUSIC);
						
						solos.playLoop(SOLO1);
						solos.playLoop(SOLO2);
						
						setTimeout(function(){
							trace("pause solos");
							solos.pauseAll();
						}, 1000);
						
						setTimeout(function(){
							trace("resume solos");
							solos.resumeAll();
						}, 2000);
						
						setTimeout(function(){
							trace("fadeOut Music");
							music.fadeAllTo(0);
						}, 2500);
						
						setTimeout(function(){
							trace("fadeIn Music");
							music.fadeAllTo(1, 350);
						}, 4000);
						
						setTimeout(function(){
							trace("Music Volume = .2");
							music.volume = .2;
						}, 5000);
						
						setTimeout(function(){
							trace("Mute Solos");
							solos.mute = true;
						}, 6000);
						
						setTimeout(function(){
							trace("Unmute Solos");
							solos.mute = false;
						}, 7000);
						
						setTimeout(function(){
							trace("STOP ALL!");
							for(var i:int = SoundAS.groups.length; i--;){
								SoundAS.groups[i].stopAll();
							}
						}, 9000);
						
						break;
					
					case Keyboard.NUMBER_8:
						trace("isPlaying / isPaused");
						
						SoundAS.play(SOLO2, 1);
						var intervalId:int = setInterval(function(){
							trace(SoundAS.getSound(SOLO2).isPlaying);
						}, 20);
						
						setTimeout(function(){
							SoundAS.getSound(SOLO2).pause();
						}, 1000);
						
						setTimeout(function(){
							SoundAS.getSound(SOLO2).resume();
						}, 2000);
						
						setTimeout(function(){
							SoundAS.play(SOLO2, 1);
							SoundAS.fadeTo(SOLO2, 0, 1000).fade.stopAtZero = true;
						}, 4000);
						
						setTimeout(function(){
							clearInterval(intervalId);
						}, 6000);
						return;
						
				}
				
			});
			
		}
	}
}