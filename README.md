[license]: https://github.com/treefortress/SoundAS/raw/master/license.txt

SoundAS - AS3 SoundManager
==========================

A modern lightweight AS3 SoundManager for Flash and AIR. 

The goal of SoundAS is to simplifying playback of your audio files, with a focus on easily transitioning from one to another, and differentiating between SoundFX and Music Loops.

#Features
* Clean modern API
* Easy memory management
* API Chaining: SoundAS.play("music").fadeTo(0);
* Built-in Tweening system, no dependancies
* Modular API. If all you need is a nice wrapper around the Sound object, use SoundInstance directly and ignore the rest.

#API Overview

Full documentation can be found here: http://treefortress.com/libs/SoundAS/docs/.

###SoundAS
This Static Class is the main interface for the library. It's responsible for loading and controlling all sounds globally.

Loading / Unloading: 

*    **addSound**(type:String, sound:Sound):void
*    **loadSound**(url:String, type:String, buffer:int = 100):void
*    **removeSound**(type:String):void
*    **removeAll**():void

Playback:

*    **getSound**(type:String, forceNew:Boolean = false):SoundInstance
*    **play**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true):SoundInstance
*    **playFx**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance
*    **playLoop**(type:String, volume:Number = 1, startTime:Number = 0):SoundInstance
*    **resume**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance
*    **resumeAll**():void
*    **pause**(type:String):SoundInstance
*    **pauseAll**():void
*    **set masterVolume**(value:Number):void
*    **fadeFrom**(type:String, startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)    
*    **fadeAllFrom**(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)
*    **fadeMasterFrom**(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)    
*    **fadeTo**(type:String, endVolume:Number = 1, duration:Number = 1000):SoundInstance
*    **fadeAllTo**(endVolume:Number = 1, duration:Number = 1000):SoundInstance
*    **fadeMasterTo**(endVolume:Number = 1, duration:Number = 1000)    

####SoundInstance
Controls playback of individual sounds, allowing you to easily stop, start, resume and set volume or position.

*     **play**(volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = true):SoundInstance
*     **pause**():SoundInstance
*     **resume**():SoundInstance
*     **stop**():SoundInstance
*     **set volume**(value:Number):void
*     **set mute**(value:Boolean):void
*     **fadeFrom**(startVolume:Number, endVolume:Number, duration:Number = 1000):SoundInstance
*     **fadeTo**(endVolume:Number, duration:Number = 1000):SoundInstance
*     **destroy**():void
*     **endFade**(applyEndVolume:Boolean = false):SoundInstance

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
    SoundAS.playLoop("music");

    //Toggle Mute for all sounds
    SoundAS.mute = !SoundAS.mute;

    //PauseAll / ResumeAll
    SoundAS.pauseAll();
    SoundAS.resumeAll();
     
    //Toggle Pause on individual song
    var sound:SoundInstance = SoundAS.getSound("music");
    (sound.isPaused)? sound.resume() : sound.pause();

    //Fade Out
    SoundAS.getSound("click").fadeTo(0);

    //Fade masterVolume out
    SoundAS.fadeMasterTo(0);

###Advanced 

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

    //Fade from .3 to .7 over 3 seconds
    SoundAS.getSound("click").fadeFrom(.3, .7, 3000);

	//Manage a SoundInstance directly and ignore SoundAS
    var sound:SoundInstance = new SoundInstance(mySound, "click");
    sound.play(volume);
    sound.position = 500; //Set position of sound in milliseconds
    sound.volume = .5; 
	sound.fadeTo(0);

---
### License
[WTFPL][license]

