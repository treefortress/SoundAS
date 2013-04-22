package
{
	import flash.display.Sprite;
	
	import treefortress.sound.SoundAS;
	
	public class SoundAS_Demo extends Sprite
	{
		public function SoundAS_Demo(){
			
			SoundAS.loadSound("Click.mp3", "Click");
			SoundAS.loadSound("Music.mp3", "music");
			
			
			SoundAS.play("music");
			
			
		}
	}
}