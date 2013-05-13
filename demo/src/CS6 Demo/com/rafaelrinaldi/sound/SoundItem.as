package com.rafaelrinaldi.sound
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * 
	 * <code>SoundManager</code> item.
	 * 
	 * @see SoundManager
	 * @see SoundControl
	 * 
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 9, 2011
	 *
	 */
	public class SoundItem extends SoundControl
	{
		/** Sound. **/
		public var sound : Sound;
		
		/** Channel. **/
		public var channel : SoundChannel;
		
		/** Loops. **/
		public var loops : int;
		
		/** Delay. **/
		public var delay : int;
		
		/** @private **/
		protected var timeout : int;
		
		/** Last position occurrence. **/
		public var lastPosition : Number;
		
		/** Stream URL. **/
		public var url : String;
		
		/** Available loading events. **/
		protected const LOADING_EVENTS : Array = [Event.COMPLETE, Event.ID3, IOErrorEvent.IO_ERROR, Event.OPEN, ProgressEvent.PROGRESS, SampleDataEvent.SAMPLE_DATA];
		
		/** Library with loading callbacks. **/
		protected var loadingCallbacks : Object;
		
		/** @param p_sound Sound instance. **/
		public function SoundItem( p_sound : Sound )
		{
			sound = p_sound;
			lastPosition = 0;
			loadingCallbacks = {};
		}
		
		/**
		 * Loads a sound stream.
		 * @param p_url Sound stream.
		 * @param p_context Loader context.
		 */
		public function load( p_url : String, p_context : SoundLoaderContext = null ) : SoundItem
		{
			try {
				
				if(channel != null) stop();
				
				// Removing all events.
				LOADING_EVENTS.forEach(function( p_type : String, ...rest ) : void {
					sound.removeEventListener(p_type, loadingEventHandler);
				});
				
				if(sound != null) sound.close();
				
			} catch( error : Error ) {
				// Nothing to close.
			}
			
			// New sound instance.
			sound = new Sound;
			
			// Adding all events.
			LOADING_EVENTS.forEach(function( p_type : String, ...rest ) : void {
				sound.addEventListener(p_type, loadingEventHandler);
			});
			
			sound.load(new URLRequest(url = p_url), p_context);
			
			return this;
		}

		/**
		 * Play list items.
		 * @param p_loops Loops. Use <strong>-1</strong> to loop forever (<strong>0</strong> by default).
		 * @param p_delay Delay (<strong>0</strong> by default).
		 */
		override public function play( p_loops : int = 0, p_delay : int = 0 ) : SoundControl
		{
			loops = p_loops == -1 ? int.MAX_VALUE : p_loops;
			delay = p_delay;
			
			cancel();
			
			timeout = setTimeout(playHandler, delay * 1000);
			
			return super.play();
		}

		/** Pause sound. **/
		override public function pause() : SoundControl
		{
			lastPosition = channel.position;
			
			channel.stop();
			
			return super.pause();
		}
		
		/** Stop sound. **/
		override public function stop() : SoundControl
		{
			lastPosition = 0;
			
			if(channel != null) channel.stop();
			
			return super.stop();
		}

		/** Cancel delay timeout. **/
		public function cancel() : SoundItem
		{
			clearTimeout(timeout);
			
			const callback : Function = controlCallbacks["cancel"];
			if(callback != null) callback.call();
						
			return this;
		}
		
		/**
		 * Fired when stream is loaded.
		 * @param p_callBack Callback to be fired.
		 */
		public function onLoad( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[Event.COMPLETE] = p_callBack;
			return this;
		}

		/**
		 * Fired when ID3 is received.
		 * @param p_callBack Callback to be fired.
		 */
		public function onID3( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[Event.ID3] = p_callBack;
			return this;
		}

		/**
		 * Fired when something goes wrong on loading the stream.
		 * @param p_callBack Callback to be fired.
		 */
		public function onIOError( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[IOErrorEvent.IO_ERROR] = p_callBack;
			return this;
		}

		/**
		 * Fired when stream is opened.
		 * @param p_callBack Callback to be fired.
		 */
		public function onOpen( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[Event.OPEN] = p_callBack;
			return this;
		}
		
		/**
		 * Fired when stream is being loaded.
		 * @param p_callBack Callback to be fired.
		 */
		public function onProgress( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[ProgressEvent.PROGRESS] = p_callBack;
			return this;
		}

		/**
		 * Fired when sample data is received.
		 * @param p_callBack Callback to be fired.
		 */
		public function onSampleData( p_callBack : Function ) : SoundItem
		{
			loadingCallbacks[SampleDataEvent.SAMPLE_DATA] = p_callBack;
			return this;
		}
		
		/** @return Sound length. **/
		public function get length() : Number
		{
			if(sound == null) return 0;
			return sound.length;
		}
		
		/** @return Sound position. **/
		public function get position() : Number
		{
			if(channel == null) return 0;
			return channel.position;
		}
		
		/** Seek to position value. **/
		public function set position( value : Number ) : void
		{
			stop();
			lastPosition = value;
			play();
		}
		
		/** @return Position progress percentage. **/
		public function get positionPercent() : Number
		{
			return position / length;
		}
		
		/** Seek to position percentage. **/
		public function set positionPercent( value : Number ) : void
		{
			position = length * value;
		}
		
		/** @return Sound volume. **/
		override public function get volume() : Number
		{
			if(channel == null) return 0;
			return channel.soundTransform.volume;
		}

		/** Sound volume setter. **/
		override public function set volume( value : Number ) : void
		{
			if(channel == null) return;
			channel.soundTransform = new SoundTransform(value, pan);
		}
		
		/** @return Sound pan. **/
		override public function get pan() : Number
		{
			if(channel == null) return 0;
			return channel.soundTransform.pan;
		}
		
		/** Sound pan setter. **/
		override public function set pan( value : Number ) : void
		{
			if(channel == null) return;
			channel.soundTransform = new SoundTransform(volume, value);
		}

		/**
		 * Handle all loading events.
		 * @private
		 */
		protected function loadingEventHandler( event : Event ) : void
		{
			//trace('loadingEventHandler', event.type)
			const callback : Function = loadingCallbacks[event.type];
			if(callback != null) callback.apply(this, [event]);
		}

		/** @private **/
		protected function playHandler() : void
		{
			var callback : Function;
			
			try {
				
				channel = sound.play(lastPosition, loops);
				channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				
				callback = controlCallbacks["play"];
				if(callback != null) callback.call();
				
			} catch( error : Error ) {
				
				trace("[SoundItem] There was a problem playing", this);
				
				callback = controlCallbacks[ErrorEvent.ERROR];
				if(callback != null) callback.apply(this, [error]);
				
			}
		}

		/**
		 * Handle <code>Event.SOUND_COMPLETE</code>.
		 * @private
		 */
		protected function soundCompleteHandler( event : Event ) : void
		{
			isPlaying = false;
			lastPosition = 0;
			
			const callback : Function = controlCallbacks[Event.SOUND_COMPLETE];
			if(callback != null) callback.apply(this, [event]);
		}

		/** Clear from memory. **/
		override public function dispose() : void
		{
			cancel();
			
			loadingCallbacks = null;
			
			if(channel != null) {
				channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				channel.stop();
				channel = null;
			}
			
			if(sound != null) {
				
				try {
					sound.close();
				} catch( error : Error ) {
					// Problem when closing.
				}
				
				sound = null;
				
			}
			
			super.dispose();
		}

	}
}
