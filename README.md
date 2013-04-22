SoundAS
=======

A modern lightweight sound manager for AS3. 

#API Overview

SoundAS has API designed to facilitate extremely easy management of Sounds within your AS3 projects. It is built to allow you to manage multiple streams of audio very easily, fadeing them in and out as required, or layering them as you need.

* _SoundAS_ - This is the main Static class, responsible for loading and controlling all sounds globally. You can use this class to initiate playback, or simply to retreice a SoundInstance to work with.
* _SoundInstance_ - Is returned each time a new sound is played. SoundInstance is responsible for controlling playback of individual sounds, allowing you to easily stop, start, change volume, or set position of any sound.

#Loading

    //Load sound from an external file
    SoundAS.loadSound("assets/Click.mp3", "click");

    //Inject an already loaded sound
    SoundAS.addSound(clickSound, "click");

#Basic Playback

    //Play
    SoundAS.play("click", volume, startTime, loops, allowMultiple, allowInterrupt);

    //Toggle Mute 
    SoundAS.mute = !SoundAS.mute;

    //Fade Out
    SoundAS.getSound("click").fadeTo(0);

#Advanced Playback 

    //Mute one sound
    SoundsAS.getSound("click").mute = true;d

    //Fade from .3 to .7 over 3 seconds
    SoundAS.getSound("click").fadeFrom(.3, .7, 3000);

	//Manage a SoundInstance directly
    var sound:SoundInstance = SoundAS.getSound("click");
    sound.play(volume);
    sound.position = 500; //Set position of sound in milliseconds
    sound.volume = .5; 
	sound.fadeTo(0);




