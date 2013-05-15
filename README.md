[license]: https://github.com/treefortress/SoundAS/raw/master/license.txt

SoundAS - AS3 SoundManager
==========================

A modern lightweight AS3 SoundManager for Flash and AIR. 

The goal of SoundAS is to simplifying playback of your audio files, with a focus on easily transitioning from one to another, and differentiating between SoundFX and Music Loops.

#Features
* Clean modern API
* API Chaining: SoundAS.play("music").fadeTo(0);
* Supports groups of sounds
* Supports seamless looping
* Supports workaround for the 'looping bug' (http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/)
* Built-in Tweening system, no dependancies
* Modular API: Use SoundInstance directly and ignore the rest.
* Non-restrictive and unambigous license

#API Overview

Full documentation can be found here: http://treefortress.com/libs/SoundAS/docs/.

###SoundAS
This Class is the main interface for the library. It's responsible for loading and controlling all sounds globally. 

Loading / Unloading: 

*    **SoundAS.addSound**(type:String, sound:Sound):void
*    **SoundAS.loadSound**(url:String, type:String, buffer:int = 100):void
*    **SoundAS.removeSound**(type:String):void
*    **SoundAS.removeAll**():void

Playback:

*    **SoundAS.getSound**(type:String, forceNew:Boolean = false):SoundInstance
*    **SoundAS.play**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true, enableSeamlessLoops:Boolean = false):SoundInstance
*    **SoundAS.playFx**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance
*    **SoundAS.playLoop**(type:String, volume:Number = 1, startTime:Number = 0, enableSeamlessLoops:Boolean = true):SoundInstance
*    **SoundAS.resume**(type:String, volume:Number = 1, startTime:Number = 0, loops:int = 0):SoundInstance
*    **SoundAS.resumeAll**():void
*    **SoundAS.pause**(type:String):SoundInstance
*    **SoundAS.pauseAll**():void
*    **SoundAS.stopAll**():void
*    **SoundAS.set masterVolume**(value:Number):void
*    **SoundAS.fadeFrom**(type:String, startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)    
*    **SoundAS.fadeAllFrom**(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)
*    **SoundAS.fadeMasterFrom**(startVolume:Number = 0, endVolume:Number = 1, duration:Number = 1000)    
*    **SoundAS.fadeTo**(type:String, endVolume:Number = 1, duration:Number = 1000):SoundInstance
*    **SoundAS.fadeAllTo**(endVolume:Number = 1, duration:Number = 1000):SoundInstance
*    **SoundAS.fadeMasterTo**(endVolume:Number = 1, duration:Number = 1000)    

####SoundInstance
Controls playback of individual sounds, allowing you to easily stop, start, resume and set volume or position.

*     **play**(volume:Number = 1, startTime:Number = 0, loops:int = 0, allowMultiple:Boolean = true):SoundInstance
*     **pause**():SoundInstance
*     **resume**(forceStart:Boolean = false):SoundInstance
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

### Groups

    //Create a group
    var musicGroup:SoundManager = SoundAS.group("music");

    //Add sound(s) to group
    musicGroup.loadSound("assets/TitleMusic.mp3", "titleMusic");
    musicGroup.loadSound("assets/GameMusic.mp3", "gameMusic");

    //Use entire SoundAS API on Group:
    musicGroup.play("titleMusic")
    musicGroup.volume = .5;
    musicGroup.mute = muteMusic;
    musicGroup.fadeTo(0);
    //etc...

    //Stop All Groups
    for(var i:int = SoundAS.groups.length; i--;){
        SoundAS.groups[i].stopAll();
    }

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

    //String 2 songs together
    SoundAS.play(MUSIC1).soundCompleted.addOnce(function(si:SoundInstance){
        SoundAS.playLoop(MUSIC2);
    }

    //Loop twice, and trigger something when all loops are finished.
    SoundAS.play(MUSIC1, 1, 0, 2).soundCompleted.add(function(si:SoundInstance){
        if(si.loopsRemaining == -1){
            trace("Loops completed!");
            si.soundCompleted.removeAll();
        }
    }

---
### License
[WTFPL][license]

