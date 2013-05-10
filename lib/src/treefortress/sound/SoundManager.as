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
	
	
	public class SoundManager
	{
		protected var instances:Vector.<SoundInstance>;
		protected var instancesBySound:Dictionary;
		protected var instancesByType:Object;
		protected var groupsByName:Object;
		public var groups:Vector.<SoundManager>;
		
		protected var activeTweens:Vector.<SoundTween>;
		
		protected var ticker:Sprite;
		protected var _tickEnabled:Boolean;
		protected var _mute:Boolean;
		protected var _volume:Number;
		protected var _masterVolume:Number;
		protected var _masterTween:SoundTween;
		
		public function SoundManager(){
			init();
		}
		
		/**
		 * Dispatched when an external Sound has completed loading. 
		 */
		public var loadCompleted:Signal;
		
		/**
		 * Dispatched when an external Sound has failed loading. 
		 */
		public var loadFailed:Signal;
		
		/**
		 * Play audio by type. It must already be loaded into memory using the addSound() or loadSound() APIs. 
		 * @param type
		 * @param volume
		 * @param startTime Starting time in milliseconds
		 * @param loops Number of times to loop audio, pass -1 to loop forever.
		 * @param allowMultiple Allow multiple, overlapping instances of this Sound (useful for SoundFX)
		 * @param allowInterrupt If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
		 */
		public function play(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance {
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
		public function playLoop(type:String, volume:Number = 1, startTime:Number = 0):SoundInstance {
			return play(type, volume, startTime, -1, false);
		}
		
		/**
		 * Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
		 */
		public function playFx(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance {
			return play(type, volume, startTime, 0, true);
		}
		
		/**
		 * Stop all sounds immediately.
		 */
		public function stopAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].stop();
			}
		}
		
		/**
		 * Resume specific sound 
		 */
		public function resume(type:String):SoundInstance {
			return getSound(type).resume();
		}
		
		/**
		 * Resume all paused instances.
		 */
		public function resumeAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].resume();
			}
		}
		
		/** 
		 * Pause a specific sound 
		 **/
		public function pause(type:String):SoundInstance {
			return getSound(type).pause();
		}
		
		/**
		 * Pause all sounds
		 */
		public function pauseAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].pause();
			}
		}
		
		/** 
		 * Fade specific sound starting at the current volume
		 **/
		public function fadeTo(type:String, endVolume:Number = 1, duration:Number = 1000):SoundInstance {
			return getSound(type).fadeTo(endVolume, duration);
		}
		
		/**
		 * Fade all sounds starting from their current Volume
		 */
		public function fadeAllTo(endVolume:Number = 1, duration:Number = 1000):void {
			for(var i:int = instances.length; i--;){
				instances[i].fadeTo(endVolume, duration);
			}
		}
		
		/** 
		 * Fade master volume starting at the current value
		 **/
		public function fadeMasterTo(endVolume:Number = 1, duration:Number = 1000):void {
			addMasterTween(_masterVolume, endVolume, duration);
		}
		
		/** 
		 * Fade specific sound specifying both the StartVolume and EndVolume.
		 **/
		public function fadeFrom(type:String, startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):SoundInstance {
			return getSound(type).fadeFrom(startVolume, endVolume, duration);
		}
		
		/**
		 * Fade all sounds specifying both the StartVolume and EndVolume.
		 */
		public function fadeAllFrom(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):void {
			for(var i:int = instances.length; i--;){
				instances[i].fadeFrom(startVolume, endVolume, duration);
			}
		}
		
		/** 
		 * Fade master volume specifying both the StartVolume and EndVolume.
		 **/
		public function fadeMasterFrom(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):void {
			addMasterTween(startVolume, endVolume, duration);
		}
		
		/**
		 * Mute all instances.
		 */
		public function get mute():Boolean { return _mute; }
		public function set mute(value:Boolean):void {
			_mute = value;
			for(var i:int = instances.length; i--;){
				instances[i].mute = _mute;
			}
		}
		
		/**
		 * Set volume on all instances
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			for(var i:int = instances.length; i--;){
				instances[i].volume = _volume;
			}
		}
		
		/**
		 * Returns a SoundInstance for a specific type.
		 */
		public function getSound(type:String, forceNew:Boolean = false):SoundInstance {
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
		public function loadSound(url:String, type:String, buffer:int = 100):void {
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
		public function addSound(type:String, sound:Sound):void {
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
		public function removeSound(type:String):void {
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
		public function removeAll():void {
			for(var i:int = instances.length; i--;){
				instances[i].destroy();
			}
			if(groups){
				for(i = groups.length; i--;){ groups[i].removeAll(); }
				groups.length = 0;
			}
			init();
		}
		
		/**
		 * Set master volume, which will me multiplied on top of all existing volume levels.
		 */
		public function get masterVolume():Number { return _masterVolume; }
		public function set masterVolume(value:Number):void {
			_masterVolume = value;
			for(var i:int = instances.length; i--;){
				instances[i].masterVolume = _masterVolume;
			}
		}
		
		/**
		 * Return a specific group , create one if it doesn't exist.
		 */
		public function group(name:String):SoundManager {
			if(!groupsByName[name]){ 
				groupsByName[name] = new SoundManager(); 
				
				if(!groups){ groups = new <SoundManager>[]; }
				groups.push(groupsByName[name]);
			}
			return groupsByName[name];
		}
		
		/**
		 * PRIVATE
		 */
		protected function init():void {
			//Create external signals
			if(!loadCompleted){ loadCompleted = new Signal(SoundInstance); }
			if(!loadFailed){ loadFailed = new Signal(SoundInstance); }
			
			//Init collections
			_volume = 1;
			_masterVolume = 1;
			instances = new <SoundInstance>[];
			instancesBySound = new Dictionary(true);
			instancesByType = {};
			groupsByName = {};
			activeTweens = new Vector.<SoundTween>();
		}
		
		internal function addMasterTween(startVolume:Number, endVolume:Number, duration:Number = 1000):void {
			if(!_masterTween){ _masterTween = new SoundTween(null, 0, 0, true); }
			_masterTween.init(startVolume, endVolume, duration);
			_masterTween.update(0);
			//Only add masterTween if it isn't already active.
			if(activeTweens.indexOf(_masterTween) == -1){
				activeTweens.push(_masterTween);
			}
			tickEnabled = true;
		}
		
		internal function addTween(type:String, startVolume:Number, endVolume:Number, duration:Number):SoundTween {
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
		
		protected function onTick(event:Event):void {
			var t:int = getTimer();
			for(var i:int = activeTweens.length; i--;){
				if(activeTweens[i].update(t)){
					activeTweens.splice(i, 1);
				}
			}
			tickEnabled = (activeTweens.length > 0);
		}
		
		protected function addInstance(si:SoundInstance):void {
			si.mute = _mute;
			si.group = this;
			if(instances.indexOf(si) == -1){ instances.push(si); }
			instancesBySound[si.sound] = si;
			instancesByType[si.type] = si;
		}
		
		protected function onSoundLoadComplete(event:Event):void {
			var sound:Sound = event.target as Sound;
			loadCompleted.dispatch(instancesBySound[sound]);	
		}
		
		protected function onSoundLoadProgress(event:ProgressEvent):void { }
		
		protected function onSoundLoadError(event:IOErrorEvent):void {
			var sound:SoundInstance = instancesBySound[event.target as Sound];
			loadFailed.dispatch(sound);
			trace("[SoundAS] ERROR: Failed Loading Sound '"+sound.type+"' @ "+sound.url);
		}
		
		protected function get tickEnabled():Boolean { return _tickEnabled; }
		protected function set tickEnabled(value:Boolean):void {
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


