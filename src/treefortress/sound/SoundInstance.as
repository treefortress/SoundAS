package treefortress.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osflash.signals.Signal;

	public class SoundInstance {
		
		
		public var type:String;
		public var url:String;
		public var sound:Sound;
		public var channel:SoundChannel;
		public var soundCompleted:Signal;
		public var soundTransform:SoundTransform;
		
		public var loops:int;
		public var allowMultiple:Boolean;
		
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
		
		protected function onSoundComplete(event:Event):void {
			soundCompleted.dispatch(this);
		}
		
		public function resume():void {
			play(_volume, pauseTime, loops, allowMultiple);
		}
		
		public function stop():void {
			pauseTime = 0;
			channel.stop();
		}
		
		public function pause():void {
			pauseTime = channel.position;
			channel.stop();
		}

		public function get mute():Boolean {
			return _muted;
		}

		public function set mute(value:Boolean):void {
			_muted = value;
			if(channel){
				channel.soundTransform = _muted? new SoundTransform(0) : soundTransform;
			}
		}
		
		public function fadeTo(endVolume:Number, duration:Number = 1000):void {
			SoundAS.addTween(type, -1, endVolume, duration);
		}
		
		public function fadeFrom(startVolume:Number, endVolume:Number, duration:Number = 1000):void {
			SoundAS.addTween(type, startVolume, endVolume, duration);
		}
		
		public function get isPlaying():Boolean {
			return (channel && channel.position > 0);
		}

		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			if(_muted){ return; }
			
			if(value < 0){ value = 0; } else if(value > 1){ value = 1; }
			if(!soundTransform){ soundTransform = new SoundTransform(); }
			soundTransform.volume = value;
			channel.soundTransform = soundTransform;
		}
		
		public function destroy():void {
			soundCompleted.removeAll();
			try {
				sound.close();
			} catch(e:Error){}
			sound = null;
			channel = null;
			soundTransform = null;
		}
		
		public function clone():SoundInstance {
			var si:SoundInstance = new SoundInstance(sound);
			return si;
		}

		public function get position():int { return channel? channel.position : 0; }
		public function set position(value:int):void {
			if(channel){ 
				stopChannel(channel);
			}
			channel = sound.play(value, loops);
		}
		
		protected function stopChannel(channel:SoundChannel):void {
			channel.stop(); 
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}		
		
	}
}