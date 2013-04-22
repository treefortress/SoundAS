package treefortress.sound
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	

	public class SoundAS
	{
		protected static var instances:Vector.<SoundInstance>;
		protected static var instancesBySound:Dictionary;
		protected static var instancesByType:Object;
		protected static var activeTweens:Vector.<SoundTween>;
		
		protected static var ticker:Sprite;
		protected static var _mute:Boolean;
		protected static var _volume:Number;
		
		//Static Initialization
		{
			init();
			ticker = new Sprite();
			ticker.addEventListener(Event.ENTER_FRAME, onTick);
		}
		
		
		/**
		 * Dispatched when an external Sound has completed loading. 
		 */
		public static var loadCompleted:Signal;
		
		/**
		 * Dispatched when an external Sound has failed loading. 
		 */
		public static var loadFailed:Signal;
		
		/**
		 * Play audio by type. It must already be loaded into memory using the addSound() or loadSound() APIs. 
		 * @param type
		 * @param volume
		 * @param startTime Starting time in milliseconds
		 * @param loops Number of times to loop audio, pass -1 to loop forever.
		 * @param allowMultiple Allow multiple, overlapping instances of this Sound (useful for SoundFX)
		 * @param allowInterrupt If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
		 */
		public static function play(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance {
			var si:SoundInstance = getSound(type);
			
			//Sound is playing, and we're not allowed to interrupt it. Just set volume.
			if(!allowInterrupt && si.isPlaying){
				si.volume = volume;
			} 
				//Play sound
			else {
				si.play(volume, startTime, loops, allowMultiple);
			}
			return si;
		}
		
		/**
		 * Convenience function to play a sound that should loop forever.
		 * 
		 */
		public static function playLoop(type:String, volume:Number = 1, startTime:Number = -1):SoundInstance {
			return play(type, volume, startTime, -1, false);
		}
		
		/**
		 * Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
		 * 
		 */
		public static function playFx(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0):SoundInstance {
			return play(type, volume, startTime, 0, true);
		}
		
		/**
		 * Resume the sound if it's currently playing, otherwise start from beginning.
		 */
		public static function resume(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0):SoundInstance {
			return play(type, volume, startTime, 0, true);
		}
		
		/**
		 * Mute all instances.
		 */
		public static function get mute():Boolean { return _mute; }
		public static function set mute(value:Boolean):void {
			_mute = value;
			for(var i:int = 0, l:int = instances.length; i < l; i++){
				instances[i].mute = _mute;
			}
		}
		
		/**
		 * Set volume on all instances
		 */
		public static function get volume():Number { return _volume; }
		public static function set volume(value:Number):void {
			_volume = value;
			for(var i:int = 0, l:int = instances.length; i < l; i++){
				instances[i].volume = _volume;
			}
		}
		
		/**
		 * Returns a SoundInstance for a specific type.
		 */
		public static function getSound(type:String, forceNew:Boolean = false):SoundInstance {
			var si:SoundInstance = instancesByType[type];
			if(!si){ throw(new Error("[SoundAS] Sound with type '"+type+"' does not appear to be loaded.")); }
			if(forceNew){
				si = si.clone();	
			} 
			return si;
		}
		
		/**
		 * Preload a sound from a URL or Local Path
		 * @param url External file path to the sound instance.
		 * @param type 
		 * @param buffer
		 * 
		 */
		public static function loadSound(url:String, type:String, buffer:int = 100):void {
			var si:SoundInstance = new SoundInstance();
			si.type = type;
			si.url = url; //Useful for looking in case of load error
			si.sound = new Sound(new URLRequest(url), new SoundLoaderContext(buffer, false));
			si.sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError, false, 0, true);
			//si.sound.addEventListener(ProgressEvent.PROGRESS, onSoundLoadProgress, false, 0, true);
			si.sound.addEventListener(Event.COMPLETE, onSoundLoadComplete, false, 0, true);
			addInstance(si);
		}
		
		/**
		 * Inject a sound that has already been loaded.
		 */
		public static function addSound(type:String, sound:Sound):void {
			var si:SoundInstance = new SoundInstance();
			si.type = type;
			si.sound = sound;
			addInstance(si);
		}
		
		/**
		 * Remove a sound from memory.
		 */
		public static function removeSound(type:String):void {
			for(var i:int = instances.length - 1; i >= 0; i--){
				if(instances[i].type == type){
					instances[i].destroy();
					instances.splice(i, 1);
				}
			}
		}
		
		/**
		 * Unload all Sound instances.
		 */
		public static function removeAll():void {
			for(var i:int = 0; i < instances.length; i++){
				instances[i].destroy();
			}
			init();
		}
		
		/**
		 * PRIVATE
		 */
		
		protected static function init():void {
			//Create external signals
			if(!loadCompleted){ loadCompleted = new Signal(SoundInstance); }
			if(!loadFailed){ loadFailed = new Signal(SoundInstance); }
			
			//Init collections
			instances = new <SoundInstance>[];
			instancesBySound = new Dictionary(true);
			instancesByType = {};
			activeTweens = new Vector.<SoundTween>();
		}
		
		public static function addTween(type:String, startVolume:Number, endVolume:Number, duration:Number):void {
			var si:SoundInstance = getSound(type);
			if(startVolume >= 0){ si.volume = startVolume; }
			var tween:SoundTween = new SoundTween(si, endVolume, duration);
			//Remove any active tweens for this Sound
			for(var i:int = activeTweens.length - 1; i >= 0; i--){
				if(activeTweens[i].sound == si){
					activeTweens.splice(i, 1);
				}
			}
			activeTweens.push(tween);
		}
		
		protected static function onTick(event:Event):void {
			for(var i:int = activeTweens.length - 1; i >= 0; i--){
				if(activeTweens[i].update()){
					activeTweens.splice(i, 1);
				}
			}
		}
		
		protected static function addInstance(si:SoundInstance):void {
			si.mute = _mute;
			if(instances.indexOf(si) == -1){
				instances.push(si);
			}
			instancesBySound[si.sound] = si;
			instancesByType[si.type] = si;
		}
		
		protected static function onSoundLoadComplete(event:Event):void {
			var sound:Sound = event.target as Sound;
			loadCompleted.dispatch(instancesBySound[sound]);	
		}
		
		protected static function onSoundLoadProgress(event:ProgressEvent):void { }
		
		protected static function onSoundLoadError(event:IOErrorEvent):void {
			var sound:Sound = event.target as Sound;
			loadFailed.dispatch(instancesBySound[sound]);
		}
		
	}
}

