package treefortress.sound
{
	import flash.utils.getTimer;
	import treefortress.sound.SoundInstance;
	
	public class SoundTween {
		
		public var startTime:int;
		public var startVolume:Number;
		public var endVolume:Number;
		public var duration:Number;
		public var sound:SoundInstance;
		
		public function SoundTween(si:SoundInstance, endVolume:Number, duration:Number) {
			sound = si;
			startTime = getTimer();
			startVolume = si.volume;
			this.endVolume = endVolume;
			this.duration = duration;
		}
		
		public function update():Boolean {
			sound.volume = easeOutQuad(getTimer() - startTime, startVolume, endVolume - startVolume, duration);
			if(getTimer() - startTime >= duration){
				sound.volume = endVolume;
			}
			return sound.volume == endVolume;
		}
		
		/**
		 * Equations from the man Robert Penner, see here for more:
		 * http://www.dzone.com/snippets/robert-penner-easing-equations
		 */
		protected static function easeOutQuad(position:Number, startValue:Number, change:Number, duration:Number):Number {
			return -change *(position/=duration)*(position-2) + startValue;
		};
		
		protected static function easeInOutQuad(position:Number, startValue:Number, change:Number, duration:Number):Number {
			if ((position/=duration/2) < 1){
				return change/2*position*position + startValue;
			}
			return -change/2 * ((--position)*(position-2) - 1) + startValue;
		};
	}
}