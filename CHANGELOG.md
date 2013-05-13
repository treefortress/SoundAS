CHANGELOG
=========

####May 5, 2013
* Added support for Groups
** SoundAS.play becomes SoundAS().play
** Moved bulk of functionality to SoundManager class.
* Added FLA-based Demo to test older versions of the compiler.


####April 24, 2013
* Added Test Suite
* Added better support for orphaned channels. 
* Added fix for obscure Sound bug with pausing a looping sound. 
* Added instance.isPaused
* Added instance.loopsRemaining
* Added instance.mixedVolume
* Added SoundAS.stopAll()
* Misc bug fixes

####April 23, 2013
* New APIs: fadeMasterTo, fadeMasterFrom, set masterVolume, instance.endFade, tween.end
* Added "Master" volume control
* Improved looping implementation (loop on SoundComplete rather than 9999)
* Optimized calling addSound() with an already mapped type
* Fixed bug with SoundComplete event
* Optimized ENTER_FRAME listener to only run while Tweens are active
* Optimized tweens to reduce getTimer() calls
* Other small API fixes


####April 22, 2013
* Initial release