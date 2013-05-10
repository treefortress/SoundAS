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
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	
	public class SoundAS
	{
		protected static var instances:Vector.<SoundInstance>;
		protected static var instancesBySound:Dictionary;
		protected static var instancesByType:Object;
		protected static var activeTweens:Vector.<SoundTween>;
		
		protected static var ticker:Sprite;
		protected static var _tickEnabled:Boolean;
		protected static var _mute:Boolean;
		protected static var _volume:Number;
		protected static var _masterVolume:Number;
		protected static var _masterTween:SoundTween;
		
		//Static Initialization
		{
			init();
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
		public static function play(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance {
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
		 */
		public static function playLoop(type:String, volume:Number = 1, startTime:Number = 0):SoundInstance {
			return play(type, volume, startTime, -1, false);
		}
		
		/**
		 * Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
		 */
		public static function playFx(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance {
			return play(type, volume, startTime, 0, true);
		}
		
		/**
		 * Stop all sounds immediately.
		 */
		public static function stopAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].stop();
			}
		}
		
		/**
		 * Resume specific sound 
		 */
		public static function resume(type:String):SoundInstance {
			return getSound(type).resume();
		}
		
		/**
		 * Resume all paused instances.
		 */
		public static function resumeAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].resume();
			}
		}
		
		/** 
		 * Pause a specific sound 
		 **/
		public static function pause(type:String):SoundInstance {
			return getSound(type).pause();
		}
		
		/**
		 * Pause all sounds
		 */
		public static function pauseAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].pause();
			}
		}
		
		/** 
		 * Fade specific sound starting at the current volume
		 **/
		public static function fadeTo(type:String, endVolume:Number = 1, duration:Number = 1000):SoundInstance {
			return getSound(type).fadeTo(endVolume, duration);
		}
		
		/**
		 * Fade all sounds starting from their current Volume
		 */
		public static function fadeAllTo(endVolume:Number = 1, duration:Number = 1000):void {
			for(var i:int = instances.length; i--;){
				instances[i].fadeTo(endVolume, duration);
			}
		}
		
		/** 
		 * Fade master volume starting at the current value
		 **/
		public static function fadeMasterTo(endVolume:Number = 1, duration:Number = 1000):void {
			addMasterTween(_masterVolume, endVolume, duration);
		}
		
		/** 
		 * Fade specific sound specifying both the StartVolume and EndVolume.
		 **/
		public static function fadeFrom(type:String, startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):SoundInstance {
			return getSound(type).fadeFrom(startVolume, endVolume, duration);
		}
		
		/**
		 * Fade all sounds specifying both the StartVolume and EndVolume.
		 */
		public static function fadeAllFrom(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):void {
			for(var i:int = instances.length; i--;){
				instances[i].fadeFrom(startVolume, endVolume, duration);
			}
		}
		
		/** 
		 * Fade master volume specifying both the StartVolume and EndVolume.
		 **/
		public static function fadeMasterFrom(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):void {
			addMasterTween(startVolume, endVolume, duration);
		}
		
		/**
		 * Mute all instances.
		 */
		public static function get mute():Boolean { return _mute; }
		public static function set mute(value:Boolean):void {
			_mute = value;
			for(var i:int = instances.length; i--;){
				instances[i].mute = _mute;
			}
		}
		
		/**
		 * Set volume on all instances
		 */
		public static function get volume():Number { return _volume; }
		public static function set volume(value:Number):void {
			_volume = value;
			for(var i:int = instances.length; i--;){
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
			//Check whether this Sound is already loaded
			var si:SoundInstance = instancesByType[type];
			if(si && si.url == url){ return; }
			
			si = new SoundInstance(null, type);
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
			var si:SoundInstance;
			//If the type is already mapped, inject sound into the existing SoundInstance.
			if(instancesByType[type]){
				si = instancesByType[type];
				si.sound = sound;
			} 
				//Create a new SoundInstance
			else {
				si = new SoundInstance(sound, type);
			}
			addInstance(si);
		}
		
		/**
		 * Remove a sound from memory.
		 */
		public static function removeSound(type:String):void {
			if(instancesByType[type] == null){ return; }
			for(var i:int = instances.length; i--;){
				if(instances[i].type == type){
					instancesBySound[instances[i].sound] = null;
					instances[i].destroy();
					instances.splice(i, 1);
				}
			}
			instancesByType[type] = null;
		}
		
		/**
		 * Unload all Sound instances.
		 */
		public static function removeAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].destroy();
			}
			init();
		}
		
		/**
		 * Set master volume, which will me multiplied on top of all existing volume levels.
		 */
		public static function get masterVolume():Number { return _masterVolume; }
		public static function set masterVolume(value:Number):void {
			_masterVolume = value;
			for(var i:int = instances.length; i--;){
				instances[i].masterVolume = _masterVolume;
			}
		}
		
		/**
		 * PRIVATE
		 */
		protected static function init():void {
			//Create external signals
			if(!loadCompleted){ loadCompleted = new Signal(SoundInstance); }
			if(!loadFailed){ loadFailed = new Signal(SoundInstance); }
			
			//Init collections
			_volume = 1;
			_masterVolume = 1;
			instances = new <SoundInstance>[];
			instancesBySound = new Dictionary(true);
			instancesByType = {};
			activeTweens = new Vector.<SoundTween>();
		}
		
		internal static function addMasterTween(startVolume:Number, endVolume:Number, duration:Number = 1000):void {
			if(!_masterTween){ _masterTween = new SoundTween(null, 0, 0, true); }
			_masterTween.init(startVolume, endVolume, duration);
			_masterTween.update(0);
			//Only add masterTween if it isn't already active.
			if(activeTweens.indexOf(_masterTween) == -1){
				activeTweens.push(_masterTween);
			}
			tickEnabled = true;
		}
		
		internal static function addTween(type:String, startVolume:Number, endVolume:Number, duration:Number):SoundTween {
			var si:SoundInstance = getSound(type);
			if(startVolume >= 0){ si.volume = startVolume; }
			var tween:SoundTween = new SoundTween(si, endVolume, duration);
			tween.update(0);
			//Kill any active tween, it will get removed the next time the tweens are updated.
			si.endFade();
			//Add new tween
			activeTweens.push(tween);
			
			tickEnabled = true;
			return tween;
		}
		
		protected static function onTick(event:Event):void {
			var t:int = getTimer();
			for(var i:int = activeTweens.length; i--;){
				if(activeTweens[i].update(t)){
					activeTweens.splice(i, 1);
				}
			}
			tickEnabled = (activeTweens.length > 0);
		}
		
		protected static function addInstance(si:SoundInstance):void {
			si.mute = _mute;
			if(instances.indexOf(si) == -1){ instances.push(si); }
			instancesBySound[si.sound] = si;
			instancesByType[si.type] = si;
		}
		
		protected static function onSoundLoadComplete(event:Event):void {
			var sound:Sound = event.target as Sound;
			loadCompleted.dispatch(instancesBySound[sound]);	
		}
		
		protected static function onSoundLoadProgress(event:ProgressEvent):void { }
		
		protected static function onSoundLoadError(event:IOErrorEvent):void {
			var sound:SoundInstance = instancesBySound[event.target as Sound];
			loadFailed.dispatch(sound);
			trace("[SoundAS] ERROR: Failed Loading Sound '"+sound.type+"' @ "+sound.url);
		}
		
		protected static function get tickEnabled():Boolean { return _tickEnabled; }
		protected static function set tickEnabled(value:Boolean):void {
			if(value == _tickEnabled){ return; }
			_tickEnabled = value;
			if(_tickEnabled){
				if(!ticker){ ticker = new Sprite(); }
				ticker.addEventListener(Event.ENTER_FRAME, onTick);
			} else {
				ticker.removeEventListener(Event.ENTER_FRAME, onTick); 
			}
		}
	}
}


