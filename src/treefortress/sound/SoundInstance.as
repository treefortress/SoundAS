package treefortress.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osflash.signals.Signal;

	public class SoundInstance {
		
		
		/**
		 * Registered type for this Sound
		 */
		public var type:String;
		
		/**
		 * URL this sound was loaded from. This is null if the sound was not loaded externally.
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
		
		protected var soundTransform:SoundTransform;
		protected var _muted:Boolean;
		protected var _volume:Number;
		protected var pauseTime:Number;
		protected var _position:int;
		
		public function SoundInstance(sound:Sound = null){
			pauseTime = 0;
			_volume = 1;
			
			this.sound = sound;
			
			soundCompleted = new Signal(SoundInstance);
			soundTransform = new SoundTransform();
		}
		
		/**
		 * Play this Sound 
		 * @param volume
		 * @param startTime Start position in milliseconds
		 * @param loops Number of times to loop Sound. Pass -1 to loop forever.
		 * @param allowMultiple Allow multiple concurrent instances of this Sound
		 */
		public function play(volume:Number = 1, startTime:int = -1, loops:int = 0, allowMultiple:Boolean = true):void {
			
			this.loops = loops;
			this.allowMultiple = allowMultiple;
			if(allowMultiple){
				channel = sound.play(startTime, loops);
			} else {
				if(channel){ 
					pauseTime = channel.position;
					stopChannel(channel);
				}
 				channel = sound.play(startTime, loops);
			}
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			this.volume = volume;	
			this.mute = mute;
		}
		
		/**
		 * Pause currently playing sound. Use resume() to continue playback.
		 */
		public function pause():void {
			pauseTime = channel.position;
			channel.stop();
		}

		
		/**
		 * Resume from previously paused time, or start over if it's not playing.
		 */
		public function resume():void {
			play(_volume, pauseTime, loops, allowMultiple);
		}
		
		/**
		 * Stop the currently playing sound and set it's position to 0
		 */
		public function stop():void {
			pauseTime = 0;
			channel.stop();
		}
		
		/**
		 * Mute current sound.
		 */
		public function get mute():Boolean { return _muted; }
		public function set mute(value:Boolean):void {
			_muted = value;
			if(channel){
				channel.soundTransform = _muted? new SoundTransform(0) : soundTransform;
			}
		}
		
		/**
		 * Fade using the current volume as the Start Volume
		 */
		public function fadeTo(endVolume:Number, duration:Number = 1000):void {
			SoundAS.addTween(type, -1, endVolume, duration);
		}
		
		/**
		 * Fade and specify both the Start Volume and End Volume.
		 */
		public function fadeFrom(startVolume:Number, endVolume:Number, duration:Number = 1000):void {
			SoundAS.addTween(type, startVolume, endVolume, duration);
		}
		
		/**
		 * Indicates whether this sound is currently playing.
		 */
		public function get isPlaying():Boolean {
			return (channel && channel.position > 0);
		}
		
		/**
		 * Set position of sound in milliseconds
		 */
		public function get position():int { return channel? channel.position : 0; }
		public function set position(value:int):void {
			if(channel){ 
				stopChannel(channel);
			}
			channel = sound.play(value, loops);
		}
		

		/**
		 * Adjust volume for this sound. You can call this while muted to change volume, and it will not break the mute.
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			if(_muted){ return; }
			
			if(value < 0){ value = 0; } else if(value > 1){ value = 1; }
			if(!soundTransform){ soundTransform = new SoundTransform(); }
			soundTransform.volume = value;
			channel.soundTransform = soundTransform;
		}
		
		/**
		 * Create a duplicate of this SoundInstance
		 */
		public function clone():SoundInstance {
			var si:SoundInstance = new SoundInstance(sound);
			return si;
		}

		
		/**
		 * Dispatched when Sound has finished playback
		 */
		protected function onSoundComplete(event:Event):void {
			soundCompleted.dispatch(this);
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
			channel = null;
			soundTransform = null;
		}
		
		protected function stopChannel(channel:SoundChannel):void {
			channel.stop(); 
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}		
		
	}
}