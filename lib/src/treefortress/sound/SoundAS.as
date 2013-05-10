package treefortress.sound
{
	public function get SoundAS() : SoundManager { 
		return instance; 
	}
}
import treefortress.sound.SoundManager;

internal var instance:SoundManager = new SoundManager();


