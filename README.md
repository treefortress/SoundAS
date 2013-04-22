SoundAS
=======

A modern lightweight sound manager for AS3. 

API Overview

###SoundAS.loadSound(url:String, type:String)
Load an external path;

###SoundAS.addSound(sound:Sound, type:String)
Inject a sound you've loaded externally.

###SoundAS.play(type:String, volume:Number = 1, startTime:Number = -1, loops:int = 0, allowMultiple:Boolean = false, allowInterrupt:Boolean = true)
The core play function for the library. 

#Basic Usage

    //Load sound from an external file
    SoundAS.loadSound("assets/Click.mp3", "click");

    //Play
    SoundAS.play("click");

    //Toggle Mute 
    SoundAS.mute = !SoundAS.mute;

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

#Advanced Features

    //Fade Out
    SoundAS.getSound("click").fadeTo(0);

    //Fade from .3 to .7 over 3 seconds
    SoundAS.getSound("click").fadeFrom(.3, .7, 3000);


