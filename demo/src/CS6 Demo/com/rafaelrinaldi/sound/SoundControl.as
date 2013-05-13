package com.rafaelrinaldi.sound
{
	import com.rafaelrinaldi.abstract.IDisposable;

	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * 
	 * Available sound controls.
	 *
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 1, 2011
	 *
	 */
	public class SoundControl implements IDisposable
	{
		/** Sound volume before is muted. **/	
		protected var originalVolume : Number;
		
		/** Is sound playing? **/
		public var isPlaying : Boolean;
		
		/** Library with control callbacks. **/
		protected var controlCallbacks : Object;

		public function SoundControl()
		{
			controlCallbacks = {};
		}
		
		/**
		 * Play list items.
		 * @param p_loops Loops. Use <strong>-1</strong> to loop forever (<strong>0</strong> by default).
		 * @param p_delay Delay (<strong>0</strong> by default).
		 */
		public function play( p_loops : int = 0, p_delay : int = 0 ) : SoundControl
		{
			isPlaying = true;
			
			const callback : Function = controlCallbacks["play"];
			if(callback != null) callback.call();
			
			return this;
		}
		
		/** Pause sound. **/
		public function pause() : SoundControl
		{
			isPlaying = false;
			
			const callback : Function = controlCallbacks["pause"];
			if(callback != null) callback.call();
			
			return this;
		}

		/** Stop sound. **/
		public function stop() : SoundControl
		{
			isPlaying = false;
			
			const callback : Function = controlCallbacks["stop"];
			if(callback != null) callback.call();
			
			return this;
		}

		/** Mute sound. **/
		public function mute() : SoundControl
		{
			originalVolume = volume;
			volume = 0;
			
			const callback : Function = controlCallbacks["mute"];
			if(callback != null) callback.call();
			
			return this;
		}
		
		/** Unmute sound. **/
		public function unmute() : SoundControl
		{
			volume = originalVolume || 1;
			
			const callback : Function = controlCallbacks["unmute"];
			if(callback != null) callback.call();
			
			return this;
		}

		/** Toggle mute/unmute sound. **/
		public function toggleMute() : void
		{
			if(volume == 0)
				unmute();
			else
				mute();
		}

		/** Toggle play/pause controls. **/
		public function togglePlay() : void
		{
			if(isPlaying)
				pause();
			else
				play();
		}

		/**
		 * Fired when sound is started.
		 * @param p_callBack Callback to be fired.
		 */
		public function onPlay( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["play"] = p_callBack;
			return this;
		}

		/**
		 * Fired when sound is paused.
		 * @param p_callBack Callback to be fired.
		 */
		public function onPause( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["pause"] = p_callBack;
			return this;
		}

		/**
		 * Fired when sound is stopped.
		 * @param p_callBack Callback to be fired.
		 */
		public function onStop( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["stop"] = p_callBack;
			return this;
		}

		/**
		 * Fired when delay timeout is canceled.
		 * @param p_callBack Callback to be fired.
		 */
		public function onCancel( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["cancel"] = p_callBack;
			return this;
		}

		/**
		 * Fired when sound is muted.
		 * @param p_callBack Callback to be fired.
		 */
		public function onMute( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["mute"] = p_callBack;
			return this;
		}

		/**
		 * Fired when sound is unmuted.
		 * @param p_callBack Callback to be fired.
		 */
		public function onUnMute( p_callBack : Function ) : SoundControl
		{
			controlCallbacks["unmute"] = p_callBack;
			return this;
		}

		/**
		 * Fired when sound is completed.
		 * @param p_callBack Callback to be fired.
		 */
		public function onComplete( p_callBack : Function ) : SoundControl
		{
			controlCallbacks[Event.SOUND_COMPLETE] = p_callBack;
			return this;
		}

		/**
		 * Fired when something goes wrong with the sound.
		 * @param p_callBack Callback to be fired.
		 */
		public function onError( p_callBack : Function ) : SoundControl
		{
			controlCallbacks[ErrorEvent.ERROR] = p_callBack;
			return this;
		}

		/** Volume getter. **/
		public function get volume() : Number
		{
			return 0;
		}
		
		/** Volume setter. **/
		public function set volume( value : Number ) : void
		{
		}
		
		/** Pan getter. **/
		public function get pan() : Number
		{
			return 0;
		}
		
		/** Pan setter. **/
		public function set pan( value : Number ) : void
		{
		}

		/** Clear from memory. **/
		public function dispose() : void
		{
			controlCallbacks = null;
		}

	}
}