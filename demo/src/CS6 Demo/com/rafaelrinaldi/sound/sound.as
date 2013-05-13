package com.rafaelrinaldi.sound
{
	/**
	 * 
	 * <code>SoundManager</code> wrapper.
	 *
	 * @see SoundManager
	 *
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 1, 2011
	 *
	 */
	public function sound() : SoundManager
	{
		return instance;
	}
}

import com.rafaelrinaldi.sound.SoundManager;

/** Creating an internal instance. **/
internal var instance : SoundManager = new SoundManager;