SoundAS
=======

A modern lightweight sound manager for AS3. 

#API Overview

#Code Examples

    //Load sound from an external file
    SoundAS.loadSound("assets/Click.mp3", "click");

    //Inject an already loaded sound
    SoundAS.addSound(clickSound, "click");

    //Play
    SoundAS.play("click", volume, startTime, loops, allowMultiple, allowInterrupt);

    //Toggle Mute 
    SoundAS.mute = !SoundAS.mute;

    //Mute one sound
    SoundsAS.getSound("click").mute = true;

	//Fade Out
    SoundAS.getSound("click").fadeTo(0);

    //Fade from .3 to .7 over 3 seconds
    SoundAS.getSound("click").fadeFrom(.3, .7, 3000);

    //Unload Sounds
    SoundAS.unloadAll();




