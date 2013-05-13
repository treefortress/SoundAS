package com.rafaelrinaldi.sound
{
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;

	/**
	 * 
	 * Controls for the global sound aka <code>SoundMixer</code>.
	 *
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 9, 2011
	 *
	 */
	public class SoundGlobal extends SoundControl
	{
		/** Stop all sounds. **/
		override public function stop() : SoundControl
		{
			SoundMixer.stopAll();
			
			return super.stop();
		}
		
		/** @return Current volume. **/
		override public function get volume() : Number
		{
			return SoundMixer.soundTransform.volume;
		}
		
		/** Current volume setter. **/
		override public function set volume( value : Number ) : void
		{
			SoundMixer.soundTransform = new SoundTransform(value, pan);
		}
		
		/** @return Current pan. **/
		override public function get pan() : Number
		{
			return SoundMixer.soundTransform.pan;
		}
		
		/** Current pan setter. **/
		override public function set pan( value : Number ) : void
		{
			SoundMixer.soundTransform = new SoundTransform(volume, value);
		}

	}
}