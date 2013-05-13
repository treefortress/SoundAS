

package treefortress.sound
{
	/** Provides a convenience instance of SoundManager to be used globally **/
	public function SoundAS() : SoundManager { 
		return instance; 
	}
}
import treefortress.sound.SoundManager;

internal var instance:SoundManager = new SoundManager();


