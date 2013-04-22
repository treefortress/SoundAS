[license]: https://github.com/treefortress/SoundAS/raw/master/license.txt

SoundAS
=======

A modern lightweight sound manager for AS3. 

The goal of SoundAS is to simplifying playback of your audio files, with a focus on easily transitioning from one to another, and differentiating between SoundFX and Music Loops.

#Features
* Clean modern API
* Easy memory management
* API Chaining: SoundAS.play("music").fadeTo(0);
* Built-in Tweening system, no dependancies

#API Overview

##SoundAS
This Static Class is the main interface for the library. It's responsible for loading and controlling all sounds globally.

Loading / Unloading: 

*    **addSound**(type:String, sound:Sound):void
*    **loadSound**(url:String, type:String, buffer:int = 100):void
*    **removeSound**(type:String):void
*    **removeAll**():void

Playback:

*    getSound(type:String, forceNew:Boolean = false):SoundInstance
*    play(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance
*    playFx(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0):SoundInstance
*    playLoop(type:String, volume:Number = 1, startTime:Number = -1):SoundInstance
*    resume(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0):SoundInstance


    
addSound(type:String, sound:Sound):void
[static] Inject a sound that has already been loaded.
SoundAS
        
addTween(type:String, startVolume:Number, endVolume:Number, duration:Number):void
[static]
SoundAS
        
fadeAllFrom(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):void
[static] Fade all sounds specifying both the StartVolume and EndVolume.
SoundAS
        
fadeAllTo(endVolume:Number = 1, duration:Number = 1000):void
[static] Fade all sounds starting from their current Volume
SoundAS
        
fadeFrom(type:String, startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000):SoundInstance
[static] Fade specific sound specifying both the StartVolume and EndVolume.
SoundAS
        
fadeTo(type:String, endVolume:Number = 1, duration:Number = 1000):SoundInstance
[static] Fade specific sound starting at the current volume
SoundAS
        
getSound(type:String, forceNew:Boolean = false):SoundInstance
[static] Returns a SoundInstance for a specific type.
SoundAS
        
loadSound(url:String, type:String, buffer:int = 100):void
[static] Preload a sound from a URL or Local Path
SoundAS
        
pause(type:String):SoundInstance
[static] Pause a specific sound
SoundAS
        
pauseAll():void
[static] Pause all sounds
SoundAS
        
play(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance
[static] Play audio by type.
SoundAS
        
playFx(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0):SoundInstance
[static] Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
SoundAS
        
playLoop(type:String, volume:Number = 1, startTime:Number = -1):SoundInstance
[static] Convenience function to play a sound that should loop forever.
SoundAS
        
removeAll():void
[static] Unload all Sound instances.
SoundAS
        
removeSound(type:String):void
[static] Remove a sound from memory.
SoundAS
        
resume(type:String):SoundInstance
[static] Resume specific sound
SoundAS
        
resumeAll():void
[static] Resume all paused instances.

##SoundInstance
Controls playback of individual sounds, allowing you to easily stop, start, resume and set volume or position.

#Code Examples

###Loading

    //Load sound from an external file
    SoundAS.loadSound("assets/Click.mp3", "click");

    //Inject an already loaded Sound instance
    SoundAS.addSound(clickSound, "click");

###Basic Playback

    //Play sound.
        //allowMultiple: Allow multiple overlapping sound instances.
        //allowInterrupt: If this sound is currently playing, start it over.
    SoundAS.play("click", volume, startTime, loops, allowMultiple, allowInterrupt);

    //Shortcut for typical game fx (no looping, allows for multiple instances)
    SoundAS.playFx("click");

    //Shortcut for typical game music (loops forever, no multiple instances)
    SoundAS.playLoop("click");

    //Toggle Mute 
    SoundAS.mute = !SoundAS.mute;

    //Fade Out
    SoundAS.getSound("click").fadeTo(0);

###Advanced 

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

    //Fade from .3 to .7 over 3 seconds
    SoundAS.getSound("click").fadeFrom(.3, .7, 3000);

	//Manage a SoundInstance directly
    var sound:SoundInstance = SoundAS.getSound("click");
    sound.play(volume);
    sound.position = 500; //Set position of sound in milliseconds
    sound.volume = .5; 
	sound.fadeTo(0);

---
### License
[WTFPL][license]

