
[license]: https://github.com/treefortress/SoundAS/raw/master/license.txt

SoundAS - AS3 SoundManager
==========================

A modern lightweight AS3 SoundManager for Flash and AIR. 

The goal of SoundAS is to simplifying playback of your audio files, with a focus on easily transitioning from one to another, and differentiating between SoundFX and Music Loops.

# Table of Contents

- [Features](#features) 
- [API Overview](#api-overview)
- [Installation](#installation)
- [Code Examples](#code-examples)
- [Advanced Examples](#advanced-examples)
- [Contribution Guide](#contribution-guide)
- [Unit Testing](#unit-testing) 
-  [License](#license)

# Features
* Clean modern API
* API Chaining: SoundAS.play("music").fadeTo(0);
* Supports groups of sounds
* Supports seamless looping
* Supports workaround for the 'looping bug' (http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/)
* Built-in Tweening system, no dependancies
* Modular API: Use SoundInstance directly and ignore the rest.
* Non-restrictive and unambigous license

The following file formats are supported by SoundAS for audio playback:

-   MP3
-   WAV
-   OGG/Vorbis
-   M4A (AAC)
-   FLAC
Note that other formats may be supported but may require additional libraries to be installed.
# API Overview

Full documentation can be found here: http://treefortress.com/libs/SoundAS/docs/.

### SoundAS
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

#### SoundInstance
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


# Installation
To install SoundAS locally on your computer, you can follow these steps:

1.  Download the latest version of SoundAS from the official GitHub repository: [https://github.com/treefortress/SoundAS/releases](https://github.com/treefortress/SoundAS/releases "https://github.com/treefortress/SoundAS/releases")
2.  Extract the downloaded ZIP file to a location of your choice.
3.  In your Flash or AIR project, add the extracted SoundAS SWC file to your library path.
4.  Finally, import the SoundAS classes you need in your project.

# Code Examples

### Loading

    //Load sound from an external file
    SoundAS.loadSound("assets/Click.mp3", "click");

    //Inject an already loaded Sound instance
    SoundAS.addSound("click", clickSound);

### Basic Playback

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
### Slowing down and speeding up audio:
```
// Load the sound 
SoundAS.loadSound("mySound.mp3", "mySound"); 

// Get the sound data as a ByteArray  
var soundData:ByteArray = SoundAS.getSound("mySound").data; 

// Set the playback speed to half (0.5) 
soundData.position = 0; 
var sound:Sound = new Sound(); 
sound.loadPCMFromByteArray(soundData, soundData.length); 
var channel:SoundChannel = sound.play(); 
channel.soundTransform = new SoundTransform(0.5);
```
### Changing Volume:
```
// Load the sound
SoundAS.loadSound("mySound.mp3", "mySound");

// Play the sound at half volume
var soundInstance:SoundInstance = SoundAS.play("mySound");
soundInstance.volume = 0.5;
```

Remember to thoroughly test your changes and ensure they adhere to project standards. Your commitment to maintaining code quality and functionality is greatly appreciated. Thank you for contributing to SoundAS!

## Advanced Examples
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

### Misc Advanced 

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



## Contribution Guide

Thank you for your interest in contributing to SoundAS! To get started, follow these steps:

### 1. Fork the Repository

Click the "Fork" button at the top-right corner of the repository's page. This will create a copy of the repository in your GitHub account.

### 2. Clone Your Fork

Clone your forked repository to your local machine:

```
git clone https://github.com/<your-username>/SoundAS.git
```
  

### 3. Create a New Branch

Create a new branch for your contribution:

```
git checkout -b feature/new-feature
```
  

### 4. Make Your Changes

Make the necessary changes to the codebase to fix whatever issue you are attempting to solve.

### 5. Test Your Changes

Before submitting your contribution, it's important to test your changes. Verify that your modifications work as expected and do not introduce new issues. Be sure to include relevant tests to validate your code. If applicable, update existing tests to cover your changes.

### 6. Commit Your Changes

Commit your changes with a clear and concise commit message:



```
git commit -m "Add new feature: description of your changes"
```
  

### 7. Push Your Changes

Push your changes to your forked repository:

```
git push origin feature/new-feature
```
  

### 8. Create a Pull Request

Return to the [repository](https://github.com/treefortress/SoundAS) and create a pull request (PR). Provide a brief description of your changes and any relevant context. Ensure that your PR title and description are clear and informative.

### 9. Review and Collaboration

Project maintainers will review your PR. They may provide feedback or request changes. Be responsive to comments or requests for clarification.

### 10. Celebrate Your Contribution

Once your contribution is accepted and merged into the project, your work becomes part of SoundAS. Congratulations on your successful contribution!

----------

Remember to thoroughly test your changes and ensure they adhere to project standards. Your commitment to maintaining code quality and functionality is greatly appreciated. Thank you for contributing to SoundAS!

## Unit Testing:
To run unit tests on SoundAS, you can follow these steps:

1.  Clone the SoundAS repository from GitHub: [https://github.com/treefortress/SoundAS](https://github.com/treefortress/SoundAS "https://github.com/treefortress/SoundAS")
2.  Open the repository in Visual Studio Code.
3.  Open the integrated terminal in Visual Studio Code.
4.  Run the command `npm install` to install the required dependencies.
5.  Run the command `npm test` to run the unit tests.
### License
[WTFPL][license]
