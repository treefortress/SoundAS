package treefortress.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Controls playback of a single sound. Comes with convenience methods for all the common Sound APIs (pause, resume, set position, volume etc). This can be used in a modular fashion if all you need is a simple wrapper around the Sound class.
	 */
	public class SoundInstance {
		
		
		public var manager:SoundManager;
		
		/**
		 * Registered type for this Sound
		 */
		public var type:String;
		
		/**
		 * URL this sound was loaded from. This is null if the sound was not loaded by SoundAS
		 */
		public var url:String;
		
		/**
		 * Current instance of Sound object
		 */
		public var sound:Sound;
		
		/**
		 * Current playback channel
		 */
		public var channel:SoundChannel;
		
		/**
		 * Dispatched when playback has completed
		 */
		public var soundCompleted:Signal;
		
		/**
		 * Number of times to loop this sound. Pass -1 to loop forever.
		 */
		public var loops:int;
		
		/**
		 * Allow multiple concurrent instances of this Sound. If false, only one instance of this sound will ever play.
		 */
		public var allowMultiple:Boolean;
		
		/**
		 * Orphaned channels that are in the process of playing out. These will only exist when: allowMultiple = true
		 */
		public var oldChannels:Vector.<SoundChannel>;
		
		protected var _loopsRemaining:int;
		protected var _muted:Boolean;
		protected var _volume:Number;
		protected var _pan:Number;
		protected var _masterVolume:Number;
		protected var _enableSeamlessLoops:Boolean;
		protected var pauseTime:Number;
		protected var _isPlaying:Boolean;
		
		protected var _soundTransform:SoundTransform;
		internal var currentTween:SoundTween;
		
		
		
		public function SoundInstance(sound:Sound = null, type:String = null){
			this.sound = sound;
			this.type = type;
			manager = SoundAS;
			pauseTime = 0;
			_volume = 1;	
			_pan = 0;
			_masterVolume = 1
			_soundTransform = new SoundTransform();
			soundCompleted = new Signal(SoundInstance);
			oldChannels = new <SoundChannel>[];
		}
		
		/**
		 * When is is enabled, you will have seamless looping of your sound files (assuming they are encoded properly), but will experience issues when pausing/resuming them.
		 * The bug is detailed here: http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/. As a workaround, always stop your looping sounds and start over, do not try and resume. 
		 */
		public function get enableSeamlessLoops():Boolean {
			return _enableSeamlessLoops;
		}

		/**
		 * Play this Sound 
		 * @param volume
		 * @param startTime Start position in milliseconds
		 * @param loops Number of times to loop Sound. Pass -1 to loop forever.
		 * @param allowMultiple Allow multiple concurrent instances of this Sound
		 * @param allow seamless sound loops. Note that this will exhibit a bug when attempting to pause/resume the looping sound.
		 */
		public function play(volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = true, enableSeamlessLoops:Boolean = false):SoundInstance {
			this.loops = loops;
			_enableSeamlessLoops = enableSeamlessLoops;
			
			//If loops == -1, switch it to loop infinitely
			loops = (loops < 0)? int.MAX_VALUE : loops;
			_loopsRemaining = 0; 
			
			//When not using seamless looping, maintain an internal loopsRemaining counter, and loop manually on soudn complete.
			//This avoids a SoundAPI bug with pause/resume: http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/
			if(enableSeamlessLoops == false){
				_loopsRemaining = loops;
				loops = 0;
			}
			
			this.allowMultiple = allowMultiple;
			if(allowMultiple){
				//Store old channel, so we can still stop it if requested.
				if(channel){
					oldChannels.push(channel);
				}
				channel = sound.play(startTime, loops);
			} else {
				if(channel){ 
					stopChannel(channel);
				}
				channel = sound.play(startTime, loops);
			}
			if(channel){ 				
				channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				_isPlaying = true;
			}
			pauseTime = 0; //Always reset pause time on play
			
			this.volume = volume;	
			this.mute = mute;
			return this;
		}
		
		public function get fade():SoundTween {
			return currentTween;
		}
		
		/**
		 * Pause currently playing sound. Use resume() to continue playback. Pause / resume is supported for single sounds only.
		 */
		public function pause():SoundInstance {
			if(!channel){ return this; }
			_isPlaying = false;
			pauseTime = channel.position;
			stopChannel(channel);
			stopOldChannels();
			return this;
		}
		
		/**
		 * Resume from previously paused time. Optionally start over if it's not paused.
		 */
		public function resume(forceStart:Boolean = false):SoundInstance {
			if(isPaused || forceStart){
				play(_volume, pauseTime, loops, allowMultiple);
			} 
			return this;
		}
		
		/**
		 * Stop the currently playing sound and set it's position to 0
		 */
		public function stop():SoundInstance {
			pauseTime = 0;
			stopChannel(channel);
			channel = null;
			stopOldChannels();
			_isPlaying = false;
			return this;
		}
		
		/**
		 * Mute current sound.
		 */
		public function get mute():Boolean { return _muted; }
		public function set mute(value:Boolean):void {
			_muted = value;
			if(channel){
				channel.soundTransform = _muted? new SoundTransform(0) : soundTransform;
				updateOldChannels();
			}
		}
		
		/**
		 * Fade using the current volume as the Start Volume
		 */
		public function fadeTo(endVolume:Number, duration:Number = 1000, stopAtZero:Boolean = true):SoundInstance {
			currentTween = manager.addTween(type, -1, endVolume, duration, stopAtZero);
			return this;
		}
		
		/**
		 * Fade and specify both the Start Volume and End Volume.
		 */
		public function fadeFrom(startVolume:Number, endVolume:Number, duration:Number = 1000, stopAtZero:Boolean = true):SoundInstance {
			currentTween = manager.addTween(type, startVolume, endVolume, duration, stopAtZero);
			return this;
		}
		
		/**
		 * Indicates whether this sound is currently playing.
		 */
		public function get isPlaying():Boolean {
			return _isPlaying;
		}
		
		/**
		 * Combined masterVolume and volume levels
		 */
		public function get mixedVolume():Number {
			return _volume * _masterVolume;
		}
		
		/**
		 * Indicates whether this sound is currently paused.
		 */
		public function get isPaused():Boolean {
			return channel && sound && pauseTime > 0 && pauseTime < sound.length;
		}
		
		/**
		 * Set position of sound in milliseconds
		 */
		public function get position():Number { return channel? channel.position : 0; }
		public function set position(value:Number):void {
			if(channel){ 
				stopChannel(channel);
			}
			channel = sound.play(value, loops);
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		/**
		 * Value between 0 and 1. You can call this while muted to change volume, and it will not break the mute.
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			//Update the voume value, but respect the mute flag.
			if(value < 0){ value = 0; } else if(value > 1 || isNaN(volume)){ value = 1; }
			_volume = value;
			soundTransform.volume = mixedVolume;
			if(!_muted && channel){
				channel.soundTransform = soundTransform;
				updateOldChannels();
			}
		}
		
		/**
		 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right).
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void {
			//Update the voume value, but respect the mute flag.
			if(value < -1){ value = -1; } else if(value > 1 || isNaN(volume)){ value = 1; }
			_pan = soundTransform.pan = value;
			if(!_muted && channel){
				channel.soundTransform = soundTransform;
				updateOldChannels();
			}
		}
		
		/**
		 * Sets the master volume, which is multiplied with the current Volume level
		 */
		public function get masterVolume():Number { return _masterVolume; }
		public function set masterVolume(value:Number):void {
			if(_masterVolume == value){ return; }
			if(value < 0){ value = 0; } else if(value > 1){ value = 1; }
			_masterVolume = value;
			//Call setter to update the volume
			volume = _volume;
		}
		
		/**
		 * Create a duplicate of this SoundInstance
		 */
		public function clone():SoundInstance {
			var si:SoundInstance = new SoundInstance(sound, type);
			return si;
		}
		
		/**
		 * Unload sound from memory.
		 */
		public function destroy():void {
			soundCompleted.removeAll();
			try {
				sound.close();
			} catch(e:Error){}
			sound = null;
			_soundTransform = null;
			stopChannel(channel);
			channel = null;
			fade.end(false);
		}
		
		/**
		 * Dispatched when Sound has finished playback
		 */
		protected function onSoundComplete(event:Event):void {
			//trace("stop", ++stopCount);
			var channel:SoundChannel = event.target as SoundChannel;
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			//If it's the current channel, see if we should loop.
			if(channel == this.channel){ 
				this.channel = null;
				pauseTime = 0;
				//Loop manually?
				if(_enableSeamlessLoops == false){
					//loop forever?
					if(loops == -1){ 
						play(_volume, 0, -1, allowMultiple);
					} 
					//Loop set number of times?
					else if(_loopsRemaining--){
						play(_volume, 0, _loopsRemaining, allowMultiple);
					} else {
						_isPlaying = false;
						soundCompleted.dispatch(this);
					}
				} else {
					soundCompleted.dispatch(this);
				}
			}
			//Clear out any old channels...
			for(var i:int = oldChannels.length; i--;){
				if(channel.position == sound.length){
					stopChannel(channel);
					oldChannels.splice(i, 1);
				}
			}
		}
		
		/**
		 * Loops remaining, this will auto-decrement each time the sound loops. It will equal -1 when the sound is completed. 
		 * It will equal 0 if the sound is looping infinitely, or not looping at all.
		 */
		public function get loopsRemaining():int {
			return _loopsRemaining;
		}
		
		/**
		 * Stop the currently playing channel.
		 */
		protected function stopChannel(channel:SoundChannel):void {
			if(!channel){ return; }
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			try {
				channel.stop(); 
			} catch(e:Error){};
		}		
		
		/**
		 * Kill all orphaned channels
		 */
		protected function stopOldChannels():void {
			if(!oldChannels.length){ return; }
			for(var i:int = oldChannels.length; i--;){
				stopChannel(oldChannels[i]);
			}
			oldChannels.length = 0;
		}
		
		/**
		 * Keep orphaned channels in sync with current volume
		 */
		protected function updateOldChannels():void {
			if(!channel){ return; }
			for(var i:int = oldChannels.length; i--;){
				oldChannels[i].soundTransform = channel.soundTransform;	
			}
		}

		public function get soundTransform():SoundTransform {
			if(!_soundTransform){ _soundTransform = new SoundTransform(mixedVolume, _pan); }
			return _soundTransform;
		}
		
		public function set soundTransform(value:SoundTransform):void {
			if(value.volume > 0){ _muted = false; } 
			else if(value.volume == 0){ _muted = true; }
			channel.soundTransform = value;
			updateOldChannels();
		}
		
	}
}

