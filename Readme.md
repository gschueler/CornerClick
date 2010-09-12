About CornerClick 0.9
====================
&copy; 2003-2010 Greg Schueler [greg.schueler+cornerclick@gmail.com](mailto:greg.schueler+cornerclick@gmail.com) 
 
# NEWS

CornerClick is now open source under the [Apache 2 License](http://www.apache.org/licenses/LICENSE-2.0).

## What is it?

   CornerClick allows you to assign actions to each corner of your screen in Mac OS X.  Your screen corners can act like four buttons which will never move. You will never miss when you try to click the corner of the screen.  

   The Dock is badly designed from a user interface point of view.  If you have a lot of icons in your dock, either your icons are really tiny or you have magnification turned on.  Every time you want to launch something new, or just get back to Safari, you have to put on your Dock goggles and hunt for the right icon. The icon you want is never in the right place, or it tries to dodge your mouse when you have magnification turned on.

### How does it work?

   Tiny, nearly invisible windows hide in the corners of your screen.  When you click on them an action is performed.  The neat thing is that clicking in the exact corner of the screen is really easy to do, since you can just whip the mouse over there instantly.  You get to define what actions they perform, and you can have each corner do as many things as you want by holding down different modifier keys.

   If you like, a popup window will display what action is going to be performed when you point at any corner of the screen.

### How do I use it?

   CornerClick is a Preference Pane.  In the preference pane you can define multiple actions for each corner of the screen.  Each action has a possible set of modifiers: shift &#x21e7;, command  &#x2318;, option &#x2325;,  control  &#x2303;, or Fn.  (The Fn modifier is only useful on PowerBooks or iBooks.)  All of the modifiers you add to an action have to be held down when you click the corner for the action to be invoked.

## What's new?

Release to Github, *9/12/2010*:

* Finally releasing source before this project stagnates and dies
* Apache 2 Licensed, fork it!

version 0.9, *4/4/2010*:

* **Snow Leopard Support**: Fixed visual glitches, updated to 64-bit compatibility
* Fixed a tiny bug with scrolling behavior
* Added setting for duration of the delay for Hover actions

See the Version History...

### Installation:

Double-click the CornerClick.prefPane file from the installation disk image.  Choose to install the preference pane.  If you are upgrading a previous version of CornerClick, you should choose yes when asked if you want to replace the old version.


### What actions can be performed?

These are the types of actions:

1. Open File

   This action opens any file you choose.  If you pick an application, that application will launch if it's not running, and will come to the foreground if it is.  You can pick any folder or file as well.  

2. Hide Current Application

   This hides the current application.

3. Hide Other Applications

   This hides all of the other running applications.

4. Open URL
   
   This opens a URL of your choice.  You can also pick a display label for the URL, so that it looks better in the popup window.

5. Run AppleScript

   This runs an AppleScript when you click the corner.  The AppleScript is loaded and compiled by CornerClick so that it can be run quickly when the corner is clicked subsequent times.

6. Expos&eacute; Actions (All Windows, Application Windows, or Desktop)

      Performs the Expos&eacute; action chosen.  Just make sure to configure the appropriate Expos&eacute; command to be activated via one of the F-keys, in the Expos&eacute; preference pane.  CornerClick works by sending that F-key to the system.

### Help! My AppleScript Action isn't working!

If there is an error during loading, compiling, or running of  selected AppleScript, CornerClick will print out a message on the Console describing the error. (Open /Applications/Utilities/Console.app)

Please don't ask me for help with AppleScript problems that aren't related to CornerClick.  

There are many resources available on the internet.  Good luck.

### What else can it do?

Well you can make combos of actions by defining multiple actions for a corner, where all of them have the same exact set of modifiers.  

For example, add an Open File action that opens the Finder (/System/Library/CoreServices/Finder.app) with a certain set of modifier keys (or none at all).  Then add another Hide Other Applications action with the same exact modifier keys.  When you click in the corner with those modifier keys, both actions will be performed, and you'll end up clearing all the clutter on your screen and revealing the Desktop.  (The order you create the actions in is the order they are performed in.)

### How much does this cost?

It's free.  

### Any other features planned?

?? it's your source now...fork away

### LICENSE

 Copyright 2003-2010 Greg Schueler
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

### Version History
* FREE - release 9/12/2010
    * CornerClick has gone open source
    
* 0.9 - release 4/5/2010
    * Snow Leopard support, 64-bit compat
    * Add hover action delay setting
    * Fix slight bug with scrolling behavior
	* Works with Mac OS X 10.6 only

* 0.8.2 - release 8/4/2009
	* Fixed the "version 0.0" bug

* 0.8.1 - release 11/22/07
	* Leopard Spaces compatibility added.
	* Works with 10.5 only

* 0.8 - release 7/11/06
	* Add ScreenSaver action.
	* Fix top-right corner bug.
	* Added new German localization.

* 0.7.1 - release 1/19/06
	* Added new Spanish localization.
	* Rebuilt as Universal Binary.

* 0.7 - release 12/5/05
	* Add Dashboard action.
	* Fix System Preferences crashing bug.

* 0.6 - release 12/14/04
   * Add "Hover" trigger, allowing the action to be triggered when the mouse
   enters the corner.
   * Hover trigger also features an optional 2 second delay.

* 0.5 - release 9/29/04
	* Expos&eacute; actions added
	* Hover bubble font and icon size adjustable
	* tweaked the appearance, using quartz for drawing
	* started using bindings in the preference pane

* 0.4 - release 7/6/04
	* Right-Click trigger
	* Fn-key modifier
	* Dynamic hover bubbles
	* Improved hover bubbles
	* Scroll-wheel and keyboard action selection
	* Custom highlight color
	* Improved preference pane
	* miscellaneous bug fixes

* 0.2.1 - release 8/18/03
	* Fixes a bug which could accidentally delete all your CornerClick settings, and a few other minor bugs
	* Fixes some UI issues in the preference pane and helper app

* 0.2 - released 8/18/03
	* Multiple Monitor Support added
	* "Run AppleScript..." Action type added
	* PreferencePane UI revamped

* 0.1 - released 7/28/03
	* initial release
