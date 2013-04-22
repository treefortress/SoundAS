package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import treefortress.sound.SoundAS;
	
	public class SoundAS_Demo extends Sprite
	{
		public function SoundAS_Demo(){
			
			SoundAS.loadSound("Click.mp3", "click");
			SoundAS.loadSound("Music.mp3", "music");
			
			SoundAS.playLoop("music");
			
			/*
			//Test Pause / Resume
			setTimeout(function(){
				SoundAS.pauseAll();
				setTimeout(function(){
					SoundAS.resumeAll();
				}, 2000);
			}, 2000);
			*/
			//Test Fade
			setTimeout(function(){
				SoundAS.fadeTo("music", 0);
				//SoundAS.fadeAllTo(0);
				setTimeout(function(){
					//SoundAS.fadeAllFrom(1, 0);
					SoundAS.fadeFrom("music", 0, 1);
				}, 2000);
			}, 2000);
			
			
			stage.addEventListener(MouseEvent.CLICK, function(){
				//SoundAS.playLoop("click", SoundAS.getSound("click").volume);
				SoundAS.play("click", 1, 0, -1, true, true);
			});
			
			
		}
	}
}